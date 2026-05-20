import yaml
import math
import subprocess
import os
import shutil
from itertools import combinations
import sys
import re
import itertools
from itertools import product
from PyP100 import PyP110
import time

hypervisor_path = os.path.abspath('./setup_generator/hypervisor')
print(hypervisor_path)
sys.path.append(hypervisor_path)

from bao import bao


def write_config(filename, content):
    with open(filename, "w") as f:
        f.write(content)

def replace_config(config, confif_sector, new_config):
    file_content = config.replace(confif_sector, new_config)
    return file_content

def find_sector(content, pattern):
    sect = pattern.findall(content)
    return sect

class test_engine:
    def __init__(self):
        self.configs_dir = ""
        self.configs_templates = ""
        self.root_dir = ""
        self.hypervisor = ""
        self.hypervisor_dir = ""
        self.imgs_dir = ""
        self.benchmark = ""
        self.list_setups = []
        self.list_configs = []
        self.num_runs = 0
        self.setups_configs = []
        self.hardware_control_en = False
        self.hardware_control_cfg = {   # used to control tapo p110 smart plug
            "device_ip": "",
            "email": "",
            "password": ""
        }

    def read_config(self, paths, setups, setups_configs, hypervisor_configs, hw_controller=None):
        self.configs_dir = paths.get("configs_dir", "")
        self.configs_templates = paths.get("config_templates", "")
        self.root_dir = os.path.abspath(paths.get("root_dir", ""))
        self.imgs_dir = os.path.abspath(paths.get("imgs_dir", ""))

        self.hypervisor = hypervisor_configs.get("name", "")
        self.hypervisor_dir = os.path.abspath(hypervisor_configs.get("src_dir", ""))

        self.benchmark = setups.get("benchmark", "")
        self.list_setups = setups.get("list_setups", {})

        for setup in setups_configs:
            setup_name = setup
            setup_guests = setups_configs[setup]["guests"]

            if "en_cache_coloring" in setups_configs[setup]:
                setup_cc = setups_configs[setup]["en_cache_coloring"]
            else:
                setup_cc = False

            if "lc_cache_coloring" in setups_configs[setup]:
                setup_cc_list = setups_configs[setup]["lc_cache_coloring"]
            else:
                setup_cc_list = []

            if "mem_bw_config" in setups_configs[setup]:
                setup_mbr = setups_configs[setup]["mem_bw_config"]
                print(f"MBR config for setup {setup}: {setup_mbr}")
            else:
                setup_mbr = {}

            log_ports = setups_configs[setup]["log_ports"]

            self.setups_configs.append({
                "setup" : setup_name,
                "guests" : setup_guests,
                "cache_coloring" : setup_cc,
                "cache_coloring_list" : setup_cc_list,
                "setup_mbr" : setup_mbr,
                "log_ports" : log_ports
            })

            self.hardware_control_cfg["device_ip"] = hw_controller.get("device_ip", "")
            self.hardware_control_cfg["email"] = hw_controller.get("email", "")
            self.hardware_control_cfg["password"] = hw_controller.get("password", "")

            # if all three fields are all filled, hardware_control is enabled
            if all(self.hardware_control_cfg.values()):
                self.hardware_control_en = True

    def get_setup_list_of_guests(self, setup_name):
        for setup in self.setups_configs:
            if setup["setup"] == setup_name:
                return setup["guests"]
        return []
    
    def generate_profiler_variant(self, events, period_sampling, num_target_cpus, store_buffer_size, num_store_buffers, pmu):
        # calculate the number of events sets
        events_codes = []

        for event in events:
            if event not in pmu.events_list:
                print(f"Event {event} not found")
                continue
            else:
                event_val = pmu.events_list[event]
                events_codes.append(event_val)
            
        guest_profiler = [
            ".non_evasive_profiler = {",
            f"\t\t\t\t.num_target_cpus = {num_target_cpus},",
            f"\t\t\t\t.num_profile_events = {len(events)},",
            f"\t\t\t\t.list_events = (size_t[]){events_codes},",
            f"\t\t\t\t.sampling_period_us = {period_sampling},",
            f"\t\t\t\t.store_buffer_size = {store_buffer_size},",
            f"\t\t\t\t.num_store_buffers = {num_store_buffers},",
            "\t\t\t},\n\t"
        ]
        guest_profiler = [x.replace(")[", "){").replace("],", "},") for x in guest_profiler]
        return guest_profiler
    
    def generate_cache_colors_assignment(self, num_bits, num_vms, min_colors_per_vm=2):
        colors_assignments = []

        # Candidate split points inside (1 .. num_bits-1)
        candidate_points = range(1, num_bits)

        for bits in combinations(candidate_points, num_vms - 1):
            # Add start=0 and end=num_bits to delimit segments fully
            points = (0,) + bits + (num_bits,)

            # Check that all segment lengths >= min_colors_per_vm
            if all(points[i+1] - points[i] >= min_colors_per_vm for i in range(num_vms)):
                masks = []
                for i in range(num_vms):
                    start = points[i]
                    end = points[i+1]
                    length = end - start
                    mask = (1 << length) - 1
                    masks.append(hex(mask << start))
                colors_assignments.append(masks)

        return colors_assignments
    
    def generate_mbr_assignments(self, mbr_configuration):
        guests_variants = []
        guests_name = []

        def normalize_to_list(value):
            if value is None:
                return []
            if isinstance(value, list):
                return value
            return [value]
        
        for guest, guest_config in mbr_configuration.items():
            if not guest_config.get("enabled", True):
                continue

            guest_variants = {}
            guest_budgets = normalize_to_list(
                guest_config.get("budget", guest_config.get("lc_budgets", []))
            )
            guest_periods = normalize_to_list(
                guest_config.get("period_us", guest_config.get("lc_period_us", []))
            )

            if not guest_budgets or not guest_periods:
                continue

            guests_name.append(guest)
            
            for budget in guest_budgets:
                for period in guest_periods:
                    # Store each variant as a dictionary with both budget and period data
                    guest_variants[f"B{budget}_P{period}"] = {
                        "budget": budget,
                        "period": period,
                    }
                    print(f"Generated MBR variant for {guest}: Budget={budget}, Period={period}")
            guests_variants.append(list(guest_variants.values()))  # Add just the values to list

        if not guests_variants:
            return []

        # Generate all possible combinations of guest variants
        mbr_variants = []
        for combination in product(*guests_variants):
            combined_variant = {}
            for i, variant in enumerate(combination):
                combined_variant[guests_name[i]] = variant
            mbr_variants.append(combined_variant)

        return mbr_variants
            
    def get_cache_colors_configurations(self, list_cache_colors, num_cache_colors):
        list_cache_col_variants = []
        list_cache_col_percentage = []
        for cache_color in list_cache_colors:
            system_cc_config = []
            system_cc_percentage = []
            for i, vm_colors in enumerate(cache_color):
                system_cc_config.append(f".colors = {vm_colors},\n")
                system_cc_percentage.append(f"{bin(int(cache_color[i], 16)).count('1')}-{num_cache_colors}")
            list_cache_col_variants.append(system_cc_config)
            list_cache_col_percentage.append(system_cc_percentage)
        
        return list_cache_col_variants, list_cache_col_percentage
    
    def generate_mbr_variant(self, mbr_config):
        period = mbr_config["period"]
        budget = mbr_config["budget"]
        mbr_variant = [
            ".mem_throth = {",
            f"\t\t\t\t.budget = {budget},",
            f"\t\t\t\t.period_us = {period},",
            f"\t\t\t}},\n\t"
        ]
        return mbr_variant
    
    def get_mbr_configurations(self, list_mbr_configs):
        list_configs = []
        list_names = []
        for mbr_config in list_mbr_configs:
            list_mbr_variants = []
            config_name = ""
            for guest in mbr_config:
                mbr_variant = self.generate_mbr_variant(mbr_config[guest])
                list_mbr_variants.append(mbr_variant)
                config_name += f"B{mbr_config[guest]['budget']}_P{mbr_config[guest]['period']}_"
            config_name = config_name[:-1]

            list_configs.append(list_mbr_variants)
            list_names.append(config_name)
        return list_configs, list_names
    
    def read_file(self, file):
        with open(file, "r") as f:
            file_content = f.read()
        return file_content

    def generate_num_cpus_code(self, file_content, num_cpus, num_cpus_pattern):
        num_cpus_sect = find_sector(file_content, num_cpus_pattern)
        new_file_content = replace_config(file_content, num_cpus_sect[0], f".cpu_num = {num_cpus},\n")
        return new_file_content
    
    def generate_cache_colors_code(self, file_content, filename, list_cc_config_pattern, list_cache_colors, hw_num_cache_colors):
        """
        Generates config files by replacing *all* occurrences of each cache coloring pattern
        with the corresponding color config from each variant in list_cache_colors.
        
        Arguments:
        - file_content: the base config string with placeholders
        - filename: base filename for generated configs
        - list_cc_config_pattern: list of compiled regex patterns (unique coloring placeholders)
        - list_cache_colors: list of variants, each a list of colors (strings) per VM instance,
        where VM instances are ordered and mapped to pattern occurrences across the file
        - hw_num_cache_colors: hardware parameter, included in filenames
        
        Returns:
        - list of generated config strings
        - list of config filenames
        """
        num_patterns = len(list_cc_config_pattern)
        list_new_configs = []
        list_config_names = []

        # Helper: find all substring occurrences matching a pattern
        def find_all_sectors(content, pattern):
            return [m.span() for m in pattern.finditer(content)]

        if len(list_cache_colors) == 0:
            # No coloring: just remove all occurrences replacing with newline
            new_file_content = file_content
            for pattern in list_cc_config_pattern:
                sectors = find_all_sectors(new_file_content, pattern)
                for sector in reversed(sectors):
                    start, end = sector
                    new_file_content = new_file_content[:start] + "\n" + new_file_content[end:]
            list_new_configs.append(new_file_content)
            list_config_names.append(filename)
            return list_new_configs, list_config_names

        # For each cache coloring variant
        for variant_idx, variant_colors in enumerate(list_cache_colors):
            new_file_content = file_content
            replaced_counts = [0]*num_patterns  # Count replacements per pattern

            for pattern_idx, pattern in enumerate(list_cc_config_pattern):
                sectors = find_all_sectors(new_file_content, pattern)
                for occ_idx, sector in reversed(list(enumerate(sectors))):
                    # Compute the overall VM instance index (across patterns)
                    vm_instance_idx = sum(replaced_counts[:pattern_idx]) + occ_idx
                    if vm_instance_idx >= len(variant_colors):
                        # No color assigned for this instance in this variant; skip
                        continue
                    color_value = variant_colors[vm_instance_idx]
                    color_config_str = f".colors = {color_value},\n"
                    start, end = sector
                    new_file_content = new_file_content[:start] + color_config_str + new_file_content[end:]
                    replaced_counts[pattern_idx] += 1

            # Filename encoding colors for traceability (optional)
            def count_ones_in_hex(hex_str):
                # Convert hex string (e.g., '0x3f') to int and count bits set to 1
                return bin(int(hex_str, 16)).count('1')

            color_counts = [str(count_ones_in_hex(c)) for c in variant_colors]
            color_id_str = "_".join(color_counts)

            # color_id_str = "_".join([c for c in variant_colors]).replace("0x", "x")  # e.g., "x1_x2_xfc"
            final_name = f"{filename}_cc_{color_id_str}-{hw_num_cache_colors}"
            list_new_configs.append(new_file_content)
            list_config_names.append(final_name)

        return list_new_configs, list_config_names
    
    def generate_mbr_code(self, file_content, filename, list_mbr_config_pattern, list_mbr_configs):
        """
        Similar to generate_cache_colors_code but for memory bandwidth restriction (MBR).
        Replaces all occurrences of each MBR pattern with the corresponding MBR config per variant.

        list_mbr_configs supports:
        - legacy format: list of MBR line lists per VM instance
        - keyed format: dict of guest_name -> {"budget": X, "period": Y}
        """
        list_new_configs = []
        list_config_names = []

        def find_all_sectors(content, pattern):
            return [m.span() for m in pattern.finditer(content)]

        def get_pattern_guest_hint(pattern):
            match = re.search(r"#([a-zA-Z0-9]+)_mem_br_config#", pattern.pattern)
            if match:
                return match.group(1).lower()
            return ""

        def to_mbr_lines(mbr_config):
            if isinstance(mbr_config, list):
                return mbr_config

            if not isinstance(mbr_config, dict):
                return []

            budget = mbr_config.get("budget")
            period = mbr_config.get("period", mbr_config.get("period_us"))
            if budget is None or period is None:
                return []

            return self.generate_mbr_variant({"budget": budget, "period": period})

        def sanitize_name(value):
            safe_val = re.sub(r"[^A-Za-z0-9_.-]+", "_", value).strip("_")
            return safe_val if safe_val else "none"

        if len(list_mbr_configs) == 0:
            # No MBR configs: remove all placeholders cleanly
            new_file_content = file_content
            for pattern in list_mbr_config_pattern:
                sectors = find_all_sectors(new_file_content, pattern)
                for sector in reversed(sectors):
                    start, end = sector
                    new_file_content = new_file_content[:start] + "\n" + new_file_content[end:]
            list_new_configs.append(new_file_content)
            list_config_names.append(filename)
            return list_new_configs, list_config_names

        for variant_idx, variant_mbr in enumerate(list_mbr_configs):
            new_file_content = file_content
            variant_name_parts = []

            if isinstance(variant_mbr, dict):
                guest_line_variants = []
                for guest_name, guest_config in variant_mbr.items():
                    mbr_lines = to_mbr_lines(guest_config)
                    if not mbr_lines:
                        continue

                    guest_line_variants.append((guest_name, mbr_lines))

                    if isinstance(guest_config, dict):
                        budget = guest_config.get("budget")
                        period = guest_config.get("period", guest_config.get("period_us"))
                        if budget is not None and period is not None:
                            variant_name_parts.append(f"{guest_name}_B{budget}_P{period}")
                            continue

                    variant_name_parts.append(f"{guest_name}_{len(mbr_lines)}")

                for pattern in list_mbr_config_pattern:
                    hint = get_pattern_guest_hint(pattern)
                    sectors = find_all_sectors(new_file_content, pattern)

                    if hint:
                        matching_variants = [
                            guest_data for guest_data in guest_line_variants
                            if hint in guest_data[0].lower()
                        ]
                    else:
                        matching_variants = guest_line_variants

                    # Fallback to single-guest configs only for generic placeholders
                    # (patterns without a guest hint). For guest-specific placeholders,
                    # unmatched hints must remain empty.
                    if not matching_variants and not hint and len(guest_line_variants) == 1:
                        matching_variants = guest_line_variants

                    for occ_idx, sector in reversed(list(enumerate(sectors))):
                        if not matching_variants:
                            mbr_config_str = "\n"
                        else:
                            if len(matching_variants) == 1:
                                _, mbr_lines = matching_variants[0]
                            else:
                                selected_idx = min(occ_idx, len(matching_variants) - 1)
                                _, mbr_lines = matching_variants[selected_idx]
                            mbr_config_str = "\n".join(mbr_lines) + "\n"

                        start, end = sector
                        new_file_content = new_file_content[:start] + mbr_config_str + new_file_content[end:]

            else:
                # Legacy list-based variants: preserve current behavior.
                num_patterns = len(list_mbr_config_pattern)
                replaced_counts = [0] * num_patterns
                mbr_lines_counts = []

                for pattern_idx, pattern in enumerate(list_mbr_config_pattern):
                    sectors = find_all_sectors(new_file_content, pattern)
                    for occ_idx, sector in reversed(list(enumerate(sectors))):
                        vm_instance_idx = sum(replaced_counts[:pattern_idx]) + occ_idx
                        if vm_instance_idx >= len(variant_mbr):
                            start, end = sector
                            new_file_content = new_file_content[:start] + "\n" + new_file_content[end:]
                            continue

                        mbr_lines = variant_mbr[vm_instance_idx]
                        mbr_lines_counts.append(str(len(mbr_lines)))
                        mbr_config_str = "\n".join(mbr_lines) + "\n"
                        start, end = sector
                        new_file_content = new_file_content[:start] + mbr_config_str + new_file_content[end:]
                        replaced_counts[pattern_idx] += 1

                if mbr_lines_counts:
                    variant_name_parts.append("_".join(mbr_lines_counts))

            variant_name = "_".join(variant_name_parts) if variant_name_parts else f"variant{variant_idx}"
            final_name = f"{filename}_mbr_{sanitize_name(variant_name)}"
            if final_name in list_config_names:
                final_name = f"{final_name}_{variant_idx}"

            list_new_configs.append(new_file_content)
            list_config_names.append(final_name)

        return list_new_configs, list_config_names
    
    def generate_config_placeholder(self, enable_profiler=False):
        config = {
            "vm_images": [],
            "vm_configs": [],
            "config_preamble": [
                "#include <config.h>\n\n",
                "struct config config = {\n",
                "\tCONFIG_HEADER\n",
                "\t.shmemlist_size = 1,",
                "\t.shmemlist = (struct shmem []){",
                "\t\t[0] = { .size = 0x00010000, }\n",
                "\t},\n\n",
            ],
            "vm_list_size": "\t.vmlist_size = ",
            "vm_list": "\t.vmlist = {",
            "config_name" : "",
            "enable_profiler": enable_profiler,
        }

        return config

    def extract_vm_configs_from_file(self, config_val):
        """
        Extracts VM config blocks (balanced braces) inside the .vmlist = { ... } section
        Returns list of VM config strings including braces.
        """
        import re

        # 1) Find the start and end of the .vmlist = { ... } block
        start_match = re.search(r'\.vmlist\s*=\s*(?:\(struct\s+vm_config\[\]\)\s*)?\{', config_val)
        if not start_match:
            return []

        start_idx = start_match.end()  # Position after opening brace

        # We need to find the matching closing brace for .vmlist
        brace_count = 1
        idx = start_idx
        end_idx = None
        while idx < len(config_val) and brace_count > 0:
            char = config_val[idx]
            if char == '{':
                brace_count += 1
            elif char == '}':
                brace_count -= 1
            idx += 1
        end_idx = idx  # Position after matching closing }

        if end_idx is None:
            return []

        # Extract the full .vmlist content inside braces
        vmlist_content = config_val[start_idx:end_idx-1].strip()

        # 2) Extract all balanced curly brace blocks at top-level inside vmlist_content
        vm_configs = []
        length = len(vmlist_content)
        i = 0

        while i < length:
            # Skip whitespace and commas
            while i < length and vmlist_content[i] in ', \n\r\t':
                i += 1
            if i >= length:
                break
            if vmlist_content[i] != '{':
                # Unexpected char outside VM block, skip or break
                break

            # Parse one balanced block starting at i
            brace_level = 0
            start_block = i
            while i < length:
                if vmlist_content[i] == '{':
                    brace_level += 1
                elif vmlist_content[i] == '}':
                    brace_level -= 1
                    if brace_level == 0:
                        # End of VM block
                        end_block = i + 1  # include closing brace
                        vm_block = vmlist_content[start_block:end_block].strip()
                        vm_configs.append(vm_block)
                        i = end_block
                        break
                i += 1

        return vm_configs

    def reconstruct_full_config(self, config_val, mitigated_vm_configs):
        """
        Replace the VM blocks inside .vmlist = { ... } with mitigated_vm_configs.
        mitigated_vm_configs must be strings.
        """
        # Match the .vmlist = { ... } block for replacement
        vmlist_regex = r'(\.vmlist\s*=\s*(?:\(struct\s+vm_config\[\]\)\s*)?\{)(.*?)(\n\s*\},\n*)'
        vmlist_match = re.search(vmlist_regex, config_val, re.DOTALL)
        if not vmlist_match:
            # Could not find vmlist block; just return original file
            return config_val
        prefix = vmlist_match.group(1)
        suffix = vmlist_match.group(3)
        # Insert all mitigated VM configs, separated according to formatting
        body = "\n\n".join(mitigated_vm_configs)
        # Replace the block
        new_config = config_val[:vmlist_match.start()] + prefix + "\n" + body + suffix + config_val[vmlist_match.end():]
        return new_config

    def generate_interference_mitigation_configurations(self, hardware_obj, list_configs, 
                                                        list_cc_config_pattern,
                                                        list_mbr_config_pattern,
                                                        list_cache_colors=[], list_mbr_configs=[]):
        output_list_configs = {}
        self.list_configs = []

        for config_name, config_val in list_configs.items():
            # Generate all cache color variants from base config
            cc_configs, cc_names = self.generate_cache_colors_code(
                config_val, f"{config_name}",
                list_cc_config_pattern,
                list_cache_colors,
                hardware_obj.num_cache_colors
            )

            # For each colored config, generate all MBR variants
            for i, cc_config in enumerate(cc_configs):
                cc_config_name = cc_names[i]

                print(f"Generating MBR variants for config: {cc_config_name}")
                print("list_mbr_configs:", list_mbr_configs)
                mbr_configs, mbr_names = self.generate_mbr_code(
                    cc_config, cc_config_name,
                    list_mbr_config_pattern,
                    list_mbr_configs
                )

                for j, mbr_config in enumerate(mbr_configs):
                    mbr_config_name = mbr_names[j]
                    output_list_configs[mbr_config_name] = mbr_config
                    self.list_configs.append(mbr_config_name)

        return output_list_configs
        
    def combine_guests(self, config_groups: dict):
        """
        config_groups = {
            "linux": {name: config_str},
            "cache": {...},
            "embench": {...},
            ...
        }
        """
        normalized = {
            name: (cfg.items() if cfg else [("", "")])
            for name, cfg in config_groups.items()
        }

        group_names = list(normalized.keys())
        group_values = list(normalized.values())

        list_configs = []
        enable_profiler = "profiler" in config_groups and bool(config_groups["profiler"])

        # Cartesian product over all groups
        for combo in product(*group_values):
            config = self.generate_config_placeholder(enable_profiler)
            config_name_parts = []
            num_vms = 0

            for group_name, (guest_name, guest_config) in zip(group_names, combo):
                if not guest_config:
                    continue

                image = guest_config.split("\n")[0]
                vm_config = guest_config.split("\n")[1:]

                config["vm_images"].append(image)
                config["vm_configs"].append(vm_config)
                config_name_parts.append(guest_name)
                num_vms += 1

            config_name = "_".join(filter(None, config_name_parts))
            self.list_configs.append(config_name)
            list_configs.append(config)

        max_vms = max((len(c["vm_images"]) for c in list_configs), default=0)

        return list_configs, max_vms

    def generate_configs(self, dict_configs=None, include_profiler=False):
        dict_configs = dict_configs or {}
        configs = {}

        for i, config in enumerate(dict_configs):
            config_name = self.list_configs[i]
            config_content = config['config_preamble'][0]
            config_content += "\n".join(config['vm_images']) + "\n\n"
            config_content += "\n".join(config['config_preamble'][1:])

            ######################################################################################## Remove after tests

            if include_profiler or config.get("enable_profiler", False):
                config_content += "\t.en_out_of_core_profiler = true,\n"
                config_content += "\t.out_of_core_profiler = { \n"
                config_content += "\t\t\t\t.num_target_cpus = 3,\n"
                config_content += "\t\t\t\t.num_profile_events = 3,\n"
                config_content += "\t\t\t\t.list_events = (size_t[]){0x03, 0x17, 0x13},\n"
                config_content += "\t},\n\n"

            ######################################################################################## 

            config_content += config['vm_list_size'] + str(len(config['vm_images'])) + ",\n"
            config_content += config['vm_list'] + "\n"
            config_content += "\n".join([cfg for cfgs in config["vm_configs"] for cfg in cfgs]) + "\n"
            config_content += "\t}\n"
            config_content += "};\n"
            configs[config_name] = config_content

        return configs
    
    def generate_profiler_variant_combinations(self, guest_obj, hw_obj):
        list_profile_variants = []
        list_profile_codes = []

        for guest in guest_obj.list_guests:
            guest_perf_monitor = self.generate_profiler_variant(
                                    guest["list_events"], 
                                    guest["profiling_period_us"],
                                    hw_obj.pmu)
            perf_code = hw_obj.pmu.generate_perf_monitor_code(guest["performance_monitor_events"])

            list_profile_variants.append(guest_perf_monitor)
            list_profile_codes.append(perf_code)
        
        return list_profile_variants, list_profile_codes
    
    def generate_profiler_variant_combinations(self, guest_obj, hw_obj):
        list_perf_variants = []
        list_perf_codes = []

        for guest in guest_obj.list_guests:            
            guest_profiler = self.generate_profiler_variant(
                                    guest["list_events"], 
                                    guest["profiling_period_us"],
                                    guest["num_target_cpus"],
                                    guest["store_buffer_size"],
                                    guest["num_store_buffers"],
                                    hw_obj.pmu)
            perf_code = hw_obj.pmu.generate_perf_monitor_code(guest["list_events"])

            list_perf_variants.append(guest_profiler)
            list_perf_codes.append(perf_code)
        
        return list_perf_variants, list_perf_codes

    def generate_baremetal_solo_tests(self, guests_objs, hardware_obj, list_cache_colors=[], list_mbr_configs=[], include_profiler=False):
        out_dir = f"{self.root_dir}{self.configs_dir}/{self.benchmark}/solo_baremetal"
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        baremetal_guest_obj = []
        profiler_guest_obj = []
        profiler_guest_configs = {}

        baremetal_type_suffix = {
            "baremetal_cache_guests" : "_cache",
            "baremetal_dram_guests" : "_dram",
            "baremetal_embench_guests" : "_embench"
        }

        for guest_obj in guests_objs:
            if guest_obj.__module__ == "baremetal":
                baremetal_guest_obj = guest_obj
                out_dir += baremetal_type_suffix[type(guest_obj).__name__] if type(guest_obj).__name__ in baremetal_type_suffix else ""

            elif guest_obj.__module__ == "profiler":
                profiler_guest_obj = (guest_obj)

        baremetal_guest_configs = baremetal_guest_obj.generate_guest_config_files(
            benchmark = self.benchmark,
            template_file = f"{self.root_dir}{self.configs_templates}/guests/baremetal.c",
            hw_obj = hardware_obj
        )

        if include_profiler:
            out_dir+="_profiling"
            profiler_guest_configs = profiler_guest_obj.generate_guest_config_files(
                benchmark = self.benchmark,
                template_file = f"{self.root_dir}{self.configs_templates}/guests/profiler.c",
                hw_obj = hardware_obj
            )

        dict_configs, num_vms = self.combine_guests(
            baremetal_configs = baremetal_guest_configs,
            profiler_configs = profiler_guest_configs
        )

        list_configs = self.generate_configs(dict_configs, include_profiler=include_profiler)
        list_configs = self.generate_interference_mitigation_configurations(
            hardware_obj,
            list_configs,
            list_cc_config_pattern = [re.compile(r"#baremetal_cache_coloring_config#\n")],
            list_mbr_config_pattern = [re.compile(r"#baremetal_mem_br_config#\n")],
            list_cache_colors = list_cache_colors,
            list_mbr_configs = list_mbr_configs
        )
    
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        for config in list_configs:
            config_name = f"{out_dir}/{config}.c"
            write_config(config_name, list_configs[config])
        
        if include_profiler:
            with open(f"{out_dir}/profiler_toc_file.txt", "w") as f:
                f.write(profiler_guest_obj.profiler_toc_file)

    def run_bash_script(self, script, args):
        try:
            result = subprocess.run(
                ['/bin/bash', f"{self.root_dir}/setup_generator/sh_scripts/{script}.sh"] + args,
                check=True,
                text=True,
                capture_output=True
            )

            if result.stderr:
                print("Script warnings/errors:", result.stderr)

        except subprocess.CalledProcessError as e:
            print("Script failed with error:", e.stderr)

    def build_tests(self, platform, include_profiling_vm=False):
        config_dir = os.path.join(
            self.configs_dir, 
            self.benchmark, self.list_setups[0])
        
        config_dir = f"{self.root_dir}{config_dir}"

        for setup in self.list_configs:
            out_dir = f"{self.imgs_dir}/{self.hypervisor}/{self.benchmark}/{self.list_setups[0]}"

            self.build_hypervisor(config_dir, setup, out_dir, platform, include_profiling_vm)

    def generate_tests(self, list_guests_obj, hardware_obj,
                            list_cache_colors=[], list_mbr_configs=[],
                            setup_name=None, include_profiler=False,):

        out_dir = f"{self.root_dir}{self.configs_dir}/{self.benchmark}/{setup_name}"

        # Separate guest lists by type
        baremetal_cache_guests = []
        baremetal_embench_guests = []
        baremetal_cci_guests = []
        linux_guests = []
        profiler_guests = []

        # Map from baremetal guest class name to corresponding list
        baremetal_type_map = {
            "baremetal_cache_guests": baremetal_cache_guests,
            "baremetal_embench_guests": baremetal_embench_guests,
            "baremetal_cci_guests" : baremetal_cci_guests,
        }

        for guest_obj in list_guests_obj:
            if guest_obj.__module__ == "baremetal":
                cls_name = type(guest_obj).__name__
                if cls_name in baremetal_type_map:
                    baremetal_type_map[cls_name].append(guest_obj)
                else:
                    # Unknown baremetal type: optionally add to a generic baremetal list or ignore
                    pass
            elif guest_obj.__module__ == "linux":
                linux_guests.append(guest_obj)
            elif guest_obj.__module__ == "profiler":
                profiler_guests.append(guest_obj)

        # Construct output directory suffix based on baremetal type presence (choose last present type as example)
        baremetal_suffix = ""
        for typ in ["baremetal_cache_guests", "baremetal_embench_guests", "baremetal_cci_guests"]:
            if baremetal_type_map[typ]:
                suffix_map = {
                    "baremetal_cache_guests": "_cache",
                    "baremetal_embench_guests": "_embench",
                    "baremetal_cci_guests": "_cci"
                }
                baremetal_suffix = suffix_map[typ]
                # out_dir += baremetal_suffix
        # out_dir += "_linux"

        # Generate configs per baremetal type
        def generate_configs_for_guest_list(guest_list, template_file_path):
            combined_configs = {}
            for guest in guest_list:
                confs = guest.generate_guest_config_files(
                    benchmark=self.benchmark,
                    template_file=template_file_path,
                    hw_obj=hardware_obj
                )
                combined_configs.update(confs)
            return combined_configs

        bm_cache_configs = generate_configs_for_guest_list(
            baremetal_cache_guests,
            f"{self.root_dir}{self.configs_templates}/guests/baremetal.c"
        )
        bm_embench_configs = generate_configs_for_guest_list(
            baremetal_embench_guests,
            f"{self.root_dir}{self.configs_templates}/guests/baremetal.c"
        )
        bm_cci_configs = generate_configs_for_guest_list(
            baremetal_cci_guests,
            f"{self.root_dir}{self.configs_templates}/guests/baremetal.c"
        )

        # Generate Linux guest configs
        linux_guest_configs = {}
        for guest in linux_guests:
            linux_guest_configs.update(
                guest.generate_guest_config_files(
                    benchmark=self.benchmark,
                    template_file=f"{self.root_dir}{self.configs_templates}/guests/linux.c",
                )
            )

        # if list_cache_colors:
        #     out_dir += "_cc"

        # Generate profiler guest configs if needed
        profiler_guest_configs = {}
        if include_profiler:
            out_dir += "_profiling"
            for guest in profiler_guests:
                profiler_guest_configs.update(
                    guest.generate_guest_config_files(
                        benchmark=self.benchmark,
                        template_file=f"{self.root_dir}{self.configs_templates}/guests/profiler.c",
                        hw_obj=hardware_obj
                    )
                )

        # Call combine_guests with all separate baremetal types

        config_groups = {
            "linux": linux_guest_configs,
            "cache": bm_cache_configs,
            "embench": bm_embench_configs,
            "cci": bm_cci_configs,
        }
        
        if include_profiler:
            config_groups["profiler"] = profiler_guest_configs

        dict_configs, num_vms = self.combine_guests(config_groups)
        # print(baremetal_cci_guests)

        list_configs = self.generate_configs(dict_configs, include_profiler=include_profiler)

        list_configs = self.generate_interference_mitigation_configurations(
            hardware_obj,
            list_configs,
            list_cc_config_pattern=[re.compile(r"#linux_cache_coloring_config#\n"),
                                    re.compile(r"#baremetal_cache_coloring_config#\n")
                                    ],
            list_mbr_config_pattern=[re.compile(r"#baremetal_mem_br_config#\n"),
                                    re.compile(r"#linux_mem_br_config#\n")],
            list_cache_colors=list_cache_colors,
            list_mbr_configs=list_mbr_configs
        )

        if not os.path.exists(out_dir):
            os.makedirs(out_dir)

        for config in list_configs:
            config_name = f"{out_dir}/{config}.c"
            write_config(config_name, list_configs[config])


    def build_hypervisor(self, config_dir, config_name, out_dir, platform, include_profiling_vm=False):

        dict_hypervisor = {
            "bao" : bao
            # add more hypervisors here as needed
        }

        hypervisor_obj = dict_hypervisor[self.hypervisor](self.hypervisor_dir, self.root_dir)
        hypervisor_obj.build_hypervisor(
            config_dir, config_name, self.imgs_dir, out_dir, platform, include_profiling_vm
        )



    def hardware_reset(self, turn_off_delay=3):
        if self.hardware_control_en == False:
            print("Warning: Hardware control is disabled")
            return
        
        p110 = PyP110.P110(
            self.hardware_control_cfg["device_ip"],
            self.hardware_control_cfg["email"],
            self.hardware_control_cfg["password"]
        )

        p110.turnOff()
        time.sleep(turn_off_delay)
        p110.turnOn()

    def hardware_turn_off(self):
        if self.hardware_control_en == False:
            print("Warning: Hardware control is disabled")
            return
    
        p110 = PyP110.P110(
            self.hardware_control_cfg["device_ip"],
            self.hardware_control_cfg["email"],
            self.hardware_control_cfg["password"]
        )

        p110.turnOff()
