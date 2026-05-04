
import yaml
import math
import subprocess
import os
import shutil
from itertools import product
import sys
import time
import re
from datetime import datetime

guests_path = os.path.abspath('./setup_generator/guests')
sys.path.append(guests_path)

from baremetal import baremetal_cache_guests, baremetal_embench_guests
from linux import linux_guests
from profiler import profiler_guest, build_eth_logger, launch_eth_logger

platforms_path = os.path.abspath('./setup_generator/platforms')
sys.path.append(platforms_path)

from zcu104 import test_platform_zcu104

test_engine_path = os.path.abspath('./setup_generator')
sys.path.append(test_engine_path)
from test_engine import test_engine
from test_logger import test_logger, list_boot_times


en_profiler = False
profiler_events_sets = [ ]
completed_imgs = []
img_timings = {}

import argparse

parser = argparse.ArgumentParser(description="Interference Profiler Script")
parser.add_argument(
    "--skip-build",
    action="store_true",
    help="Skip the build process for the images"
)
parser.add_argument(
    # path to config file
    "--config",
    type=str,
    default="./config.yaml",
    help="Path to the configuration file (default: config.yaml)"
)
args = parser.parse_args()



def stylize_done(img, timing):
    return f"\033[9m{img}\033[0m ✅  [{timing['start']} - {timing['end']}] ({timing['duration']})"

def stylize_failed(img):
    return f"\033[91m{img}\033[0m ❌"  # Red and cross mark

def stylize_current(img):
    return f">>> \033[1m{img}\033[0m ⏳"  # Bold and pointer

def read_guests(config):
    default_guests = {}
    guests = config.get("guests", default_guests)
    linux_guests_obj = None
    baremetal_cache_guests_obj = None
    
    if "linux" in guests:
        linux_guests_obj = linux_guests()
        linux_guests_obj.read_config(guests["linux"])

    if "baremetal_cache_interf" in guests:
        baremetal_cache_guests_obj = baremetal_cache_guests()
        baremetal_cache_guests_obj.read_config(guests["baremetal_cache_interf"])

    return linux_guests_obj, baremetal_cache_guests_obj

def read_hardware_config(config, root_dir):
    default_hardware = {}
    hardware = config.get("hardware", default_hardware)
    platform_name = hardware.get("platform", "")

    # create a dictionary with the platform names and the corresponding objects
    platforms = {
        "zcu104" : test_platform_zcu104,
    }
    hw_config = platforms[platform_name](root_dir)
    hw_config.read_hardware_config(hardware)

    return hw_config

def read_tests_config(config):
    config_paths = {}
    config_setups = {}
    config_guests_per_setup = {}

    paths = config.get("paths", config_paths)
    setups = config.get("setups", config_setups)
    setups_configs  = config.get("setups_configs", config_guests_per_setup)
    hw_controller = config.get("hardware", {}).get("hardware_control", {})
    hypervisor_configs = config.get("hypervisor", {})

    test_engine_obj = test_engine()
    test_engine_obj.read_config(paths, setups, setups_configs, hypervisor_configs, hw_controller)

    return test_engine_obj

def read_framework_configurations(config):
    linux_guests_obj, baremetal_cache_guests_obj = read_guests(config)
    test_engine_obj = read_tests_config(config)
    hw_config = read_hardware_config(config, test_engine_obj.root_dir)

    return hw_config, linux_guests_obj, baremetal_cache_guests_obj, test_engine_obj


def generate_tests(engine_tests, guests_obj, hw_config, list_cache_colors, list_mbr_settings, setup_name=None):
    include_profiling_vm = False
    if("profiling" in setup_name):
        include_profiling_vm = True
        setup_name = setup_name.replace("_profiling", "")

    engine_tests.generate_tests(guests_obj, hw_config, list_cache_colors, list_mbr_settings, setup_name, include_profiling_vm)
    if not args.skip_build:
        engine_tests.build_tests(hw_config.platform_name, include_profiling_vm)

def print_test_status(img_index, img, list_bao_imgs):
    sys.stdout.write("\033[2J\033[H")  # Clear screen
    print("Image Test Progress:\n")
    for j, name in enumerate(list_bao_imgs):
        if name in img_timings:
            print(stylize_done(name, img_timings[name]))
        elif j == img_index:
            print(stylize_current(name))
        else:
            print(stylize_failed(name))
    print(f"\nRunning test: {img}")

def main():

    config_file = args.config
    with open(config_file, "r") as config_file:
        config = yaml.safe_load(config_file)

    engine_tests = read_tests_config(config)
    hw_config = read_hardware_config(config, engine_tests.root_dir)

    list_guests = []
    en_profiler = False
    for setup in engine_tests.list_setups:
        setup_guests = engine_tests.get_setup_list_of_guests(setup)
        for setup_guest in setup_guests:
            list_guests.append(setup_guest)
    list_guests = list(dict.fromkeys(list_guests))
    
    guests = config.get("guests", {})
    guests_obj = {}

    for guest in list_guests:
        if guest == "linux":
            linux_guests_obj = linux_guests()
            linux_guests_obj.read_config(guests["linux"])
            linux_guests_obj.get_configurations()
            if not args.skip_build:
                linux_guests_obj.build_guests(f"{engine_tests.imgs_dir}/guests/{engine_tests.benchmark}", hw_config.platform_name)

            guests_obj["linux"] = linux_guests_obj

        elif guest == "baremetal_cache_interf":
            baremetal_cache_guests_obj = baremetal_cache_guests()
            baremetal_cache_guests_obj.read_config(guests["baremetal_cache_interf"])
            baremetal_cache_guests_obj.get_configurations()
            if not args.skip_build:
                baremetal_cache_guests_obj.build_guests(f"{engine_tests.imgs_dir}/guests/{engine_tests.benchmark}", hw_config.platform_name)

            guests_obj["baremetal_cache_interf"] = baremetal_cache_guests_obj
        
        elif guest == "baremetal_embench":
            baremetal_embench_guests_obj = baremetal_embench_guests()
            baremetal_embench_guests_obj.read_config(guests["baremetal_embench"])
            baremetal_embench_guests_obj.get_configurations()
            if not args.skip_build:
                baremetal_embench_guests_obj.build_guests(f"{engine_tests.imgs_dir}/guests/{engine_tests.benchmark}", hw_config.platform_name)

            guests_obj["baremetal_embench"] = baremetal_embench_guests_obj

        elif guest == "profiler":
            profiler_guests_obj = profiler_guest()
            profiler_guests_obj.read_config(guests["profiler"])
            profiler_guests_obj.get_configurations(hw_config.num_pmu_counters)
            if not args.skip_build:
                profiler_guests_obj.build_guests(f"{engine_tests.imgs_dir}/guests/{engine_tests.benchmark}", hw_config.platform_name)

            guests_obj["profiler"] = profiler_guests_obj
            en_profiler = True

    for setup in engine_tests.list_setups:
        setup_cfg = {}
        for cfg in engine_tests.setups_configs:
            if cfg.get("setup") == setup:
                setup_cfg = cfg
                break
        cache_coloring_en = setup_cfg["cache_coloring"]


        list_cache_colors = []
        setup_guests = setup_cfg["guests"]
        setup_guests_obj = []
        for guest in setup_guests:
            setup_guests_obj.append(guests_obj[guest])

        if cache_coloring_en:
            if setup_cfg["cache_coloring_list"] != []:
                list_cache_colors = setup_cfg["cache_coloring_list"]
            else:
                num_vms = 2 if len(setup_guests) == 1 else len(setup_guests) 
                if en_profiler:
                    num_vms -= 1
                list_cache_colors = engine_tests.generate_cache_colors_assignment(hw_config.num_cache_colors, num_vms)
        
        mbr_configuration = setup_cfg["setup_mbr"]
        list_mbr_settings = []
        print(f"MBR configuration for setup {setup}: {mbr_configuration}")
        if mbr_configuration:
            list_mbr_settings = engine_tests.generate_mbr_assignments(mbr_configuration)
            
        generate_tests(engine_tests, setup_guests_obj, hw_config, list_cache_colors, list_mbr_settings, setup)

    list_bao_imgs = []
    list_log_ports = []
    for setup in engine_tests.list_setups:
        for cfg in engine_tests.list_configs:
            setup_name = re.sub(r".*?"+engine_tests.benchmark, engine_tests.benchmark, cfg)
            setup_name += ".img"
            list_bao_imgs.append(setup_name)

            for cfg_settings in engine_tests.setups_configs:
                if cfg_settings.get("setup") == setup:
                    list_log_ports.append(cfg_settings["log_ports"])
                    break


    # return 0

    test_logger_obj = test_logger(hw_config.master_interface, 115200)
    engine_tests.hardware_reset()

    for i, img in enumerate(list_bao_imgs):

        success = False
        retry_count = 0
        max_retries = 10  # Set a limit to prevent infinite loops

        while not success and retry_count < max_retries:
            start_time = datetime.now()
            print_test_status(i, img, list_bao_imgs)        
            print(f"Start time: {start_time.strftime('%Y-%m-%d %H:%M:%S')}\n")

            if en_profiler:
                build_eth_logger(engine_tests.root_dir)            
                num_profiler_variants = len(profiler_guests_obj.list_guests)
                guest_index = i % num_profiler_variants

                eth_profiler_process = launch_eth_logger(
                    engine_tests.root_dir,
                    profiler_guests_obj.profiler_runtime_config["tx_packet_size"],
                    f"{engine_tests.root_dir}/tests_results/profile/{engine_tests.benchmark}/{engine_tests.list_setups[0]}/{img[:-4]}.txt",
                    profiler_guests_obj.num_target_cpus
                )

            log_output_dir = f"{engine_tests.root_dir}/tests_results/{engine_tests.benchmark}/{engine_tests.list_setups[0]}/{img[:-4]}"
            os.makedirs(log_output_dir, exist_ok=True)

            print("Starting test for image:", img)
            img_path = f"{engine_tests.imgs_dir}/{engine_tests.hypervisor}/{engine_tests.benchmark}/{engine_tests.list_setups[0]}/{img}"

            hw_config.launch_test(img_path)

            test_logger_obj.event_end_of_test.clear()
            for serial_port in list_log_ports[i]:
                test_logger_obj.open_serial_port(serial_port, 115200)
                serial_port_name = serial_port.replace("/", "_")
                log_filename = f"{log_output_dir}/log{serial_port_name}.txt"
                test_logger_obj.set_logger_to_port(serial_port, log_filename)
                print(f"Logging to: {log_filename}")


            test_completed = test_logger_obj.wait_for_test_end(timeout=60*3)
            test_logger_obj.reset_test_status()

            if en_profiler:
                eth_profiler_process.terminate()
                eth_profiler_process.wait()
                eth_profiler_process.kill()
                eth_profiler_process.wait()

            end_time = datetime.now()

            if test_completed:
                duration = str(end_time - start_time)
                img_timings[img] = {
                    "start": start_time.strftime('%H:%M:%S'),
                    "end": end_time.strftime('%H:%M:%S'),
                    "duration": duration
                }
                completed_imgs.append(img)
                success = True

            else:
                engine_tests.hardware_reset(turn_off_delay=15)
                # input("Test failed, please reboot hardware and press enter to continue...")
                retry_count += 1
                print(f"Test for image {img} failed. Retrying... ({retry_count}/{max_retries})")

        if retry_count == max_retries:
            print(f"Max retries reached for image {img}. Moving to the next image.")
            img_timings[img] = {
                "start": start_time.strftime('%H:%M:%S'),
                "end": "N/A",
                "duration": "N/A"
            }

        time.sleep(0.5)

    print_test_status(len(list_bao_imgs), img, list_bao_imgs)
    engine_tests.hardware_turn_off()


if __name__ == "__main__":
    main()
