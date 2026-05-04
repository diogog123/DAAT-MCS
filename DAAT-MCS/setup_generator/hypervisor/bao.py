import subprocess


class bao:
    def __init__(self, bao_dir, root_dir):
        self.hypervisor_name = "bao"
        self.bao_dir = bao_dir
        self.root_dir = root_dir
        self.list_artifacts = ["bao_img"]


    def build_hypervisor(self, config_dir, config_name, imgs_dir, out_dir, platform, include_profiling_vm=False):
        
        config_profiler = "y" if include_profiling_vm else "n"
        command = [ 
            "bash", "-c", 
            f"""
                make -C {self.bao_dir} \
                PLATFORM={platform} \
                CONFIG={config_name} \
                clean && \
                make -C {self.bao_dir} \
                PLATFORM={platform} \
                CONFIG_REPO={config_dir} \
                CONFIG={config_name} \
                CONFIG_PROFILER={config_profiler} \
                CPPFLAGS=-DBAO_WRKDIR_IMGS={imgs_dir}/guests && \
                if [ ! -d {out_dir} ]; then \
                    mkdir -p {out_dir}; \
                fi && \
                mkimage -n bao_uboot -A arm64 -O linux -C none -T kernel -a 0x200000 -e 0x200000 \
                    -d {self.bao_dir}/bin/{platform}/{config_name}/bao.bin {out_dir}/{config_name}.img
            """
        ]
        try:
            result = subprocess.run(
                command, 
                check=True, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.PIPE, 
                shell=False, 
            )
            # print(result.stdout.decode())
            self.clean_hypervisor()
        except subprocess.CalledProcessError as e:
            print(f"Error occurred: {e.stderr.decode()}")

    def clean_hypervisor(self):
        command = [
            "bash", "-c",
            f"""
                make -C {self.bao_dir} clean
            """
        ]
        try:
            result = subprocess.run(
                command, 
                check=True, 
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                shell=False, 
            )
            # print(result.stdout.decode())
        except subprocess.CalledProcessError as e:
            print(f"Error occurred: {e.stderr.decode()}")
