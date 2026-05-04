import os
import sys
import subprocess

arch_path = os.path.abspath('./setup_generator/arch/aarch64')
print(arch_path)
sys.path.append(arch_path)

from pmuv3 import pmu

class test_platform_zcu104:
    def __init__(self, root_dir):
        self.platform_name = "zcu104"
        self.num_pmu_counters = 6
        self.num_cache_colors = 8
        self.master_interface = "/dev/ttyUSB1"
        log_ports = {}
        self.pmu = pmu()
        self.platform_launch_cfgs = {
            "tcl_script" : f"{root_dir}/setup_generator/platforms/zcu104/scripts/reset_zcu104.tcl",
            "firmware_path" : f"{root_dir}/setup_generator/platforms/zcu104/firmware",
            "bitstream" : "",
        }

    def launch_test(self, bao_img):
        # sudo copy bao_img to /tftpboot
        command = [
            "sudo", "cp", bao_img, "/var/lib/tftpboot/bao.img"
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
            print(f"Error occurred: {e.stderr.decode()}")

        command = [
        "bash", "-c",
        f"""
        export TCL_FILE={self.platform_launch_cfgs["tcl_script"]} && \
        export FW_PATH={self.platform_launch_cfgs["firmware_path"]} && \
        export BITSTREAM={self.platform_launch_cfgs["bitstream"]} && \
        xsct $TCL_FILE $FW_PATH $BITSTREAM
        """
    ]
        try:
            result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
            # print(result.stdout.decode())
        except subprocess.CalledProcessError as e:
            print(f"Error occurred: {e.stderr.decode()}")

    def read_hardware_config(self, config):
        bitstream = config.get("bitstream", "")
        self.platform_launch_cfgs["bitstream"] = bitstream if bitstream is not None else ""
