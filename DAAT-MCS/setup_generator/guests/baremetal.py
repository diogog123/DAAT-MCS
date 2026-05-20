import math
import subprocess
import re
import os
import shutil

def find_sector(content, pattern):
    sect = pattern.findall(content)
    return sect

def replace_config(config, confif_sector, new_config):
    file_content = config.replace(confif_sector, new_config)
    return file_content


class baremetal_guests:
    def __init__(self):
        self.src_dir = ""
        self.num_cpus = []
        self.list_guests = []
        self.cpu_IDs = []
        self.mode = "constant"

    def read_config(self, baremetal_config):
        self.src_dir = baremetal_config.get("src_dir", "")
        self.num_cpus = baremetal_config.get("num_cpus", [])
        self.cpu_IDs = baremetal_config.get("cpu_IDs", [])

        self.num_cpus = [len(cpu_list) for cpu_list in self.cpu_IDs]
        self.mode = baremetal_config.get("mode", "constant")

    def genertate_config_file_content(self, guest_config_file, config_name, image_name, benchmark, cpu_affinity, num_cpus):
        guest_image_name_pattern = re.compile(r"#baremetal_name#\s*")
        guest_image_sect = find_sector(guest_config_file, guest_image_name_pattern)
        new_file_content = replace_config(guest_config_file, guest_image_sect[0], f"{benchmark}/{config_name}")

        guest_image_pattern = re.compile(r"#baremetal_image_name#\s*")
        guest_image_sect = find_sector(new_file_content, guest_image_pattern)
        for name in guest_image_sect:
            if name in new_file_content:
                new_file_content = replace_config(new_file_content, name, f"{image_name}")

        cpu_affinity_pattern = re.compile(r"#baremetal_cpu_affinity_config#\n")
        cpu_affinity_sect = find_sector(new_file_content, cpu_affinity_pattern)
        new_file_content = replace_config(new_file_content, cpu_affinity_sect[0], f".cpu_affinity = 0x{cpu_affinity:X},\n")
        
        num_cpus_pattern = re.compile(r"#baremetal_cpu_num_config#\n")
        num_cpus_sect = find_sector(new_file_content, num_cpus_pattern)
        new_file_content = replace_config(new_file_content, num_cpus_sect[0], f".cpu_num = {num_cpus},\n")

        return new_file_content



class baremetal_cache_guests(baremetal_guests):
    def __init__(self):
        super().__init__() 

        self.cache_line_size = 0
        self.interference_buffer_size = []
        self.read_write_operation = ""
        self.target_resource = "cache"        

    def get_configurations(self):
        for ibs in self.interference_buffer_size:
            for cpus in self.num_cpus:
                cpu_IDs = self.cpu_IDs[self.num_cpus.index(cpus)]
                for rw in self.read_write_operation:
                    self.list_guests.append({
                        "src_dir" : self.src_dir,
                        "cache_line_size" : self.cache_line_size,
                        "interference_buffer_size" : ibs,
                        "num_cpus" : cpus,
                        "cpu_IDs" : cpu_IDs,
                        "read_write_operation" : rw,
                    })

    def read_config(self, baremetal_cache_config):
        super().read_config(baremetal_cache_config)

        self.cache_line_size = baremetal_cache_config.get("cache_line_size", 0)
        self.interference_buffer_size = baremetal_cache_config.get("interference_buffer_size", [])
        self.read_write_operation = baremetal_cache_config.get("read_write_operation", "")


    def build_guests(self, out_dir, platform):
        bytes_converter = {
            'M': 1024 ** 2,  # Megabytes
            'K': 1024,       # Kilobytes
        }

        for guest in self.list_guests:
            num_cpus = guest["num_cpus"]
            ibs = guest["interference_buffer_size"]
            ibs_bytes = int(ibs[:-1]) * bytes_converter[ibs[-1]]
            workload = hex(ibs_bytes)
            cache_line_size = guest["cache_line_size"]
            en_read = 1 if "read" in guest["read_write_operation"] else 0
            en_write = 1 if "write" in guest["read_write_operation"] else 0
            en_ivac = 1 if "ivac" in guest["read_write_operation"] else 0
            en_civac = 1 if "civac" in guest["read_write_operation"] else 0

            c_file_path = f"{guest['src_dir']}/src/baremetal-app/cache_stressor/{self.mode}/main.c"
            with open(c_file_path, "r") as f:
                file_content = f.read()

            file_content = re.sub(
                        r"#define\s+CACHE_LINE_SIZE\s+\d+",
                        f"#define CACHE_LINE_SIZE     {cache_line_size}",
                        file_content
                    )
            file_content = re.sub(
                        r"#define\s+NUM_CPUS\s+\d+",
                        f"#define NUM_CPUS            {num_cpus}",
                        file_content
                    )
            file_content = re.sub(
                        r"#define\s+INTERF_BUF_SIZE\s+0x[0-9a-fA-F]+",
                        f"#define INTERF_BUF_SIZE     {workload}",
                        file_content
                    )
            file_content = re.sub(
                        r"#define\s+ENABLE_READS\s+\d+",
                        f"#define ENABLE_READS        {en_read}",
                        file_content
                    )
            file_content = re.sub(
                        r"#define\s+ENABLE_WRITES\s+\d+",
                        f"#define ENABLE_WRITES       {en_write}",
                        file_content
                    )

            file_content = re.sub(
                        r"#define\s+IVAC_CACHE\s+\d+",
                        f"#define IVAC_CACHE        {en_ivac}",
                        file_content
            )

            file_content = re.sub(
                        r"#define\s+CIVAC_CACHE\s+\d+",
                        f"#define CIVAC_CACHE        {en_civac}",
                        file_content
            )

            with open(c_file_path, "w") as f:
                f.write(file_content)
            
            rw_operation = ""
            if en_read: rw_operation += "r"
            if en_write: rw_operation += "w"
            if en_ivac: rw_operation += "i"
            if en_civac: rw_operation += "c"

            bare_name = f"baremetal_cache_{rw_operation}-C{num_cpus}-W{ibs}"
            bare_app = f"APP=cache_stressor WORKLOAD={self.mode}"
            command = [
                "bash", "-c",
                f"""
                    make -C {guest['src_dir']} NAME={bare_name} PLATFORM={platform} {bare_app}
                """
            ]

            try:
                result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
                # print(result.stdout.decode())
            except subprocess.CalledProcessError as e:
                pass


            if not os.path.exists(out_dir):
                os.makedirs(out_dir)
            
            out_file = f"{guest['src_dir']}/build/{platform}/cache_stressor/{self.mode}/{bare_name}.bin"
            dest_file = os.path.join(out_dir, f"{bare_name}.bin")
            shutil.copyfile(out_file, dest_file)


    def generate_guest_config_files(self, benchmark, template_file, hw_obj=None):
        template_file_content = ""
        dict_guest_config = {}
        with open(template_file, "r") as f:
            template_file_content = f.read()
        
        for guest in self.list_guests:
            guest_config_file = template_file_content
            cpu_IDs = guest["cpu_IDs"]
            num_cpus = len(cpu_IDs)
            cpu_affinity = 0
            for cpu in cpu_IDs:
                cpu_affinity |= (1 << cpu)
                
            ibs = guest["interference_buffer_size"]

            if "read" in guest["read_write_operation"]:
                en_read = 1
                rw_operation = "r"
            if "write" in guest["read_write_operation"]:
                en_write = 1
                rw_operation = "w"
            if "ivac" in guest["read_write_operation"]:
                en_ivac = 1
                rw_operation = "i"
            if "civac" in guest["read_write_operation"]:
                en_civac = 1
                rw_operation = "c"
        
            config_name = f"baremetal_cache_{rw_operation}-C{num_cpus}-W{ibs}"
            image_name = "baremetal_cache"
                        

            new_file_content = self.genertate_config_file_content(guest_config_file, config_name, image_name, benchmark, cpu_affinity, num_cpus)
            dict_guest_config[config_name] = new_file_content
            

        return dict_guest_config

class baremetal_embench_guests(baremetal_guests):
    def __init__(self):
        super().__init__()

    def read_config(self, baremetal_embench_config):
        super().read_config(baremetal_embench_config)
        self.list_benchmarks = baremetal_embench_config.get("benchmarks", [])
    
    def get_configurations(self):
        total_guests = len(self.list_benchmarks)
        for i in range(0, total_guests):
            num_cpus = len(self.cpu_IDs)
            self.list_guests.append({
                "src_dir" : self.src_dir,
                "benchmark" : self.list_benchmarks[i],
                "num_cpus" : num_cpus,
                "cpu_IDs" : self.cpu_IDs[0]
            })
    
    def build_guests(self, out_dir, platform):

        for guest in self.list_guests:
            benchmark = guest["benchmark"]
            bare_name = f"baremetal_embench_{benchmark}-C{guest['num_cpus']}"
            command = [
                "bash", "-c",
                f"""
                    make -C {guest['src_dir']} NAME={bare_name} PLATFORM={platform} BENCH={benchmark}
                """
            ]

            try:
                result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=False)
                # print(result.stdout.decode())
            except subprocess.CalledProcessError as e:
                pass


            if not os.path.exists(out_dir):
                os.makedirs(out_dir)
            
            out_file = f"{guest['src_dir']}/build/{platform}/{bare_name}.bin"
            dest_file = os.path.join(out_dir, f"{bare_name}.bin")
            shutil.copyfile(out_file, dest_file)

    def generate_guest_config_files(self, benchmark, template_file, hw_obj=None):
        template_file_content = ""
        dict_guest_config = {}
        with open(template_file, "r") as f:
            template_file_content = f.read()
        
        for guest in self.list_guests:
            guest_config_file = template_file_content
            # num_cpus = guest["num_cpus"]
            cpu_IDs = guest["cpu_IDs"]
            num_cpus = len(cpu_IDs)
            cpu_affinity = 0
            for cpu in cpu_IDs:
                cpu_affinity |= (1 << cpu)
            
            config_name = f"{guest['src_dir'].split('/')[-1]}_{guest['benchmark']}-C{num_cpus}"
            image_name = f"{guest['src_dir'].split('/')[-1]}"
            # get object class name

            new_file_content = self.genertate_config_file_content(guest_config_file, config_name, image_name, benchmark, cpu_affinity, num_cpus)
            dict_guest_config[config_name] = new_file_content
            

        return dict_guest_config
    
class baremetal_cci_guests(baremetal_guests):
    def __init__(self):
        super().__init__()
        self.ila_config = {}
        self.ila_configurations = []

    def read_config(self, baremetal_cci_config):
        super().read_config(baremetal_cci_config)
        self.ila_config = baremetal_cci_config.get("ila", {})

    def get_configurations(self):
        snoop_types  = self.ila_config.get("snoop_types", [1])
        channels     = self.ila_config.get("channels", [])
        test_types   = self.ila_config.get("test_types", ["TEST_TYPE_SOLO"])
        coherency    = self.ila_config.get("coherency", [0])

        cpu_ids_solo = self.cpu_IDs[0]
        cpu_ids_dma  = self.cpu_IDs[1]

        for tt in test_types:
            for snoop in snoop_types:
                for coh in coherency:
                    cpu_ids = cpu_ids_solo if tt == "TEST_TYPE_SOLO" else cpu_ids_dma
                    if tt == "TEST_TYPE_SOLO":
                        self.ila_configurations.append({
                            "test_type"  : tt,
                            "snoop_type" : snoop,
                            "channels"   : 0,
                            "coherency"  : coh,
                            "cpu_IDs"    : cpu_ids,
                        })
                    else:
                        for ch in channels:
                            self.ila_configurations.append({
                                "test_type"  : tt,
                                "snoop_type" : snoop,
                                "channels"   : ch,
                                "coherency"  : coh,
                                "cpu_IDs"    : cpu_ids,
                            })

    def build_guests(self, out_dir, platform):
        for ila_cfg in self.ila_configurations:
            snoop_type = ila_cfg["snoop_type"]
            channels   = ila_cfg["channels"]
            test_type  = ila_cfg["test_type"]
            coherency  = ila_cfg["coherency"]
            cpu_IDs    = ila_cfg["cpu_IDs"]
            num_cpus   = len(cpu_IDs)

            c_file_path = f"{self.src_dir}/src/main.c"
            with open(c_file_path, "r") as f:
                file_content = f.read()

            file_content = re.sub(
                r"#define\s+TEST_TYPE\s+\w+",
                f"#define TEST_TYPE     {test_type}",
                file_content
            )
            file_content = re.sub(
                r"#define\s+SNOOP_TYPE\s+\d+",
                f"#define SNOOP_TYPE    {snoop_type}",
                file_content
            )
            file_content = re.sub(
                r"#define\s+DMA_CHANNELS\s+\d+",
                f"#define DMA_CHANNELS  {channels}",
                file_content
            )
            file_content = re.sub(
                r"#define\s+COHERENCY\s+\d+",
                f"#define COHERENCY     {coherency}",
                file_content
            )
            file_content = re.sub(
                r"#define\s+NUM_CPUS\s+\d+",
                f"#define NUM_CPUS      {num_cpus}",
                file_content
            )

            with open(c_file_path, "w") as f:
                f.write(file_content)

            bare_name = f"baremetal_cci_{test_type}_snoop{snoop_type}_ch{channels}_coh{coherency}_C{num_cpus}"
            command = [
                "bash", "-c",
                f"make -C {self.src_dir} NAME={bare_name} PLATFORM={platform}"
            ]
            try:
                subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            except subprocess.CalledProcessError as e:
                print(f"Build failed for {bare_name}: {e.stderr.decode()}")
                continue

            if not os.path.exists(out_dir):
                os.makedirs(out_dir)

            shutil.copyfile(
                f"{self.src_dir}/build/{platform}/{bare_name}.bin",
                f"{out_dir}/{bare_name}.bin"
            )

    def generate_guest_config_files(self, benchmark, template_file, hw_obj=None):
        template_file_content = ""
        dict_guest_config = {}
        with open(template_file, "r") as f:
            template_file_content = f.read()

        for ila_cfg in self.ila_configurations:
            guest_config_file = template_file_content
            cpu_IDs    = ila_cfg["cpu_IDs"]
            num_cpus   = len(cpu_IDs)
            snoop_type = ila_cfg["snoop_type"]
            channels   = ila_cfg["channels"]
            test_type  = ila_cfg["test_type"]
            coherency  = ila_cfg["coherency"]

            cpu_affinity = 0
            for cpu in cpu_IDs:
                cpu_affinity |= (1 << cpu)

            config_name = f"baremetal_cci_{test_type}_snoop{snoop_type}_ch{channels}_coh{coherency}_C{num_cpus}"
            image_name  = config_name

            new_file_content = self.genertate_config_file_content(
                guest_config_file, config_name, image_name, benchmark, cpu_affinity, num_cpus
            )
            dict_guest_config[config_name] = new_file_content
        print("ola")
        print(dict_guest_config)
        return dict_guest_config