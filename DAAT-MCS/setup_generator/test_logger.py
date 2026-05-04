import threading
import serial
import time

list_boot_times = []

class test_logger:
    def __init__(self, master_port, master_baud_rate):
        self.master_port = master_port
        self.serial_ports = []
        self.log_threads = []
        self.event_end_of_test = threading.Event()
        self.test_completed = False
        self.serial_tags = {
            "test_start": "[START] Profilling Started",
            "test_end": "[END] Profiling Completed",
            "boot_error" : "Kernel OS not found",
            "bao_error" : "BAO ERROR",
            "boot_error_1" : "ERROR: can't get kernel image"
        }
        self.serial_func_map = {
            self.serial_tags["test_start"]: self.logger_start,
            self.serial_tags["test_end"]: self.logger_end,
            self.serial_tags["boot_error"]: self.logger_boot_error,
            self.serial_tags["bao_error"]: self.logger_bao_error,
            self.serial_tags["boot_error_1"]: self.logger_boot_error
        }

        ser_port = self.open_serial_port(master_port, master_baud_rate)
        if ser_port is None:
            raise Exception("Error opening master port")
        else:
            self.serial_ports.append(ser_port)

    def store_log(self, log, filename):
        with open(filename, "w") as f:
            f.write(log)

    def open_serial_port(self, serial_port, baudrate):
        # Check if port is already open
        for ser in self.serial_ports:
            if ser.name == serial_port:
                print("Serial port already open")
                return ser

        ser = serial.Serial(serial_port, baudrate, timeout=1)
        if ser.isOpen():
            self.serial_ports.append(ser)
            return ser  # Do not add to self.serial_ports here
        else:
            print("Error opening serial port")
            return None

    def close_serial_port(self, serial_port):
        for ser in self.serial_ports:
            if ser.name == serial_port:
                ser.close()
                self.serial_ports.remove(ser)
                return
        print("Serial port not found")
    
    def set_logger_to_port(self, serial_port, output_file):
        # get the ser_obj from serial_ports
        for ser in self.serial_ports:
            if ser.name == serial_port:
                ser_port = ser
                break
        else:
            print("Serial port not found")
            return
    
        log_thread = threading.Thread(
            target=self.trace_results_thread,
            args=(output_file, ser_port)
        )
        log_thread.start()
        self.log_threads.append(log_thread)
        
    def logger_start(self, logging_controller):
        logging_controller["logging_start"] = True
        logging_controller["log_boot_end_time"] = time.time()
        
    def logger_end(self, logging_controller):
        logging_controller["log_exec_time_end"] = time.time()
        logging_controller["logging_start"] = False
        self.event_end_of_test.set()
        self.store_log(
            "\n".join(logging_controller["logging_content"]),
            logging_controller["logging_output_file"]
            )
    
        list_boot_times.append(
            logging_controller["log_boot_end_time"] - logging_controller["log_boot_start_time"]
        )
        self.test_completed = True
        print("Test completed successfully in {:.2f} seconds".format(
            logging_controller["log_exec_time_end"] - logging_controller["log_boot_end_time"]
        ))
        
    def logger_boot_error(self, logging_controller):
        logging_controller["logging_start"] = False
        self.event_end_of_test.set()

    def logger_bao_error(self, logging_controller):
        logging_controller["logging_start"] = False
        self.event_end_of_test.set()

    def trace_results_thread(self, output_file, serial_port):
        logging_controller = {
            "logging_start" : False,
            "logging_content" : [],
            "logging_output_file" : output_file,
            "log_boot_start_time" : 0,
            "log_boot_end_time" : 0,
        }

        # measure the time between open serial port and first line read
        logging_controller["log_boot_start_time"] = time.time()
        first_line = False

        try:
            while not self.event_end_of_test.is_set():
                line = serial_port.readline().decode("utf-8",  errors="ignore").strip()
                if not line:
                    continue
                else:
                    # print(line)
                    if not first_line:
                        first_line = True
                        logging_controller["log_boot_start_time"] = time.time()

                    if line in self.serial_func_map:
                        self.serial_func_map[line](logging_controller)
                    else:
                        if logging_controller["logging_start"]:
                            logging_controller["logging_content"].append(line)
                            # print(line)

        except KeyboardInterrupt:
            print("Logging interrupted by user.")

        finally:
            # check if serial_port is not master_port
            if serial_port.port != self.master_port:
                print("Closing serial port", serial_port.port)
                self.close_serial_port(serial_port.port)
            if logging_controller["logging_start"]:
                self.store_log(
                    "\n".join(logging_controller["logging_content"]),
                    logging_controller["logging_output_file"]
                )

    def wait_for_test_end(self, timeout=0):
        for thread in self.log_threads:
            thread.join() if timeout == 0 else thread.join(timeout)
            
            if thread.is_alive():
                self.event_end_of_test.set()
                break
        return self.test_completed
    
    def reset_test_status(self):
        self.test_completed = False
