import math
import os
import shutil
import subprocess
import netifaces as ni
import re

def find_sector(content, pattern):
    sect = pattern.findall(content)
    return sect

def replace_config(config, confif_sector, new_config):
    file_content = config.replace(confif_sector, new_config)
    return file_content

class profiler_guest:
    def __init__(self):
        self.profiler_dir = ""
        self.build_guest = False
        self.rebuild_initrd = False

        self.num_target_cpus = 0
        self.store_buffer_size = 0
        self.num_store_buffers = 0

        self.list_guests = []
        self.list_variants = []
        self.profiler_runtime_config = {
            "server_ip" : "",
            "shmem_phys_addr" : 4026531840,     # 0xf0000000
            "shmem_size" : 65536,               # 0x00010000
            "store_buffer_size" : 0,
            "num_store_buffers" : 0,
            "tx_packet_size" : 0,
        }

        self.eth_logger_build = False
        self.profiler_toc_file = ""

    # create a function that returns all the possible configurations
    def get_configurations(self, num_pmc_available):
        total_num_guests = 1
        
        self.list_guests.append({
            "profiler_dir" : self.profiler_dir,
            "build_guest" : self.build_guest,
            "num_target_cpus" : self.num_target_cpus,
            "store_buffer_size" : self.store_buffer_size,
            "num_store_buffers" : self.num_store_buffers,
        })

    def read_config(self, linux_config):
        self.profiler_dir = linux_config.get("profiler_dir", "")
        self.build_guest = linux_config.get("build_guest", False)
        self.rebuild_initrd = linux_config.get("rebuild_initrd", False)
        
        linux_performance_monitor = linux_config.get("profiler_configuration", {})
        self.list_events = linux_performance_monitor.get("events", [])
        self.profiling_period_us = linux_performance_monitor.get("profiling_period_us", [])
        store_buffer_size = linux_performance_monitor.get("store_buffer_size", "")
        # store buffer size is a string that can be in the format of 1MB, 2GB, etc.
        if store_buffer_size:
            if store_buffer_size.endswith("KB"):
                self.store_buffer_size = int(store_buffer_size[:-2]) * 1024
            elif store_buffer_size.endswith("MB"):
                self.store_buffer_size = int(store_buffer_size[:-2]) * 1024 * 1024
            elif store_buffer_size.endswith("GB"):
                self.store_buffer_size = int(store_buffer_size[:-2]) * 1024 * 1024 * 1024
            else:
                self.store_buffer_size = int(store_buffer_size)

        self.num_target_cpus = linux_performance_monitor.get("num_target_cpus", 0)
        self.num_store_buffers = linux_performance_monitor.get("num_store_buffers", 0)

        self.profiler_runtime_config["store_buffer_size"] = self.store_buffer_size
        self.profiler_runtime_config["num_store_buffers"] = self.num_store_buffers
        self.profiler_runtime_config["server_ip"] = ni.ifaddresses('wlp5s0')[ni.AF_INET][0]['addr']         # need to check if this works properly
        
        # profiler_sample_size = self.num_target_cpus * len(self.list_events) * 4
        # tx_packet_size = (self.store_buffer_size - 8) - self.store_buffer_size % (profiler_sample_size*4)
        
        self.profiler_runtime_config["tx_packet_size"] = self.store_buffer_size

    def generate_profiler_variant(self, num_target_cpus, store_buffer_size, num_store_buffers):
        events_codes = []

            
        guest_profiler = [
            ".non_evasive_profiler = {",
            f"\t\t\t\t.num_target_cpus = {num_target_cpus},",
            f"\t\t\t\t.store_buffer_size = {store_buffer_size},",
            f"\t\t\t\t.num_store_buffers = {num_store_buffers},",
            "\t\t\t},\n\t"
        ]
        guest_profiler = [x.replace(")[", "){").replace("],", "},") for x in guest_profiler]
        return guest_profiler
    
    def generate_profiler_combinations(self, hw_obj=None):
        list_profile_variants = []

        for guest in self.list_guests:
            guest_perf_monitor = self.generate_profiler_variant(
                                    guest["num_target_cpus"],
                                    guest["store_buffer_size"],
                                    guest["num_store_buffers"]
                                    )
            list_profile_variants.append(guest_perf_monitor)
        
        return list_profile_variants

    def generate_perf_monitor_variant_code(self, file_content, guest, perf_monitor_pattern):
        perf_mon_sect = find_sector(file_content, perf_monitor_pattern)
        perf_mon_config = "\n".join(guest) + "\n"
        new_file_content = replace_config(file_content, perf_mon_sect[0], perf_mon_config)

        return new_file_content

    def generate_guest_config_files(self, benchmark, template_file, hw_obj=None):
        template_file_content = ""
        dict_guest_config = {}
        with open(template_file, 'r') as f:
            template_file_content = f.read()

        guest_config_file = template_file_content
        guest_image_name = f"profile"

        guest = self.generate_profiler_combinations(hw_obj)[0]

        profiler_image_name_pattern = re.compile(r"#profiler_name#\s*")
        profiler_image_sect = find_sector(guest_config_file, profiler_image_name_pattern)
        new_file_content = new_file_content = replace_config(guest_config_file, profiler_image_sect[0], f"{benchmark}/profiler")

        performance_monitor_pattern = re.compile(r"#profiler_config#\n")
        new_file_content = self.generate_perf_monitor_variant_code(new_file_content, guest, performance_monitor_pattern)
        dict_guest_config[guest_image_name] = new_file_content

        dict_guest_config[guest_image_name] = new_file_content
    
        return dict_guest_config
 
    def create_profiler_runtime_script(self, out_dir):
        import os

        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        out_dir = os.path.join(out_dir, "etc/profile.d")
        os.makedirs(out_dir, exist_ok=True)
        script_path = os.path.join(out_dir, "profiler_runtime.sh")
        print(f"Creating profiler runtime script at {script_path}")

        with open(script_path, 'w') as f:
            f.write("#!/bin/bash\n\n")

            # Export environment variables
            f.write(f"export SERVER_IP={self.profiler_runtime_config['server_ip']}\n")
            f.write(f"export SHMEM_PHYS_ADDR={self.profiler_runtime_config['shmem_phys_addr']}\n")
            f.write(f"export SHMEM_SIZE={self.profiler_runtime_config['shmem_size']}\n")
            f.write(f"export STORE_BUFFER_SIZE={self.profiler_runtime_config['store_buffer_size']}\n")
            f.write(f"export NUM_STORE_BUFFERS={self.profiler_runtime_config['num_store_buffers']}\n")
            f.write(f"export TX_PACKET_SIZE={self.profiler_runtime_config['tx_packet_size']}\n\n")

            # Improved network interface wait logic
            f.write('INTERFACE="eth0"\n')
            f.write('echo "Waiting for $INTERFACE to be up..."\n')
            f.write('while ! ip link show "$INTERFACE" | grep -qw "UP"; do\n')
            f.write('    sleep 1\n')
            f.write('done\n')

            f.write('echo "$INTERFACE is up, waiting for IP address..."\n')
            f.write('while ! ip addr show "$INTERFACE" | grep -q "inet "; do\n')
            f.write('    sleep 1\n')
            f.write('done\n')

            f.write('echo "IP obtained. Waiting for default route..."\n')
            f.write('while ! ip route show default | grep -q "dev $INTERFACE"; do\n')
            f.write('    sleep 1\n')
            f.write('done\n')

            f.write('echo "$INTERFACE is fully configured."\n\n')

            # Launch client application
            f.write("echo 'Launching profiler client application...'\n")
            f.write("echo \"2 0 0 0\" > /dev/baohypercall0\n")
            f.write("/root/client ${SERVER_IP} 5201 $SHMEM_PHYS_ADDR $STORE_BUFFER_SIZE\n")
            f.write("echo 'Profiler client application exited'\n")
            f.write("echo '--------------------------------------------------------'\n\n")

            # Keep script running to avoid exit (optional)
            f.write("while true; do\n")
            f.write("    sleep 1\n")
            f.write("done\n")

            f.write("exit 0\n")

        os.chmod(script_path, 0o755)

    def build_guests(self, out_dir, platform):
        command = []
        if self.build_guest:
            command = [
                "bash", "-c",
                f"""
                    make -C {self.profiler_dir} PLATFORM={platform} ARCH=aarch64 GUEST_LOAD_ADDRESS=0x40000000
                """
            ]
            try:
                result = subprocess.run(command, check=True)
                # print(result.stdout.decode())
            except subprocess.CalledProcessError as e:
                print(f"Error occurred: {e.stderr.decode()}")
    
        elif self.rebuild_initrd:
            rootfs_dir = self.profiler_dir + "/rootfs_overlay/"
            self.create_profiler_runtime_script(rootfs_dir)

            command = [
                "bash", "-c",
                f"""
                    make -C {self.profiler_dir} rebuild_initramfs PLATFORM={platform} ARCH=aarch64 GUEST_LOAD_ADDRESS=0x40000000
                """
            ]
            try:
                result = subprocess.run(
                    command, 
                    check=True, 
                    # stdout=subprocess.PIPE, 
                    # stderr=subprocess.PIPE, 
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    shell=False, 
                    env=os.environ.copy()
                )
                # print(result.stdout.decode())
            except subprocess.CalledProcessError as e:
                pass
        
        linux_img = f"{self.profiler_dir}/wrkdir/linux.bin"
        if not os.path.exists(linux_img):
            print(f"Error: {linux_img} does not exist.")
            return
        
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        dest_file = os.path.join(out_dir, 'profiler.bin')
        shutil.copyfile(linux_img, dest_file)

def build_eth_logger(root_dir):
    command = [
        "bash", "-c",
        f"""
            make -C {root_dir}/setup_generator/profiler_logger/ clean CROSS_COMPILE=""
            make -C {root_dir}/setup_generator/profiler_logger/ server CROSS_COMPILE=""
        """
    ]
    try:
        result = subprocess.run(
            command, 
            check=True, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.PIPE, 
            # stdout=subprocess.DEVNULL,
            # stderr=subprocess.DEVNULL,
            shell=False, 
            env=os.environ.copy()
        )
        # print(result.stdout.decode())
    except subprocess.CalledProcessError as e:
        print(f"Error occurred: {e.stderr.decode()}")

def launch_eth_logger(root_dir, packet_size, output_file, num_cpus):
    command = [
        "bash", "-c",
        f"{root_dir}/setup_generator/profiler_logger/build/server.out {packet_size} {output_file} 0 {num_cpus}"
    ]

    print("command: ", command)

    # if output_file directory does not exist, create it
    output_dir = os.path.dirname(output_file)
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    try:
        process = subprocess.Popen(command, env=os.environ)
        import time
        time.sleep(3)
        if process.poll() is not None:
            print("eth_logger failed to start.")

            return None
        return process
    except Exception as e:
        print(f"Failed to launch eth_logger: {e}")
        return None
