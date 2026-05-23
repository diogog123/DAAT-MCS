import pandas as pd
import glob
import os

INPUT_DIR = "parsed_results/"
OUTPUT_DIR = "quantiles_results/"

os.makedirs(OUTPUT_DIR, exist_ok=True)


def process_file(file_path):
    df = pd.read_csv(file_path)

    name = os.path.splitext(os.path.basename(file_path))[0]

    # -----------------------
    # Q95
    # -----------------------
    q95 = df["Latency (cycles)"].quantile(0.95)
    df_q95 = df[df["Latency (cycles)"] <= q95]

    q95_out = os.path.join(OUTPUT_DIR, f"{name}_q95.csv")
    df_q95.to_csv(q95_out, index=False)

    # -----------------------
    # Q99
    # -----------------------
    q99 = df["Latency (cycles)"].quantile(0.99)
    df_q99 = df[df["Latency (cycles)"] <= q99]

    q99_out = os.path.join(OUTPUT_DIR, f"{name}_q99.csv")
    df_q99.to_csv(q99_out, index=False)

    print(f"[{name}] Q95={q95:.2f} | Q99={q99:.2f} | N={len(df)}")


def main():
    csv_files = glob.glob(os.path.join(INPUT_DIR, "*.csv"))

    print(f"Found {len(csv_files)} test CSVs")

    for file_path in csv_files:
        process_file(file_path)


if __name__ == "__main__":
    main()