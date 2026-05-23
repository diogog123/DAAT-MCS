import pandas as pd
import glob
import os
import re
import argparse

CLOCK_FREQ_HZ = 150e6

# ============================================================
# AXI SIGNAL CONFIGURATION
# ============================================================

SNOOP_CONFIG = {
    1: {  # READ SNOOP
        "req_valid": "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_arvalid_1",
        "req_ready": "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_arready_1",
        "response":  "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_rvalid_1",
        "req_value": "SEND_AR",
        "resp_value": "1",
        "type_name": "read"
    },

    2: {  # WRITE SNOOP
        "req_valid": "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_awvalid_1",
        "req_ready": "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_awready_1",
        "response":  "design_1_i/system_ila_0/inst/SLOT_0_ACEMM_bvalid_1",
        "req_value": "SEND_AW",
        "resp_value": "1",
        "type_name": "write"
    }
}

# ============================================================
# LATENCY EXTRACTION
# ============================================================

def calc_latencies(file_path, cfg):

    df = pd.read_csv(file_path, low_memory=False)

    req_handshake = (
        (df[cfg["req_valid"]] == cfg["req_value"]) &
        (df[cfg["req_ready"]] == '1')
    )

    response_handshake = (
        df[cfg["response"]] == cfg["resp_value"]
    )

    req_indices = df.index[req_handshake]
    response_indices = df.index[response_handshake]

    latencies_cycles = []

    for req in req_indices:

        response_after = response_indices[response_indices > req]

        if len(response_after) > 0:

            latency = response_after[0] - req
            latencies_cycles.append(latency)

    return latencies_cycles

# ============================================================
# TEST PARSING
# ============================================================

def parse_test_folder(folder_name):

    pattern = (
        r'baremetal_cci_TEST_TYPE_'
        r'(?P<testtype>SOLO|DMA|DMA_FPGA)_'
        r'snoop(?P<snoop>[12])_'
        r'ch(?P<channels>\d+)_'
        r'coh(?P<coh>[01])_'
        r'C\d+'
    )

    match = re.search(pattern, folder_name)

    if not match:
        raise ValueError(f"Invalid folder name: {folder_name}")

    info = match.groupdict()

    # --------------------------------------------------------

    if info["testtype"] == "SOLO":
        interference = "solo"

    elif info["testtype"] == "DMA":
        interference = "dma_interf"

    elif info["testtype"] == "DMA_FPGA":
        interference = "dma+fpga_interf"

    else:
        interference = "unknown"

    # --------------------------------------------------------

    snoop_id = int(info["snoop"])

    snoop_type = SNOOP_CONFIG[snoop_id]["type_name"]

    # --------------------------------------------------------

    coherency = (
        "coherent"
        if info["coh"] == "1"
        else "non_coherent"
    )

    # --------------------------------------------------------

    return {
        "interference": interference,
        "snoop_type": snoop_type,
        "channels": int(info["channels"]),
        "coherency": coherency,
        "snoop_id": snoop_id
    }

# ============================================================
# PROCESS SINGLE TEST
# ============================================================

def process_test_folder(folder_path, output_dir):

    folder_name = os.path.basename(folder_path)

    print("\n====================================================")
    print(f"Processing: {folder_name}")
    print("====================================================")

    test_info = parse_test_folder(folder_name)

    cfg = SNOOP_CONFIG[test_info["snoop_id"]]

    # --------------------------------------------------------

    csv_files = glob.glob(
        os.path.join(folder_path, "*.csv")
    )

    csv_files.sort()

    if len(csv_files) == 0:
        print("No CSV files found.")
        return

    # Optional:
    # skip first run if needed
    csv_files = csv_files[1:]

    # --------------------------------------------------------

    all_transactions = []

    for run_num, file_path in enumerate(csv_files, start=2):

        print(f"Run {run_num}: {os.path.basename(file_path)}")

        latencies = calc_latencies(file_path, cfg)

        for trans_num, latency in enumerate(latencies, start=1):

            all_transactions.append({

                "Run": run_num,

                "Transaction": trans_num,

                "Latency (cycles)": latency,

                "Latency (ns)": (
                    latency / CLOCK_FREQ_HZ * 1e9
                ),

                "Interference": test_info["interference"],

                "Snoop Type": test_info["snoop_type"],

                "Channels": test_info["channels"],

                "Coherency": test_info["coherency"]
            })

    # --------------------------------------------------------

    out_df = pd.DataFrame(all_transactions)

    out_filename = (
        f"{test_info['interference']}_"
        f"{test_info['snoop_type']}_"
        f"{test_info['channels']}ch_"
        f"{test_info['coherency']}.csv"
    )

    out_path = os.path.join(output_dir, out_filename)

    out_df.to_csv(out_path, index=False)

    print(f"\nSaved: {out_path}")

# ============================================================
# MAIN
# ============================================================

parser = argparse.ArgumentParser()

parser.add_argument(
    "root_folder",
    help="Folder containing all test folders"
)

parser.add_argument(
    "--output",
    default="parsed_results",
    help="Output folder"
)

args = parser.parse_args()

ROOT_FOLDER = args.root_folder
OUTPUT_FOLDER = args.output

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# ============================================================

test_folders = glob.glob(
    os.path.join(ROOT_FOLDER, "baremetal_cci_TEST_TYPE_*")
)

test_folders.sort()

print(f"\nFound {len(test_folders)} test folders")

# ============================================================

for folder in test_folders:

    process_test_folder(folder, OUTPUT_FOLDER)

print("\n====================================================")
print("ALL TESTS FINISHED")
print("====================================================")