import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
from scipy.interpolate import make_interp_spline
import glob

# -----------------------------
# PATHS
# -----------------------------
RAW_DIR = "parsed_results"
Q_DIR = "quantiles_results"

BASE_OUT = "./violins_final"

# -----------------------------
# ORDER FIXA
# -----------------------------
ORDER = [
    "solo",
    "1ch", "1ch+fpga",
    "2ch", "2ch+fpga",
    "4ch", "4ch+fpga",
    "8ch", "8ch+fpga"
]

positions = np.array([1, 2.2, 3.0, 4.4, 5.2, 6.6, 7.4, 8.8, 9.6])

# -----------------------------
# COLORS
# -----------------------------
solo_color = '#4A54C3'
dma_color = '#5575F0'
fpga_color = '#A8BDF8'

# -----------------------------
# PARSE NAME
# -----------------------------
def parse_name(name):

    name = name.lower()

    mode = "raw"
    if "_q95" in name:
        mode = "q95"
    elif "_q99" in name:
        mode = "q99"

    access = "read" if "read" in name else "write"
    coh = "non_coherent" if "non_coherent" in name else "coherent"

    cfg = None

    if "solo" in name:
        cfg = "solo"
    elif "1ch" in name:
        cfg = "1ch"
    elif "2ch" in name:
        cfg = "2ch"
    elif "4ch" in name:
        cfg = "4ch"
    elif "8ch" in name:
        cfg = "8ch"

    if "fpga" in name:
        cfg = cfg + "+fpga"

    return mode, access, coh, cfg

# -----------------------------
# LOAD DATA
# -----------------------------
def load_data(mode, access, coh):

    folder = RAW_DIR if mode == "raw" else Q_DIR
    files = glob.glob(f"{folder}/*.csv")

    data = {}

    for f in files:

        name = os.path.basename(f)

        m, a, c, cfg = parse_name(name)

        if m != mode or a != access or c != coh:
            continue

        df = pd.read_csv(f)

        data[cfg] = df["Latency (cycles)"].tolist()

    return data

# -----------------------------
# PLOT
# -----------------------------
def plot(mode, access, coh, data):

    out_dir = os.path.join(BASE_OUT, mode)
    os.makedirs(out_dir, exist_ok=True)

    fig, ax = plt.subplots(figsize=(8, 5))

    mean_pos = []
    mean_val = []

    # -----------------------------
    # VIOLINS
    # -----------------------------
    for pos, label in zip(positions, ORDER):

        if label not in data:
            continue

        values = data[label]

        if label == "solo":
            color, alpha = solo_color, 0.92
        elif "+fpga" in label:
            color, alpha = fpga_color, 0.85
        else:
            color, alpha = dma_color, 0.92

        parts = ax.violinplot(
            values,
            positions=[pos],
            vert=True,
            widths=0.62,
            showmeans=False,
            showmedians=False,
            showextrema=False
        )

        # APPLY COLORS
        for pc in parts['bodies']:
            pc.set_facecolor(color)
            pc.set_edgecolor('#1A1A2E')
            pc.set_alpha(alpha)
            pc.set_linewidth(1.2)

        # MIN / MAX
        min_v = min(values)
        max_v = max(values)

        ax.plot(
            [pos, pos],
            [min_v, max_v],
            color='#1A1A2E',
            linewidth=1.6,
            zorder=3
        )

        ax.plot(
            [pos-0.07, pos+0.07],
            [min_v, min_v],
            color='#1A1A2E',
            linewidth=2.0,
            zorder=3
        )

        ax.plot(
            [pos-0.07, pos+0.07],
            [max_v, max_v],
            color='#1A1A2E',
            linewidth=2.0,
            zorder=3
        )

        # MEAN
        m = np.mean(values)

        mean_pos.append(pos)
        mean_val.append(m)

        ax.plot(
            pos,
            m,
            'o',
            color='white',
            markersize=6,
            markeredgecolor='#1A1A2E',
            markeredgewidth=1.4,
            zorder=4
        )

    # -----------------------------
    # GLOBAL TRENDLINE
    # -----------------------------
    if len(mean_pos) > 2:

        x = np.array(mean_pos)
        y = np.array(mean_val)

        xs = np.linspace(x.min(), x.max(), 300)

        spline = make_interp_spline(x, y, k=3)
        ys = spline(xs)

        ax.plot(
            xs,
            ys,
            linestyle='--',
            linewidth=2.5,
            color='#F08D39',
            zorder=2
        )

    # -----------------------------
    # GROUP SEPARATORS
    # -----------------------------
    for sep in [1.65, 3.75, 5.95, 8.15]:
        ax.axvline(
            sep,
            color='#D0CEC8',
            linewidth=0.7,
            linestyle='--',
            zorder=0
        )

    # -----------------------------
    # AXIS STYLE
    # -----------------------------
    ax.set_ylabel(
        'Latency (cycles)',
        fontsize=11,
        fontweight='bold'
    )

    ax.set_xticks(positions)

    ax.set_xticklabels(
        ORDER,
        rotation=25,
        ha='right',
        fontsize=9.5
    )

    ax.tick_params(axis='y', labelsize=9.5)

    ax.grid(axis='y', linestyle='--', alpha=0.3)

    ax.set_axisbelow(True)

    for spine in ax.spines.values():
        spine.set_color('#1A1A2E')
        spine.set_linewidth(0.8)

    # -----------------------------
    # Y LIMITS
    # -----------------------------
    ax.set_ylim(0, 50)
    ax.set_yticks(np.arange(0, 51, 10))

    # -----------------------------
    # SECONDARY AXIS
    # -----------------------------
    if len(mean_val) > 0:

        baseline = mean_val[0]

        def to_rel(y):
            return y / baseline

        def from_rel(y):
            return y * baseline

        secax = ax.secondary_yaxis(
            'right',
            functions=(to_rel, from_rel)
        )

        secax.set_ylabel(
            'Relative performance',
            fontsize=11
        )

        secax.set_ylim(0, 6)
        secax.set_yticks(np.arange(0, 7, 1))
        secax.tick_params(axis='y', labelsize=9)

    # -----------------------------
    # TITLE
    # -----------------------------
    title = f"{mode.upper()} | {access.upper()} | {coh.upper()}"

    ax.set_title(
        title,
        fontsize=12,
        fontweight='bold'
    )

    # -----------------------------
    # LEGEND
    # -----------------------------
    from matplotlib.lines import Line2D
    from matplotlib.patches import Patch

    legend_elements = [
        Patch(
            facecolor=solo_color,
            edgecolor='#1A1A2E',
            alpha=0.92,
            label='solo'
        ),
        Patch(
            facecolor=dma_color,
            edgecolor='#1A1A2E',
            alpha=0.92,
            label='s2_interf'
        ),
        Patch(
            facecolor=fpga_color,
            edgecolor='#1A1A2E',
            alpha=0.85,
            label='s2+s0_interf'
        ),
        Line2D(
            [0],
            [0],
            marker='o',
            color='w',
            markerfacecolor='white',
            markeredgecolor='#1A1A2E',
            markersize=6,
            linestyle='None',
            label='Mean'
        ),
        Line2D(
            [0],
            [0],
            color='#F08D39',
            linestyle='--',
            linewidth=2.5,
            label='Trendline'
        )
    ]

    ax.legend(
        handles=legend_elements,
        loc='upper left',
        bbox_to_anchor=(0.01, 0.99),
        fontsize=9,
        frameon=True,
        framealpha=0.9,
        edgecolor='#D0CEC8'
    )

    plt.tight_layout()

    out_file = os.path.join(
        out_dir,
        f"{mode}_{access}_{coh}.png"
    )

    plt.savefig(
        out_file,
        dpi=300,
        bbox_inches='tight'
    )

    plt.close()

    print(f"Saved: {out_file}")

# -----------------------------
# MAIN
# -----------------------------
if __name__ == "__main__":

    MODES = ["raw", "q95", "q99"]
    ACCESSES = ["read", "write"]
    COH = ["coherent", "non_coherent"]

    for mode in MODES:
        for access in ACCESSES:
            for coh in COH:

                print(f"Processing {mode} {access} {coh}")

                data = load_data(mode, access, coh)

                plot(mode, access, coh, data)