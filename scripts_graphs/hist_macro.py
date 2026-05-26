"""
plot_mibench.py
Parses MiBench results from the DAAT-MCS framework and plots
relative performance histograms (interf_time / solo_time).

4 plots:
  - Read Snoop  / Non-Coherent
  - Read Snoop  / Coherent
  - Write Snoop / Non-Coherent
  - Write Snoop / Coherent

Usage:
    python3 plot_mibench.py [results_dir]
"""

import os
import re
import sys
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────

DEFAULT_RESULTS_DIR = (
    "/media/diogo/rootfs/CCI_Interference/DAAT-MCS/DAAT-MCS/"
    "tests_results/CCI_macrobenchmarks/cci_baremetal_linux"
)

LOG_FILENAME = "log_dev_ttyUSB2.txt"

BENCH_ORDER = [
    "qsort-small", "qsort-large",
    "susanc-small", "susanc-large",
    "susane-small", "susane-large",
    "susans-small", "susans-large",
    "bitcount-small", "bitcount-large",
    "basicmath-small", "basicmath-large",
]

COLORS = {
    "SOLO":          "#94a3b8",
    "DMA-1ch":       "#60a5fa",
    "DMA-2ch":       "#3b82f6",
    "DMA-4ch":       "#2563eb",
    "DMA-8ch":       "#1d4ed8",
    "DMA+FPGA-1ch":  "#f97316",
    "DMA+FPGA-2ch":  "#ea580c",
    "DMA+FPGA-4ch":  "#c2410c",
    "DMA+FPGA-8ch":  "#9a3412",
}

SERIES_ORDER = [
    "SOLO",
    "DMA-1ch", "DMA-2ch", "DMA-4ch", "DMA-8ch",
    "DMA+FPGA-1ch", "DMA+FPGA-2ch", "DMA+FPGA-4ch", "DMA+FPGA-8ch",
]

# ── Parsing ───────────────────────────────────────────────────────────────────

def parse_folder_name(folder):
    p = {"test_type": None, "snoop": None, "channels": None, "coherency": None}

    if "TEST_TYPE_DMA_FPGA" in folder:
        p["test_type"] = "DMA_FPGA"
    elif "TEST_TYPE_DMA" in folder:
        p["test_type"] = "DMA"
    elif "TEST_TYPE_SOLO" in folder:
        p["test_type"] = "SOLO"
    else:
        return None

    m = re.search(r"snoop(\d+)", folder)
    if not m: return None
    p["snoop"] = int(m.group(1))

    m = re.search(r"ch(\d+)", folder)
    if not m: return None
    p["channels"] = int(m.group(1))

    m = re.search(r"coh(\d+)", folder)
    if not m: return None
    p["coherency"] = int(m.group(1))

    return p


def parse_log(log_path):
    """
    Parse log_dev_ttyUSB2.txt.
    Format:
        -> mibench/automotive/qsort-small
        ...
        # Final result:
        0.026401 +- 0.000113 seconds time elapsed  ( +-  0.43% )
    The time value is on the line AFTER '# Final result:'
    """
    results = {}
    current_bench = None
    grab_next = False

    with open(log_path, "r", errors="ignore") as f:
        lines = f.readlines()

    for line in lines:
        line_s = line.strip()

        # Grab the number from the line after "Final result:"
        if grab_next and current_bench:
            m = re.search(r"([\d.]+)", line_s)
            if m:
                results[current_bench] = float(m.group(1))
            current_bench = None
            grab_next = False
            continue

        if "mibench/automotive/" in line_s:
            current_bench = line_s.split("mibench/automotive/")[-1].strip()
            grab_next = False
            continue

        if "Final result:" in line_s and current_bench:
            # Check if number is on same line
            after = line_s.split("Final result:")[-1].strip()
            m = re.search(r"([\d.]+)", after)
            if m:
                results[current_bench] = float(m.group(1))
                current_bench = None
            else:
                # Number is on next line
                grab_next = True

    return results


def series_label(test_type, channels):
    if test_type == "SOLO":      return "SOLO"
    elif test_type == "DMA":     return f"DMA-{channels}ch"
    elif test_type == "DMA_FPGA": return f"DMA+FPGA-{channels}ch"
    return "?"


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    results_dir = sys.argv[1] if len(sys.argv) > 1 else DEFAULT_RESULTS_DIR
    results_dir = Path(results_dir)

    if not results_dir.exists():
        print(f"ERROR: Directory not found: {results_dir}")
        sys.exit(1)

    data = {
        1: {0: {}, 1: {}},
        2: {0: {}, 1: {}},
    }

    for folder in sorted(results_dir.iterdir()):
        if not folder.is_dir():
            continue
        meta = parse_folder_name(folder.name)
        if meta is None:
            continue

        log_path = folder / LOG_FILENAME
        if not log_path.exists():
            print(f"  [WARN] No log file in {folder.name}")
            continue

        bench_times = parse_log(log_path)
        if not bench_times:
            print(f"  [WARN] No results parsed from {folder.name}")
            continue

        print(f"  [OK] {folder.name} -> {len(bench_times)} benchmarks")

        snoop  = meta["snoop"]
        coh    = meta["coherency"]
        series = series_label(meta["test_type"], meta["channels"])

        if snoop not in data or coh not in data[snoop]:
            continue

        if series not in data[snoop][coh]:
            data[snoop][coh][series] = {}

        for bench, t in bench_times.items():
            if bench in data[snoop][coh][series]:
                data[snoop][coh][series][bench] = (data[snoop][coh][series][bench] + t) / 2
            else:
                data[snoop][coh][series][bench] = t

    # ── Plots ─────────────────────────────────────────────────────────────────
    plot_configs = [
        (1, 0, "Read Snoop - Non-Coherent"),
        (1, 1, "Read Snoop - Coherent"),
        (2, 0, "Write Snoop - Non-Coherent"),
        (2, 1, "Write Snoop - Coherent"),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(24, 14))
    fig.patch.set_facecolor("#0f0f17")
    axes = axes.flatten()

    for ax_idx, (snoop, coh, title) in enumerate(plot_configs):
        ax = axes[ax_idx]
        ax.set_facecolor("#12121f")

        d = data[snoop][coh]

        if "SOLO" not in d:
            ax.text(0.5, 0.5, "No SOLO data", ha="center", va="center",
                    color="#ef4444", transform=ax.transAxes, fontsize=14)
            ax.set_title(title, color="#7c9ef8", fontsize=13, pad=10)
            continue

        available_series = [s for s in SERIES_ORDER if s in d and d[s]]
        n_series  = len(available_series)
        n_benches = len(BENCH_ORDER)
        bar_width = 0.8 / n_series
        x = np.arange(n_benches)

        for s_idx, series in enumerate(available_series):
            solo_data   = d["SOLO"]
            series_data = d[series]

            rel_perf = []
            for bench in BENCH_ORDER:
                solo_t   = solo_data.get(bench)
                series_t = series_data.get(bench)
                if solo_t and series_t and solo_t > 0:
                    rel_perf.append(series_t / solo_t)
                else:
                    rel_perf.append(0.0)

            offset = (s_idx - n_series / 2 + 0.5) * bar_width
            ax.bar(
                x + offset, rel_perf,
                width=bar_width * 0.9,
                color=COLORS.get(series, "#888"),
                label=series,
                zorder=3
            )

        ax.axhline(y=1.0, color="#22c55e", linewidth=1.2,
                   linestyle="--", zorder=4, alpha=0.8, label="Solo baseline")

        ax.set_ylim(0, 1.6)

        ax.set_title(title, color="#7c9ef8", fontsize=13, fontweight="bold", pad=12)
        ax.set_xticks(x)
        ax.set_xticklabels(BENCH_ORDER, rotation=35, ha="right",
                           fontsize=9, color="#94a3b8")
        ax.set_ylabel("Relative Performance", color="#94a3b8", fontsize=10)
        ax.tick_params(axis="y", colors="#94a3b8")
        ax.tick_params(axis="x", colors="#94a3b8")
        for spine in ax.spines.values():
            spine.set_edgecolor("#2d2d44")
        ax.yaxis.grid(True, color="#2d2d44", linewidth=0.6, zorder=0)
        ax.set_axisbelow(True)
        ax.legend(fontsize=8, ncol=3, facecolor="#1a1a2e", edgecolor="#2d2d44",
                  labelcolor="#e2e8f0", loc="upper right")

    fig.suptitle("MiBench - Relative Performance under CCI Interference",
                 color="#e2e8f0", fontsize=16, fontweight="bold", y=1.01)
    plt.tight_layout(pad=2.0)

    out_path = results_dir / "mibench_relative_performance.png"
    plt.savefig(out_path, dpi=150, bbox_inches="tight", facecolor="#0f0f17")
    print(f"\nSaved: {out_path}")
    plt.show()


if __name__ == "__main__":
    main()