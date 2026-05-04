import math
import os
import shutil
import subprocess
import re

def replace_config(config, confif_sector, new_config):
    file_content = config.replace(confif_sector, new_config)
    return file_content

def find_sector(content, pattern):
    sect = pattern.findall(content)
    return sect


class linux_guests:
    def __init__(self):
        self.linux_dir = ""
        self.build_guest = False
        self.rebuild_initrd = False
        self.performance_monitor_en = False
        self.performance_monitor_events = []
        self.performance_monitor_period_us = []
        self.list_guests = []
        self.list_variants = []
        self.list_boot_commands = []


    # create a function that returns all the possible configurations
    def get_configurations(self):

        total_num_guests = 1

        num_cpus = len(self.cpu_IDs)
        self.list_guests.append({
            "linux_dir" : self.linux_dir,
            "build_guest" : self.build_guest,
            "num_cpus" : num_cpus,
            "cpu_IDs" : self.cpu_IDs[0]
        })

        if len(self.list_boot_commands) > 0:
            for i in range(0, len(self.list_guests)):
                for j in range(0, len(self.list_boot_commands)):
                    self.list_guests.append({
                        "linux_dir" : self.linux_dir,
                        "build_guest" : self.build_guest,
                        "boot_commands" : self.list_boot_commands[j][1:],
                        "workload_name" : self.list_boot_commands[j][0],
                        "num_cpus" : num_cpus,
                        "cpu_IDs" : self.cpu_IDs[0]
                    })

                self.list_guests.pop(i)

    def read_config(self, linux_config):
        self.linux_dir = os.path.abspath(linux_config.get("linux_dir", ""))
        self.build_guest = linux_config.get("build_guest", False)
        self.rebuild_initrd = linux_config.get("rebuild_initrd", False)
        self.list_boot_commands = linux_config.get("boot_commands", [])
        self.num_cpus = linux_config.get("num_cpus", 1)
        self.cpu_IDs = linux_config.get("cpu_IDs", [[0]])

    def create_guest_runtime_script(self, guest, out_dir):
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        # check if "boot_commands" is in the guest dictionary
        if "boot_commands" in guest:
            # write the boot commands to a file
            boot_commands_file = os.path.join(out_dir, "run_benchmark.sh")

            if isinstance(guest["boot_commands"], list):
                guest["boot_commands"] = "; ".join(guest["boot_commands"])

            with open(boot_commands_file, "w") as f:
                f.write("sleep 0.5\n")
                f.write("echo \"[START] Profilling Started\"\n")
                f.write(f"{guest['boot_commands']}\n")
                f.write("echo \"[END] Profiling Completed\"\n")
                
    def generate_guest_config_files(self, benchmark, template_file, hw_obj=None):
        template_file_content = ""
        dict_guest_config = {}
        with open(template_file, "r") as f:
            template_file_content = f.read()

        for guest in self.list_guests:
            guest_config_file = template_file_content
            guest_image_name = "linux_" + guest["workload_name"]
            guest_config_name = guest_image_name
            
            guest_image_name_pattern = re.compile(r"#linux_name#\s*")
            guest_image_sect = find_sector(guest_config_file, guest_image_name_pattern)
            new_file_content = replace_config(guest_config_file, guest_image_sect[0], f"{benchmark}/{guest_image_name}")

            cpu_affinity_pattern = re.compile(r"#linux_cpu_affinity_config#\n")
            cpu_affinity_sect = find_sector(new_file_content, cpu_affinity_pattern)
            new_file_content = replace_config(new_file_content, cpu_affinity_sect[0], f".cpu_affinity = 0x{guest['cpu_IDs'][0]:X},\n")

            cpu_num_pattern = re.compile(r"#linux_cpu_num_config#\n")
            cpu_num_sect = find_sector(new_file_content, cpu_num_pattern)
            new_file_content = replace_config(new_file_content, cpu_num_sect[0], f".cpu_num = {guest['num_cpus']},\n")

            dict_guest_config[guest_config_name] = new_file_content

        return dict_guest_config


    def build_guests(self, out_dir, platform):
        command = []
        for guest in self.list_guests:
            if self.build_guest:
                command = [
                    "bash", "-c",
                    f"""
                        make -C {self.linux_dir} PLATFORM={platform} ARCH=aarch64 GUEST_LOAD_ADDRESS=0x40000000
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
        
            elif self.rebuild_initrd:
                script_out_dir = guest["linux_dir"] + "/rootfs_overlay/etc/profile.d"
                self.create_guest_runtime_script(guest, script_out_dir)
                command = [
                    "bash", "-c",
                    f"""
                        make -C {self.linux_dir} rebuild_initramfs PLATFORM={platform} ARCH=aarch64 GUEST_LOAD_ADDRESS=0x40000000
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
                        shell=False
                    )
                    # print(result.stdout.decode())
                except subprocess.CalledProcessError as e:
                    pass
            
            linux_img = f"{self.linux_dir}/wrkdir/linux.bin"
            if not os.path.exists(linux_img):
                print(f"Error: {linux_img} does not exist.")
                return
            
            if not os.path.exists(out_dir):
                os.makedirs(out_dir)

            out_filename = "linux_" + guest["workload_name"] + ".bin"
            dest_file = os.path.join(out_dir, out_filename)
            shutil.copyfile(linux_img, dest_file)