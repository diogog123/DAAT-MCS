import os
import re
import csv
import math
import argparse
from dataclasses import dataclass
from typing import Optional, Dict, List, Set, Tuple

import numpy as np

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

from matplotlib.offsetbox import AnnotationBbox, DrawingArea, TextArea, HPacker
from matplotlib.patches import Rectangle
from matplotlib.colors import ListedColormap, BoundaryNorm
from matplotlib.lines import Line2D

import networkx as nx


CPU_SEQUENCE = ["CPU0", "CPU1", "CPU2"]


# -------------------------
# Consistent config labeling
# -------------------------
CFG_LABEL_MAP = {
    "interf": "interf",
    "2_2_4-8": "c1",
    "2_4_2-8": "c2",
    "2_3_3-8": "c3",
    "3_2_3-8": "c4",
    "3_3_2-8": "c5",
    "4_2_2-8": "c6",
}


def cfg_label(cfg: str) -> str:
    return CFG_LABEL_MAP.get(cfg, cfg)


def cfg_sort_key(cfg: str, label_map: Dict[str, str]) -> tuple:
    if cfg == "interf":
        return (0, 0, cfg)
    lab = label_map.get(cfg, cfg)
    m = re.fullmatch(r"c(\d+)", str(lab))
    if m:
        return (1, int(m.group(1)), cfg)
    return (2, 10**9, cfg)


def order_cfg_list(cfg_set: Set[str]) -> List[str]:
    return sorted(cfg_set, key=lambda c: cfg_sort_key(c, CFG_LABEL_MAP))


# -------------------------
# Data loading / parsing
# -------------------------


def parse_cpu_checkpoints(filename: str) -> Dict[str, List[int]]:
    cpu_data: Dict[str, List[int]] = {}
    current_cpu: Optional[str] = None
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if line.startswith("CPU") and "checkpoints:" in line:
                current_cpu = line.split()[0]
                cpu_data[current_cpu] = []
            elif current_cpu and line and not line.startswith("=") and not line.startswith("Aggregated"):
                parts = line.split()
                numbers = [int(x) for x in parts if x.isdigit()]
                cpu_data[current_cpu].extend(numbers)
    return cpu_data


# Supports:
#   ...-C1_profile_0.txt
#   ...-C1_profile_0_cc.txt
#   ...-C1_profile_0_cc_<tag>.txt
# And tolerates missing _0 by making it optional.
_FILENAME_RE = re.compile(
    r"^linux_(?P<cpu0>.+?)_baremetal_cache_(?P<cpu1>.+?)_baremetal_embench_(?P<cpu2>[\w-]+)-C1_profile(?:_0)?"
    r"(?:_cc(?:_(?P<tag>.+))?)?\.txt$"
)


def parse_filename(filename: str) -> Optional[Tuple[str, str, str, Optional[str]]]:
    """Return (cpu0_bench, cpu1_bench, cpu2_bench, coloring_tag_or_None)."""
    m = _FILENAME_RE.match(filename)
    if not m:
        return None

    cpu0 = (m.group("cpu0") or "").rstrip("_")
    cpu1 = "cache_" + (m.group("cpu1") or "").rstrip("_")
    cpu2 = (m.group("cpu2") or "").rstrip("_")
    tag = m.group("tag")

    if not cpu0 or not cpu1 or not cpu2:
        return None

    return cpu0, cpu1, cpu2, tag


def load_all_files(dirs: List[str]) -> Dict[Tuple[str, str, str], Dict[str, Dict[str, List[int]]]]:
    """data[(cpu0_bench, cpu1_bench, cpu2_bench)][CPUx][config] = list_of_timestamps"""
    data: Dict[Tuple[str, str, str], Dict[str, Dict[str, List[int]]]] = {}
    for directory in dirs:
        if not os.path.isdir(directory):
            raise FileNotFoundError(f"Input directory not found: {directory}")

        for filename in os.listdir(directory):
            parsed = parse_filename(filename)
            if parsed is None:
                continue
            cpu0_b, cpu1_b, cpu2_b, tag = parsed

            filepath = os.path.join(directory, filename)
            checkpoint_data = parse_cpu_checkpoints(filepath)

            cfg = "interf" if tag is None else tag

            key = (cpu0_b, cpu1_b, cpu2_b)
            for cpu, checkpoints in checkpoint_data.items():
                data.setdefault(key, {}).setdefault(cpu, {})
                data[key][cpu][cfg] = checkpoints

    return data


def scan_benchmarks_from_dirs(dirs: List[str]) -> Dict[str, List[str]]:
    """Return dict: {'cpu0': [...], 'cpu1': [...], 'cpu2': [...]} parsed from filenames."""
    cpu0_set, cpu1_set, cpu2_set = set(), set(), set()

    for directory in dirs:
        if not os.path.isdir(directory):
            continue
        for filename in os.listdir(directory):
            parsed = parse_filename(filename)
            if parsed is None:
                continue
            cpu0_b, cpu1_b, cpu2_b, _tag = parsed
            cpu0_set.add(cpu0_b)
            cpu1_set.add(cpu1_b)
            cpu2_set.add(cpu2_b)

    return {"cpu0": sorted(cpu0_set), "cpu1": sorted(cpu1_set), "cpu2": sorted(cpu2_set)}


# -------------------------
# Metrics / delta model
# -------------------------


def metric_from_checkpoints(cpu_id: str, checkpoints: List[int]) -> Optional[float]:
    checkpoints_clean = [ts for ts in checkpoints if ts > 0]
    if not checkpoints_clean:
        return None
    if cpu_id == "CPU0":
        return float(np.sum(checkpoints_clean)) / 1000.0
    return float(len(checkpoints_clean))


def compute_baseline_delta_class(values: Dict[str, float], cpu_id: str, tau: float, tol_factor: float):
    cfgs = list(values.keys())
    arr = np.array([values[c] for c in cfgs], dtype=float)

    if cpu_id == "CPU0":
        b_idx = int(np.argmin(arr))
    else:
        b_idx = int(np.argmax(arr))

    baseline = float(arr[b_idx])
    baseline_cfg = cfgs[b_idx]

    delta: Dict[str, float] = {}
    klass: Dict[str, int] = {}
    for cfg in cfgs:
        v = float(values[cfg])
        if cpu_id == "CPU0":
            d = 100.0 * (v - baseline) / baseline
        else:
            d = 100.0 * (baseline - v) / baseline
        delta[cfg] = d

        if d <= tau:
            k = 0
        elif d <= tol_factor * tau:
            k = 1
        else:
            k = 2
        klass[cfg] = k

    return baseline, baseline_cfg, delta, klass


def compute_class(values: Dict[str, float], cpu_id: str, tau: float, tol_factor: float) -> Dict[str, int]:
    cfgs = list(values.keys())
    arr = np.array([values[c] for c in cfgs], dtype=float)

    if cpu_id == "CPU0":
        b_idx = int(np.argmin(arr))
    else:
        b_idx = int(np.argmax(arr))

    baseline = float(arr[b_idx])
    klass: Dict[str, int] = {}

    for cfg in cfgs:
        v = float(values[cfg])
        if cpu_id == "CPU0":
            d = 100.0 * (v - baseline) / baseline
        else:
            d = 100.0 * (baseline - v) / baseline

        if d <= tau:
            k = 0
        elif d <= tol_factor * tau:
            k = 1
        else:
            k = 2
        klass[cfg] = k

    return klass


# -------------------------
# Heatmap (cmap configurable)
# -------------------------

cpu_band_colors = {"CPU0": "tab:blue", "CPU1": "tab:orange", "CPU2": "tab:green"}


def plot_delta_grouped_heatmap(out_dir: str, cpu0_bench: str, delta_by_cpu: Dict[str, np.ndarray],
                              cfg_list: List[str], embench_list: List[str],
                              tau_by_cpu: Dict[str, float], tol_factor: float, cmap: str = "viridis") -> str:
    os.makedirs(out_dir, exist_ok=True)

    d0 = delta_by_cpu["CPU0"].T
    d1 = delta_by_cpu["CPU1"].T
    d2 = delta_by_cpu["CPU2"].T

    n_cfg = len(cfg_list)
    n_rows = len(embench_list)

    ft0 = float(tol_factor) * float(tau_by_cpu["CPU0"])
    ft1 = float(tol_factor) * float(tau_by_cpu["CPU1"])
    ft2 = float(tol_factor) * float(tau_by_cpu["CPU2"])

    ok = np.logical_and.reduce([
        np.isfinite(d0), np.isfinite(d1), np.isfinite(d2),
        d0 <= ft0, d1 <= ft1, d2 <= ft2
    ])

    d_int = np.maximum.reduce([d0, d1, d2])

    CPU_GROUPS = ["CPU0", "CPU1", "CPU2", "INT"]
    delta_all = np.concatenate([d0, d1, d2, d_int], axis=1)

    vmin, vmax = 0.0, 100.0
    fig_w = max(12.0, 0.55 * (n_cfg * len(CPU_GROUPS)))
    fig_h = max(7.0, 0.32 * n_rows)
    fig, ax = plt.subplots(figsize=(fig_w, fig_h))

    alpha = np.ones_like(delta_all, dtype=float)
    for y in range(delta_all.shape[0]):
        for x in range(delta_all.shape[1]):
            d = delta_all[y, x]
            if not np.isfinite(d):
                alpha[y, x] = 0.0
                continue
            group = x // n_cfg
            if CPU_GROUPS[group] != "INT":
                cpu = CPU_GROUPS[group]
                t = float(tau_by_cpu[cpu])
                t2 = float(tol_factor) * t
                cls = 0 if d <= t else (1 if d <= t2 else 2)
                if cls == 2:
                    alpha[y, x] = 0.25
            else:
                cfg_idx = x % n_cfg
                if not ok[y, cfg_idx]:
                    alpha[y, x] = 0.20

    im = ax.imshow(delta_all, aspect="auto", interpolation="nearest",
                   cmap=cmap, vmin=vmin, vmax=vmax, alpha=alpha)

    int_map = ok.astype(int)
    cmap_int = ListedColormap(["#f3a6a6", "#83e283"])
    norm_int = BoundaryNorm([-0.5, 0.5, 1.5], cmap_int.N)

    x0 = 3 * n_cfg - 0.5
    x1 = 4 * n_cfg - 0.5
    y0 = -0.5
    y1 = n_rows - 0.5

    ax.imshow(
        int_map,
        cmap=cmap_int,
        norm=norm_int,
        interpolation="nearest",
        aspect="auto",
        extent=(x0, x1, y1, y0),
        alpha=0.8,
        zorder=5,
    )

    norm = im.norm
    cmap_obj = im.cmap
    for y in range(n_rows):
        for x in range(n_cfg * len(CPU_GROUPS)):
            d = delta_all[y, x]
            if not np.isfinite(d):
                continue
            group = x // n_cfg
            cfg_idx = x % n_cfg

            if CPU_GROUPS[group] != "INT":
                cpu = CPU_GROUPS[group]
                t = float(tau_by_cpu[cpu])
                t2 = float(tol_factor) * t
                cls = 0 if d <= t else (1 if d <= t2 else 2)
                txt = str(cls)

                r, g, b, _ = cmap_obj(norm(d))
                luma = 0.299 * r + 0.587 * g + 0.114 * b
                txt_color = "black" if luma > 0.6 else "white"
            else:
                txt = "✓" if ok[y, cfg_idx] else "✗"
                txt_color = "black"

            ax.text(x, y, txt, ha="center", va="center", fontsize=10,
                    color=txt_color, zorder=10)

    ax.set_xlabel("")
    ax.set_yticks(np.arange(n_rows))
    ax.set_yticklabels(embench_list, fontsize=12)

    pretty_cfg = [cfg_label(cfg) for cfg in cfg_list]
    ax.set_xticks(np.arange(n_cfg * len(CPU_GROUPS)))
    ax.set_xticklabels(pretty_cfg * len(CPU_GROUPS), rotation=45, ha="center", fontsize=12)

    for g in range(1, len(CPU_GROUPS)):
        ax.axvline(x=g * n_cfg - 0.5, color="black", lw=2, alpha=0.95)
    ax.axvline(x=3 * n_cfg - 0.5, color="black", lw=2, alpha=0.95, zorder=6)

    trans = ax.get_xaxis_transform(which="grid")
    y_bracket = 1.02
    y_text = 1.06

    for g, name in enumerate(CPU_GROUPS):
        gx0 = g * n_cfg - 0.5
        gx1 = (g + 1) * n_cfg - 0.5
        gxc = (gx0 + gx1) / 2.0

        ax.plot([gx0, gx1], [y_bracket, y_bracket], transform=trans,
                color="black", lw=2.0, clip_on=False)
        ax.plot([gx0, gx0], [y_bracket, y_bracket - 0.02], transform=trans,
                color="black", lw=2.0, clip_on=False)
        ax.plot([gx1, gx1], [y_bracket, y_bracket - 0.02], transform=trans,
                color="black", lw=2.0, clip_on=False)

        if name in ("CPU0", "CPU1", "CPU2"):
            tau = float(tau_by_cpu[name])
            ftau = float(tol_factor) * tau
            label = f"{name}\nτ={tau:.1f}%, fτ={ftau:.1f}%"

            sq = DrawingArea(10, 10, 0, 0)
            sq.add_artist(Rectangle((0, 0), 10, 10,
                                    facecolor=cpu_band_colors[name],
                                    edgecolor="black", lw=0.5))
            txt = TextArea(label, textprops=dict(ha="center", va="bottom", fontsize=12))
            packed = HPacker(children=[sq, txt], align="center", pad=0, sep=4)

            ab = AnnotationBbox(
                packed, (gxc, y_text),
                xycoords=trans,
                box_alignment=(0.5, 0.0),
                frameon=True,
                pad=0.4,
                bboxprops=dict(facecolor="white", edgecolor="none", alpha=0.85),
                clip_on=False,
            )
            ax.add_artist(ab)
        else:
            label = "Acceptability\nIntersection"
            ax.text(gxc, y_text, label, transform=trans,
                    ha="center", va="bottom", fontsize=12,
                    bbox=dict(facecolor="white", edgecolor="none", alpha=0.85, pad=2.0),
                    clip_on=False)

    plt.tight_layout(rect=(0, 0, 1, 0.95))

    cbar = fig.colorbar(im, ax=ax, shrink=0.85, pad=0.04)
    cbar.set_label("Δ (%)", rotation=0, labelpad=-35, y=1.05, fontsize=12)
    cbar.set_ticks([0, 20, 40, 60, 80, 100])

    cbar.ax.yaxis.set_ticks_position("left")
    cbar.ax.yaxis.set_label_position("left")
    cbar.ax.tick_params(labelleft=True, labelright=False)

    fig.canvas.draw()
    pos = cbar.ax.get_position()
    gap = 0.006
    w2 = pos.width * 0.55
    cax2 = fig.add_axes([pos.x1 + gap, pos.y0, w2, pos.height])
    cax2.set_facecolor("white")
    cax2.set_xlim(0, 1)
    cax2.set_ylim(cbar.ax.get_ylim())
    cax2.set_xticks([])
    cax2.set_yticks([])

    for spine in cax2.spines.values():
        spine.set_visible(True)
        spine.set_alpha(0.3)

    for cpu in ("CPU0", "CPU1", "CPU2"):
        t = float(tau_by_cpu[cpu])
        t2 = float(tol_factor) * t
        ylo, yhi = cbar.ax.get_ylim()
        yy0 = max(ylo, min(t, yhi))
        yy1 = max(ylo, min(t2, yhi))
        if yy1 > yy0:
            cax2.axhspan(yy0, yy1, xmin=0.0, xmax=1.0,
                         color=cpu_band_colors[cpu], alpha=0.9)

    out = os.path.join(out_dir, f"heatmap_{cpu0_bench}.png")
    plt.savefig(out, dpi=220)
    plt.close(fig)
    return out


# -------------------------
# Ridgeline (minimal)
# -------------------------


def _gaussian_kernel1d(sigma: float, radius: Optional[int] = None) -> np.ndarray:
    if sigma <= 0:
        return np.array([1.0])
    if radius is None:
        radius = int(max(3, np.ceil(3 * sigma)))
    x = np.arange(-radius, radius + 1)
    k = np.exp(-(x**2) / (2 * sigma**2))
    k /= np.sum(k)
    return k


def _smooth(y: np.ndarray, sigma_bins: float = 1.2) -> np.ndarray:
    k = _gaussian_kernel1d(sigma_bins)
    return np.convolve(y, k, mode="same")


def _density_from_samples(samples: np.ndarray, xgrid: np.ndarray, bins: int = 80) -> np.ndarray:
    if len(samples) == 0:
        return np.zeros_like(xgrid)
    hist, edges = np.histogram(samples, bins=bins, range=(xgrid[0], xgrid[-1]), density=True)
    centers = 0.5 * (edges[:-1] + edges[1:])
    hist_s = _smooth(hist, sigma_bins=1.3)
    return np.interp(xgrid, centers, hist_s, left=0.0, right=0.0)


def draw_ridgeline(ax, cpu_id: str, cfg_list: List[str], delta_mat: np.ndarray, class_mat: np.ndarray,
                  tau: float, tol_factor: float) -> None:
    finite = delta_mat[np.isfinite(delta_mat)]
    if finite.size == 0:
        raise ValueError(f"No finite delta values for {cpu_id}")

    x_min = 0.0
    x_max = max(100.0, tol_factor * tau * 1.2)
    xgrid = np.linspace(x_min, x_max, 400)

    ax.axvspan(0, tau, color="#2ca02c", alpha=0.10, lw=0)
    ax.axvspan(tau, tol_factor * tau, color="#ffbf00", alpha=0.10, lw=0)
    ax.axvspan(tol_factor * tau, x_max, color="#d62728", alpha=0.06, lw=0)
    ax.axvline(tau, color="#2ca02c", lw=1.0, alpha=0.8)
    ax.axvline(tol_factor * tau, color="#d62728", lw=1.0, alpha=0.8)

    ridge_scale = 0.8
    for i in range(len(cfg_list)):
        samples = delta_mat[i, :]
        samples = samples[np.isfinite(samples)]
        if samples.size == 0:
            continue

        dens = _density_from_samples(samples, xgrid, bins=90)
        if dens.max() > 0:
            dens = dens / dens.max()

        y0 = i
        y = y0 + ridge_scale * dens
        ax.fill_between(xgrid, y0, y, color="#1f77b4", alpha=0.25, linewidth=0.8)
        ax.plot(xgrid, y, color="#1f77b4", alpha=0.7, linewidth=0.8)

    ax.set_title(cpu_id)
    ax.set_xlim(x_min, x_max)
    ax.grid(axis="x", linestyle="--", linewidth=0.4, alpha=0.5)


def plot_ridgeline_3cpus(path: str, cpu0_bench: str, cfg_list: List[str],
                        delta_by_cpu: Dict[str, np.ndarray], class_by_cpu: Dict[str, np.ndarray],
                        tau: Dict[str, float], tol_factor: float) -> str:
    fig, axes = plt.subplots(1, 3, figsize=(10, 1.8), sharey=True, constrained_layout=True)

    for ax, cpu_id in zip(axes, ["CPU0", "CPU1", "CPU2"]):
        draw_ridgeline(ax, cpu_id, cfg_list, delta_by_cpu[cpu_id], class_by_cpu[cpu_id], tau[cpu_id], tol_factor)

    config_names = [cfg_label(cfg) for cfg in cfg_list]
    axes[0].set_ylabel(cpu0_bench)
    axes[0].set_yticks(np.arange(len(cfg_list)))
    axes[0].set_yticklabels(config_names, fontsize=10)
    for ax in axes[1:]:
        ax.tick_params(labelleft=False)

    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    plt.savefig(path, dpi=220)
    plt.close(fig)
    return path


# -------------------------
# Decision trees (style configurable)
# -------------------------


@dataclass
class TreesStyle:
    edge_color_0: str = "#2ca02c"
    edge_color_1: str = "#ffbf00"
    edge_color_2: str = "#7f7f7f"
    edge_alpha_0: float = 0.80
    edge_alpha_1: float = 0.80
    edge_alpha_2: float = 0.50
    edge_width_0: float = 1.6
    edge_width_1: float = 1.6
    edge_width_2: float = 1.2

    node_color: str = "#5c7a8a"
    node_alpha_ok: float = 0.95
    node_alpha_bad: float = 0.30
    node_alpha_shadow: float = 0.15
    node_size: int = 600

    def edge_color_map(self) -> Dict[int, str]:
        return {0: self.edge_color_0, 1: self.edge_color_1, 2: self.edge_color_2}

    def edge_alpha_map(self) -> Dict[int, float]:
        return {0: float(self.edge_alpha_0), 1: float(self.edge_alpha_1), 2: float(self.edge_alpha_2)}

    def edge_width_map(self) -> Dict[int, float]:
        return {0: float(self.edge_width_0), 1: float(self.edge_width_1), 2: float(self.edge_width_2)}


DEFAULT_TREES_STYLE = TreesStyle()


def _cls_int_or_none(x) -> Optional[int]:
    if x is None or not np.isfinite(x):
        return None
    return int(x)


def layered_positions(G, ordered_cfg: List[str], layer_x: Optional[Dict[int, float]] = None) -> Dict[str, np.ndarray]:
    horizontal_spacing = 0.5
    if layer_x is None:
        layer_x = {0: 0.0, 1: horizontal_spacing, 2: 2 * horizontal_spacing, 3: 3 * horizontal_spacing}

    y_of_cfg = {cfg: float(len(ordered_cfg) - 1 - i) for i, cfg in enumerate(ordered_cfg)}

    pos: Dict[str, np.ndarray] = {}
    for n, attrs in G.nodes(data=True):
        layer = attrs.get("layer", 0)
        x = layer_x.get(layer, float(layer))
        if n == "ROOT":
            y = (len(ordered_cfg) - 1) / 2.0 if len(ordered_cfg) else 0.0
        else:
            cfg = n.split("_", 1)[1] if "_" in n else n
            y = y_of_cfg.get(cfg, 0.0)
        pos[n] = np.array([x, y], dtype=float)

    return pos


def build_decision_tree_for_benchmark(class_by_cpu: Dict[str, np.ndarray], eb_idx: int,
                                     cfg_list: List[str], embench_list: List[str],
                                     style: TreesStyle):
    eb_name = embench_list[eb_idx]

    c0 = class_by_cpu["CPU0"][:, eb_idx]
    c1 = class_by_cpu["CPU1"][:, eb_idx]
    c2 = class_by_cpu["CPU2"][:, eb_idx]

    cls0 = {cfg_list[i]: _cls_int_or_none(c0[i]) for i in range(len(cfg_list))}
    cls1 = {cfg_list[i]: _cls_int_or_none(c1[i]) for i in range(len(cfg_list))}
    cls2 = {cfg_list[i]: _cls_int_or_none(c2[i]) for i in range(len(cfg_list))}

    G = nx.DiGraph()
    root = "ROOT"
    G.add_node(root, layer=0, label="", node_alpha=1.0)

    for cfg in cfg_list:
        k0 = cls0.get(cfg)
        if k0 is None:
            continue
        node_alpha = style.node_alpha_ok if k0 <= 1 else style.node_alpha_bad
        G.add_node(f"L0_{cfg}", layer=1, label=cfg_label(cfg), node_alpha=node_alpha, cls=k0)
        G.add_edge(root, f"L0_{cfg}", cls=k0)

    for cfg in cfg_list:
        k1 = cls1.get(cfg)
        if k1 is None:
            continue
        k0 = cls0.get(cfg)
        if k0 is None or k0 == 2:
            node_alpha = style.node_alpha_shadow
            node_cls = 2
        else:
            node_alpha = style.node_alpha_ok if k1 <= 1 else style.node_alpha_bad
            node_cls = k1
        G.add_node(f"L1_{cfg}", layer=2, label=cfg_label(cfg), node_alpha=node_alpha, cls=node_cls)
        if k0 is not None and k0 <= 1:
            G.add_edge(f"L0_{cfg}", f"L1_{cfg}", cls=k1)

    for cfg in cfg_list:
        k2 = cls2.get(cfg)
        if k2 is None:
            continue
        k1 = cls1.get(cfg)
        k0 = cls0.get(cfg)
        reachable = (k0 is not None and k0 <= 1 and k1 is not None and k1 <= 1)
        if not reachable:
            node_alpha = style.node_alpha_shadow
            node_cls = 2
        else:
            node_alpha = style.node_alpha_ok if k2 <= 1 else style.node_alpha_bad
            node_cls = k2
        G.add_node(f"L2_{cfg}", layer=3, label=cfg_label(cfg), node_alpha=node_alpha, cls=node_cls)
        if reachable:
            G.add_edge(f"L1_{cfg}", f"L2_{cfg}", cls=k2)

    ordered_cfg = sorted(cfg_list, key=lambda c: cfg_sort_key(c, CFG_LABEL_MAP))
    return G, eb_name, ordered_cfg


def _draw_nodes_by_alpha(ax, G, pos, nodes: List[str], style: TreesStyle, alpha: float, node_size: int) -> None:
    if not nodes:
        return
    nx.draw_networkx_nodes(
        G, pos, nodelist=nodes, node_size=node_size, node_color=style.node_color,
        alpha=alpha, linewidths=0.5, edgecolors="#4d4d4d", ax=ax
    )


def _draw_edges_by_class(ax, G, pos, edgelist, cls: int, style: TreesStyle) -> None:
    if not edgelist:
        return
    ec = style.edge_color_map()[int(cls)]
    ea = style.edge_alpha_map()[int(cls)]
    ew = style.edge_width_map()[int(cls)]
    nx.draw_networkx_edges(G, pos, edgelist=edgelist, edge_color=ec, width=ew,
                           alpha=ea, arrows=True, arrowsize=10, ax=ax)


def plot_trees_grid(out_path: str, class_by_cpu: Dict[str, np.ndarray], cfg_list: List[str], embench_list: List[str],
                   trees_per_row: int = 11, style: Optional[TreesStyle] = None) -> str:
    style = style or DEFAULT_TREES_STYLE

    n_embench = len(embench_list)
    n_cols = int(trees_per_row)
    n_rows = int(math.ceil(n_embench / n_cols))

    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    fig, axes = plt.subplots(n_rows, n_cols, figsize=(5 * n_cols, 3 * n_rows), squeeze=False)

    for k in range(n_rows * n_cols):
        r, c = divmod(k, n_cols)
        ax = axes[r, c]
        if k >= n_embench:
            ax.axis("off")
            continue

        eb_idx = k
        G, eb_name, ordered_cfg = build_decision_tree_for_benchmark(class_by_cpu, eb_idx, cfg_list, embench_list, style)
        pos = layered_positions(G, ordered_cfg)

        ax.set_xlim(-0.3, 2.1)
        ax.set_ylim(-0.5, len(ordered_cfg) - 0.5)

        root = [n for n in G.nodes if G.nodes[n].get("layer") == 0]
        ok_nodes = [n for n in G.nodes if n not in root and G.nodes[n].get("node_alpha", 1.0) >= style.node_alpha_ok]
        bad_nodes = [n for n in G.nodes if n not in root and style.node_alpha_shadow < G.nodes[n].get("node_alpha", 1.0) < style.node_alpha_ok]
        shadow_nodes = [n for n in G.nodes if n not in root and G.nodes[n].get("node_alpha", 1.0) <= style.node_alpha_shadow]

        _draw_nodes_by_alpha(ax, G, pos, root, style, alpha=1.0, node_size=style.node_size)
        _draw_nodes_by_alpha(ax, G, pos, ok_nodes, style, alpha=style.node_alpha_ok, node_size=style.node_size)
        _draw_nodes_by_alpha(ax, G, pos, bad_nodes, style, alpha=style.node_alpha_bad, node_size=style.node_size)
        _draw_nodes_by_alpha(ax, G, pos, shadow_nodes, style, alpha=style.node_alpha_shadow, node_size=style.node_size)

        for cls in [0, 1, 2]:
            ed = [(u, v) for (u, v, d) in G.edges(data=True) if int(d["cls"]) == cls]
            _draw_edges_by_class(ax, G, pos, ed, cls=cls, style=style)

        labels = {n: G.nodes[n].get("label", n) for n in G.nodes}
        for n, txt in labels.items():
            if n == "ROOT":
                fc = "black"
            else:
                a = G.nodes[n].get("node_alpha", 1.0)
                fc = "white" if a >= style.node_alpha_ok else "black"
            nx.draw_networkx_labels(G, pos, labels={n: txt}, font_size=12, font_color=fc, ax=ax, clip_on=True)

        ax.set_title(eb_name, fontsize=15)
        ax.axis("off")

    legend = [
        Line2D([0], [0], color=style.edge_color_map()[0], lw=3, label="class 0"),
        Line2D([0], [0], color=style.edge_color_map()[1], lw=3, label="class 1"),
        Line2D([0], [0], color=style.edge_color_map()[2], lw=3, alpha=style.edge_alpha_map()[2], label="class 2 (ignored)"),
    ]
    fig.legend(handles=legend, loc="lower center", ncol=3, frameon=False, fontsize=15)

    plt.tight_layout(rect=(0, 0.05, 1, 1))
    plt.savefig(out_path, dpi=220)
    plt.close(fig)
    return out_path


# -------------------------
# PlotSuite
# -------------------------


class PlotSuite:
    def __init__(self, data):
        self.data = data

    def _keys(self, cpu0bench: str, cpu1bench: Optional[str], cpu2_subset: Optional[Set[str]]):
        keys = []
        for (b0, b1, b2) in self.data.keys():
            if b0 != cpu0bench:
                continue
            if cpu1bench is not None and b1 != cpu1bench:
                continue
            if cpu2_subset is not None and b2 not in cpu2_subset:
                continue
            keys.append((b0, b1, b2))

        if not keys:
            raise SystemExit(
                f"No entries found for cpu0={cpu0bench}, cpu1={cpu1bench}, cpu2_subset={None if cpu2_subset is None else len(cpu2_subset)}"
            )

        cpu1_set = sorted({b1 for (_, b1, _) in keys})
        if cpu1bench is None and len(cpu1_set) > 1:
            raise SystemExit(
                f"Multiple CPU1 benches exist for cpu0={cpu0bench}: {cpu1_set}. Please specify --cpu1bench or select one in the GUI."
            )

        if cpu1bench is None:
            cpu1bench = cpu1_set[0]

        embench_list = sorted({b2 for (_, _, b2) in keys})

        cfg_set = set()
        for k in keys:
            for cpu in CPU_SEQUENCE:
                cfg_set |= set(self.data[k].get(cpu, {}).keys())
        cfg_list = order_cfg_list(cfg_set)

        return cpu1bench, embench_list, cfg_list

    def build_matrices(self, cpu0bench: str, cpu1bench: Optional[str], cpu2_subset: Optional[Set[str]],
                      tau_by_cpu: Dict[str, float], tol_factor: float):
        cpu1bench, embench_list, cfg_list = self._keys(cpu0bench, cpu1bench, cpu2_subset)

        delta_by_cpu = {}
        class_by_cpu = {}

        for cpu_id in CPU_SEQUENCE:
            delta_mat = np.full((len(cfg_list), len(embench_list)), np.nan, dtype=float)
            class_mat = np.full((len(cfg_list), len(embench_list)), np.nan, dtype=float)

            for j, eb in enumerate(embench_list):
                cpu_cfg_metrics = {}
                cpu_data = self.data.get((cpu0bench, cpu1bench, eb), {}).get(cpu_id, {})

                for cfg, ckpts in cpu_data.items():
                    m = metric_from_checkpoints(cpu_id, ckpts)
                    if m is not None:
                        cpu_cfg_metrics[cfg] = m

                if not cpu_cfg_metrics:
                    continue

                _, _, dmap, kmap = compute_baseline_delta_class(cpu_cfg_metrics, cpu_id, tau_by_cpu[cpu_id], tol_factor)

                for i, cfg in enumerate(cfg_list):
                    if cfg in dmap:
                        delta_mat[i, j] = dmap[cfg]
                        class_mat[i, j] = kmap[cfg]

            delta_by_cpu[cpu_id] = delta_mat
            class_by_cpu[cpu_id] = class_mat

        return embench_list, cfg_list, delta_by_cpu, class_by_cpu

    def build_class_matrices(self, cpu0bench: str, cpu1bench: Optional[str], cpu2_subset: Optional[Set[str]],
                            tau_by_cpu: Dict[str, float], tol_factor: float):
        cpu1bench, embench_list, cfg_list = self._keys(cpu0bench, cpu1bench, cpu2_subset)

        class_by_cpu = {}
        for cpu_id in CPU_SEQUENCE:
            class_mat = np.full((len(cfg_list), len(embench_list)), np.nan, dtype=float)

            for j, eb in enumerate(embench_list):
                cpu_cfg_metrics = {}
                cpu_data = self.data.get((cpu0bench, cpu1bench, eb), {}).get(cpu_id, {})

                for cfg, ckpts in cpu_data.items():
                    m = metric_from_checkpoints(cpu_id, ckpts)
                    if m is not None:
                        cpu_cfg_metrics[cfg] = m

                if not cpu_cfg_metrics:
                    continue

                kmap = compute_class(cpu_cfg_metrics, cpu_id, tau_by_cpu[cpu_id], tol_factor)
                for i, cfg in enumerate(cfg_list):
                    if cfg in kmap:
                        class_mat[i, j] = kmap[cfg]

            class_by_cpu[cpu_id] = class_mat

        return embench_list, cfg_list, class_by_cpu


# -------------------------
# Auto-tune (detect + rank)
# -------------------------


def detect_configs_in_scope(data, cpu0_list: List[str], cpu1bench: str, cpu2_set: Set[str]) -> List[str]:
    cfgs = set()
    for (b0, b1, b2), per_cpu in data.items():
        if b0 not in cpu0_list:
            continue
        if b1 != cpu1bench:
            continue
        if b2 not in cpu2_set:
            continue
        for cpu in CPU_SEQUENCE:
            cfgs |= set(per_cpu.get(cpu, {}).keys())
    return sorted(cfgs, key=lambda c: cfg_sort_key(c, CFG_LABEL_MAP))


def rank_configs_for_autotune(suite: PlotSuite, cpu0_list: List[str], cpu1bench: str, cpu2_set: Set[str],
                             tau: Dict[str, float], tol_factor: float):
    """Rank configs.

    Objective:
      - Primary: maximize acceptability rate (all CPUs class<=1)
      - Secondary: minimize mean delta CPU0
      - Tertiary: minimize worst mean delta across CPUs
    """
    rows = []

    for cpu0bench in cpu0_list:
        embench_list, cfg_list, delta_by_cpu, class_by_cpu = suite.build_matrices(
            cpu0bench, cpu1bench, cpu2_set, tau, tol_factor
        )

        c0 = class_by_cpu["CPU0"]
        c1 = class_by_cpu["CPU1"]
        c2 = class_by_cpu["CPU2"]

        ok = np.isfinite(c0) & np.isfinite(c1) & np.isfinite(c2) & (c0 <= 1) & (c1 <= 1) & (c2 <= 1)

        d0 = delta_by_cpu["CPU0"]
        d1 = delta_by_cpu["CPU1"]
        d2 = delta_by_cpu["CPU2"]

        for i, cfg in enumerate(cfg_list):
            total = int(np.sum(np.isfinite(c0[i, :]) & np.isfinite(c1[i, :]) & np.isfinite(c2[i, :])))
            accepted = int(np.sum(ok[i, :]))
            accept_rate = 0.0 if total == 0 else (100.0 * accepted / total)

            mean_d0 = float(np.nanmean(d0[i, :])) if np.isfinite(d0[i, :]).any() else float("nan")
            mean_d1 = float(np.nanmean(d1[i, :])) if np.isfinite(d1[i, :]).any() else float("nan")
            mean_d2 = float(np.nanmean(d2[i, :])) if np.isfinite(d2[i, :]).any() else float("nan")
            worst_mean = float(np.nanmax([mean_d0, mean_d1, mean_d2]))

            rows.append({
                "cpu0bench": cpu0bench,
                "cfg": cfg,
                "cfg_label": cfg_label(cfg),
                "accept_rate": accept_rate,
                "mean_d0": mean_d0,
                "mean_d1": mean_d1,
                "mean_d2": mean_d2,
                "worst_mean": worst_mean,
                "total": total,
                "accepted": accepted,
            })

    def key(r):
        return (-r["accept_rate"], r["mean_d0"], r["worst_mean"], r["cfg"])

    return sorted(rows, key=key)


# -------------------------
# Tkinter GUI
# -------------------------


def launch_gui():
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox
    from tkinter.colorchooser import askcolor
    import threading

    def _is_hex_color(s: str) -> bool:
        if not isinstance(s, str):
            return False
        if not s.startswith("#"):
            return False
        if len(s) != 7:
            return False
        try:
            int(s[1:], 16)
            return True
        except ValueError:
            return False

    class PlotterGUI:
        def __init__(self, master):
            self.master = master
            master.title("DAAT-MCS Tuner GUI")

            # Bigger default + minimum so buttons don't get clipped
            master.geometry("1400x950")
            master.minsize(1200, 850)

            # I/O
            self.interf_dir = tk.StringVar()
            self.cc_dir = tk.StringVar()
            self.outdir = tk.StringVar(value="./output")

            # Plot types (multi-select)
            self.plt_heatmap = tk.BooleanVar(value=True)
            self.plt_ridgeline = tk.BooleanVar(value=True)
            self.plt_trees = tk.BooleanVar(value=True)

            # Tolerances
            self.cpu0tol = tk.DoubleVar(value=5.0)
            self.cpu1tol = tk.DoubleVar(value=10.0)
            self.cpu2tol = tk.DoubleVar(value=10.0)
            self.tolfactor = tk.DoubleVar(value=1.5)

            # Heatmap settings
            self.hm_cmap = tk.StringVar(value="viridis")

            # Trees settings
            self.tr_treesperrow = tk.IntVar(value=11)
            self.tr_edge_c0 = tk.StringVar(value=DEFAULT_TREES_STYLE.edge_color_0)
            self.tr_edge_c1 = tk.StringVar(value=DEFAULT_TREES_STYLE.edge_color_1)
            self.tr_edge_c2 = tk.StringVar(value=DEFAULT_TREES_STYLE.edge_color_2)
            self.tr_edge_a0 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_alpha_0)
            self.tr_edge_a1 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_alpha_1)
            self.tr_edge_a2 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_alpha_2)
            self.tr_edge_w0 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_width_0)
            self.tr_edge_w1 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_width_1)
            self.tr_edge_w2 = tk.DoubleVar(value=DEFAULT_TREES_STYLE.edge_width_2)
            self.tr_node_color = tk.StringVar(value=DEFAULT_TREES_STYLE.node_color)
            self.tr_node_a_ok = tk.DoubleVar(value=DEFAULT_TREES_STYLE.node_alpha_ok)
            self.tr_node_a_bad = tk.DoubleVar(value=DEFAULT_TREES_STYLE.node_alpha_bad)
            self.tr_node_a_shadow = tk.DoubleVar(value=DEFAULT_TREES_STYLE.node_alpha_shadow)
            self.tr_node_size = tk.IntVar(value=DEFAULT_TREES_STYLE.node_size)

            self.status = tk.StringVar(value="Ready")
            self._build_ui(askcolor, _is_hex_color)

        def _build_ui(self, askcolor, is_hex):
            nb = ttk.Notebook(self.master)
            nb.pack(fill="both", expand=True, padx=10, pady=10)

            tab_run = ttk.Frame(nb)
            tab_heatmap = ttk.Frame(nb)
            tab_trees = ttk.Frame(nb)

            nb.add(tab_run, text="Run")
            nb.add(tab_heatmap, text="Heatmap")
            nb.add(tab_trees, text="Trees")

            # --- Run tab ---
            frame_dirs = ttk.LabelFrame(tab_run, text="Data Directories", padding=10)
            frame_dirs.pack(fill="x", padx=10, pady=5)

            ttk.Label(frame_dirs, text="Interference Dir:").grid(row=0, column=0, sticky="w")
            ttk.Entry(frame_dirs, textvariable=self.interf_dir, width=86).grid(row=0, column=1, padx=5)
            ttk.Button(frame_dirs, text="Browse...", command=self.browse_interf).grid(row=0, column=2)

            ttk.Label(frame_dirs, text="Cache Coloring Dir:").grid(row=1, column=0, sticky="w")
            ttk.Entry(frame_dirs, textvariable=self.cc_dir, width=86).grid(row=1, column=1, padx=5)
            ttk.Button(frame_dirs, text="Browse...", command=self.browse_cc).grid(row=1, column=2)

            ttk.Button(frame_dirs, text="Scan Benchmarks", command=self.scan_benchmarks).grid(row=2, column=1, pady=10, sticky="w")

            frame_bench = ttk.LabelFrame(tab_run, text="Benchmark Selection", padding=10)
            frame_bench.pack(fill="both", expand=True, padx=10, pady=5)

            ttk.Label(frame_bench, text="CPU0 (MiBench)\n(multi-select)").grid(row=0, column=0, sticky="nw", padx=5)
            self.lb_cpu0 = tk.Listbox(frame_bench, height=14, selectmode="multiple", exportselection=False)
            self.lb_cpu0.grid(row=1, column=0, sticky="nsew", padx=5)
            fr0 = ttk.Frame(frame_bench)
            fr0.grid(row=2, column=0, sticky="ew", padx=5, pady=2)
            ttk.Button(fr0, text="Select All", command=lambda: self.select_all(self.lb_cpu0)).pack(side="left", fill="x", expand=True)
            ttk.Button(fr0, text="Unselect All", command=lambda: self.unselect_all(self.lb_cpu0)).pack(side="left", fill="x", expand=True, padx=6)

            ttk.Label(frame_bench, text="CPU1 (cache app)\n(select exactly 1)").grid(row=0, column=1, sticky="nw", padx=5)
            self.lb_cpu1 = tk.Listbox(frame_bench, height=14, selectmode="multiple", exportselection=False)
            self.lb_cpu1.grid(row=1, column=1, sticky="nsew", padx=5)
            fr1 = ttk.Frame(frame_bench)
            fr1.grid(row=2, column=1, sticky="ew", padx=5, pady=2)
            ttk.Button(fr1, text="Select All", command=lambda: self.select_all(self.lb_cpu1)).pack(side="left", fill="x", expand=True)
            ttk.Button(fr1, text="Unselect All", command=lambda: self.unselect_all(self.lb_cpu1)).pack(side="left", fill="x", expand=True, padx=6)

            ttk.Label(frame_bench, text="CPU2 (Embench)\n(multi-select)").grid(row=0, column=2, sticky="nw", padx=5)
            self.lb_cpu2 = tk.Listbox(frame_bench, height=14, selectmode="multiple", exportselection=False)
            self.lb_cpu2.grid(row=1, column=2, sticky="nsew", padx=5)
            fr2 = ttk.Frame(frame_bench)
            fr2.grid(row=2, column=2, sticky="ew", padx=5, pady=2)
            ttk.Button(fr2, text="Select All", command=lambda: self.select_all(self.lb_cpu2)).pack(side="left", fill="x", expand=True)
            ttk.Button(fr2, text="Unselect All", command=lambda: self.unselect_all(self.lb_cpu2)).pack(side="left", fill="x", expand=True, padx=6)

            frame_bench.columnconfigure(0, weight=1)
            frame_bench.columnconfigure(1, weight=1)
            frame_bench.columnconfigure(2, weight=1)
            frame_bench.rowconfigure(1, weight=1)

            frame_tol = ttk.LabelFrame(tab_run, text="Tolerances (%)", padding=10)
            frame_tol.pack(fill="x", padx=10, pady=5)

            ttk.Label(frame_tol, text="CPU0 τ:").grid(row=0, column=0, sticky="w")
            ttk.Entry(frame_tol, textvariable=self.cpu0tol, width=10).grid(row=0, column=1, sticky="w")
            ttk.Label(frame_tol, text="CPU1 τ:").grid(row=0, column=2, sticky="w", padx=(20, 0))
            ttk.Entry(frame_tol, textvariable=self.cpu1tol, width=10).grid(row=0, column=3, sticky="w")
            ttk.Label(frame_tol, text="CPU2 τ:").grid(row=1, column=0, sticky="w")
            ttk.Entry(frame_tol, textvariable=self.cpu2tol, width=10).grid(row=1, column=1, sticky="w")
            ttk.Label(frame_tol, text="Tolerance Factor:").grid(row=1, column=2, sticky="w", padx=(20, 0))
            ttk.Entry(frame_tol, textvariable=self.tolfactor, width=10).grid(row=1, column=3, sticky="w")

            frame_plot = ttk.LabelFrame(tab_run, text="Plot Types (multi-select)", padding=10)
            frame_plot.pack(fill="x", padx=10, pady=5)
            ttk.Checkbutton(frame_plot, text="Heatmap", variable=self.plt_heatmap).pack(anchor="w")
            ttk.Checkbutton(frame_plot, text="Ridgeline", variable=self.plt_ridgeline).pack(anchor="w")
            ttk.Checkbutton(frame_plot, text="Decision Trees", variable=self.plt_trees).pack(anchor="w")

            frame_out = ttk.LabelFrame(tab_run, text="Output", padding=10)
            frame_out.pack(fill="x", padx=10, pady=5)
            ttk.Label(frame_out, text="Output Directory:").grid(row=0, column=0, sticky="w")
            ttk.Entry(frame_out, textvariable=self.outdir, width=86).grid(row=0, column=1, padx=5)
            ttk.Button(frame_out, text="Browse...", command=self.browse_outdir).grid(row=0, column=2)

            frame_run = ttk.Frame(tab_run, padding=10)
            frame_run.pack(fill="x", padx=10, pady=5)
            self.btn_run = ttk.Button(frame_run, text="Generate Plot(s)", command=self.run_plot)
            self.btn_run.pack(side="left")
            self.btn_autotune = ttk.Button(frame_run, text="Auto-tune", command=self.open_autotune)
            self.btn_autotune.pack(side="left", padx=12)

            frame_status = ttk.Frame(tab_run)
            frame_status.pack(fill="x", side="bottom", padx=10, pady=5)
            ttk.Label(frame_status, text="Status:").pack(side="left")
            ttk.Label(frame_status, textvariable=self.status, relief="sunken").pack(side="left", fill="x", expand=True, padx=5)
            self.progress = ttk.Progressbar(tab_run, mode="indeterminate")
            self.progress.pack(fill="x", padx=10, pady=5)

            # --- Heatmap tab ---
            hm = ttk.LabelFrame(tab_heatmap, text="Heatmap settings", padding=10)
            hm.pack(fill="x", padx=10, pady=10)

            ttk.Label(hm, text="Colormap name (--cmap):").grid(row=0, column=0, sticky="w")
            ttk.Entry(hm, textvariable=self.hm_cmap, width=24).grid(row=0, column=1, sticky="w", padx=6)
            ttk.Label(hm, text="Examples: viridis, plasma, inferno, magma, cividis").grid(row=1, column=0, columnspan=2, sticky="w")

            # --- Trees tab ---
            tr = ttk.LabelFrame(tab_trees, text="Decision tree settings", padding=10)
            tr.pack(fill="both", expand=True, padx=10, pady=10)

            ttk.Label(tr, text="Trees per row (--treesperrow):").grid(row=0, column=0, sticky="w")
            ttk.Entry(tr, textvariable=self.tr_treesperrow, width=10).grid(row=0, column=1, sticky="w", padx=6)

            sep = ttk.Separator(tr, orient="horizontal")
            sep.grid(row=1, column=0, columnspan=6, sticky="ew", pady=10)

            def color_row(r, label, var):
                ttk.Label(tr, text=label).grid(row=r, column=0, sticky="w")
                ttk.Entry(tr, textvariable=var, width=12).grid(row=r, column=1, sticky="w", padx=6)

                def pick():
                    c = askcolor(title=f"Pick {label}")
                    if c and c[1]:
                        var.set(c[1])

                ttk.Button(tr, text="Pick…", command=pick).grid(row=r, column=2, sticky="w")

                def validate():
                    if not is_hex(var.get()):
                        from tkinter import messagebox
                        messagebox.showwarning("Invalid color", f"{label} must be a hex color like #RRGGBB")

                ttk.Button(tr, text="Validate", command=validate).grid(row=r, column=3, sticky="w", padx=6)

            color_row(2, "EDGE_COLOR[0]", self.tr_edge_c0)
            color_row(3, "EDGE_COLOR[1]", self.tr_edge_c1)
            color_row(4, "EDGE_COLOR[2]", self.tr_edge_c2)
            color_row(6, "NODE_COLOR", self.tr_node_color)

            ttk.Label(tr, text="EDGE_ALPHA[0]").grid(row=2, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_edge_a0, width=8).grid(row=2, column=5, sticky="w")
            ttk.Label(tr, text="EDGE_ALPHA[1]").grid(row=3, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_edge_a1, width=8).grid(row=3, column=5, sticky="w")
            ttk.Label(tr, text="EDGE_ALPHA[2]").grid(row=4, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_edge_a2, width=8).grid(row=4, column=5, sticky="w")

            ttk.Label(tr, text="EDGE_WIDTH[0]").grid(row=8, column=0, sticky="w")
            ttk.Entry(tr, textvariable=self.tr_edge_w0, width=8).grid(row=8, column=1, sticky="w", padx=6)
            ttk.Label(tr, text="EDGE_WIDTH[1]").grid(row=9, column=0, sticky="w")
            ttk.Entry(tr, textvariable=self.tr_edge_w1, width=8).grid(row=9, column=1, sticky="w", padx=6)
            ttk.Label(tr, text="EDGE_WIDTH[2]").grid(row=10, column=0, sticky="w")
            ttk.Entry(tr, textvariable=self.tr_edge_w2, width=8).grid(row=10, column=1, sticky="w", padx=6)

            ttk.Label(tr, text="NODE_ALPHA_OK").grid(row=8, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_node_a_ok, width=8).grid(row=8, column=5, sticky="w")
            ttk.Label(tr, text="NODE_ALPHA_BAD").grid(row=9, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_node_a_bad, width=8).grid(row=9, column=5, sticky="w")
            ttk.Label(tr, text="NODE_ALPHA_SHADOW").grid(row=10, column=4, sticky="w", padx=(20, 0))
            ttk.Entry(tr, textvariable=self.tr_node_a_shadow, width=8).grid(row=10, column=5, sticky="w")

            ttk.Label(tr, text="NODE_SIZE").grid(row=12, column=0, sticky="w")
            ttk.Entry(tr, textvariable=self.tr_node_size, width=10).grid(row=12, column=1, sticky="w", padx=6)

        def reset_tree_style(self):
            s = DEFAULT_TREES_STYLE
            self.tr_edge_c0.set(s.edge_color_0)
            self.tr_edge_c1.set(s.edge_color_1)
            self.tr_edge_c2.set(s.edge_color_2)
            self.tr_edge_a0.set(s.edge_alpha_0)
            self.tr_edge_a1.set(s.edge_alpha_1)
            self.tr_edge_a2.set(s.edge_alpha_2)
            self.tr_edge_w0.set(s.edge_width_0)
            self.tr_edge_w1.set(s.edge_width_1)
            self.tr_edge_w2.set(s.edge_width_2)
            self.tr_node_color.set(s.node_color)
            self.tr_node_a_ok.set(s.node_alpha_ok)
            self.tr_node_a_bad.set(s.node_alpha_bad)
            self.tr_node_a_shadow.set(s.node_alpha_shadow)
            self.tr_node_size.set(s.node_size)

        def browse_interf(self):
            p = filedialog.askdirectory(title="Select Interference Directory")
            if p:
                self.interf_dir.set(p)

        def browse_cc(self):
            p = filedialog.askdirectory(title="Select Cache Coloring Directory")
            if p:
                self.cc_dir.set(p)

        def browse_outdir(self):
            p = filedialog.askdirectory(title="Select Output Directory")
            if p:
                self.outdir.set(p)

        def select_all(self, lb):
            lb.selection_set(0, "end")

        def unselect_all(self, lb):
            lb.selection_clear(0, "end")

        def _get_selected(self, lb):
            idxs = lb.curselection()
            return [lb.get(i) for i in idxs]

        def _get_selected_plot_types(self) -> List[str]:
            plot_types = []
            if self.plt_heatmap.get():
                plot_types.append("heatmap")
            if self.plt_ridgeline.get():
                plot_types.append("ridgeline")
            if self.plt_trees.get():
                plot_types.append("trees")
            if not plot_types:
                raise ValueError("Select at least one plot type.")
            return plot_types

        def scan_benchmarks(self):
            interf = self.interf_dir.get()
            cc = self.cc_dir.get()
            if not interf or not cc:
                messagebox.showwarning("Missing input", "Please select both directories.")
                return

            benches = scan_benchmarks_from_dirs([interf, cc])

            for lb in (self.lb_cpu0, self.lb_cpu1, self.lb_cpu2):
                lb.delete(0, "end")

            for b in benches["cpu0"]:
                self.lb_cpu0.insert("end", b)
            for b in benches["cpu1"]:
                self.lb_cpu1.insert("end", b)
            for b in benches["cpu2"]:
                self.lb_cpu2.insert("end", b)

            if benches["cpu0"]:
                self.select_all(self.lb_cpu0)
            if benches["cpu1"]:
                self.lb_cpu1.selection_set(0)
            if benches["cpu2"]:
                self.select_all(self.lb_cpu2)

            self.status.set(f"Scanned: CPU0={len(benches['cpu0'])}, CPU1={len(benches['cpu1'])}, CPU2={len(benches['cpu2'])}")

        def _build_trees_style(self) -> TreesStyle:
            return TreesStyle(
                edge_color_0=self.tr_edge_c0.get(),
                edge_color_1=self.tr_edge_c1.get(),
                edge_color_2=self.tr_edge_c2.get(),
                edge_alpha_0=float(self.tr_edge_a0.get()),
                edge_alpha_1=float(self.tr_edge_a1.get()),
                edge_alpha_2=float(self.tr_edge_a2.get()),
                edge_width_0=float(self.tr_edge_w0.get()),
                edge_width_1=float(self.tr_edge_w1.get()),
                edge_width_2=float(self.tr_edge_w2.get()),
                node_color=self.tr_node_color.get(),
                node_alpha_ok=float(self.tr_node_a_ok.get()),
                node_alpha_bad=float(self.tr_node_a_bad.get()),
                node_alpha_shadow=float(self.tr_node_a_shadow.get()),
                node_size=int(self.tr_node_size.get()),
            )

        def _validate_settings(self):
            for name, col in [("EDGE_COLOR[0]", self.tr_edge_c0.get()),
                              ("EDGE_COLOR[1]", self.tr_edge_c1.get()),
                              ("EDGE_COLOR[2]", self.tr_edge_c2.get()),
                              ("NODE_COLOR", self.tr_node_color.get())]:
                if not _is_hex_color(col):
                    raise ValueError(f"{name} must be hex color like #RRGGBB (got {col})")

            for name, a in [("EDGE_ALPHA[0]", self.tr_edge_a0.get()),
                            ("EDGE_ALPHA[1]", self.tr_edge_a1.get()),
                            ("EDGE_ALPHA[2]", self.tr_edge_a2.get()),
                            ("NODE_ALPHA_OK", self.tr_node_a_ok.get()),
                            ("NODE_ALPHA_BAD", self.tr_node_a_bad.get()),
                            ("NODE_ALPHA_SHADOW", self.tr_node_a_shadow.get())]:
                if not (0.0 <= float(a) <= 1.0):
                    raise ValueError(f"{name} must be within [0,1] (got {a})")

            tpr = int(self.tr_treesperrow.get())
            if tpr <= 0:
                raise ValueError("treesperrow must be > 0")

            ns = int(self.tr_node_size.get())
            if ns <= 0:
                raise ValueError("NODE_SIZE must be > 0")

            cmap = self.hm_cmap.get().strip()
            if not cmap:
                raise ValueError("cmap name cannot be empty")

        def _validate_selections(self):
            cpu0_list = self._get_selected(self.lb_cpu0)
            cpu1_list = self._get_selected(self.lb_cpu1)
            cpu2_list = self._get_selected(self.lb_cpu2)

            if not cpu0_list:
                raise ValueError("Select at least 1 CPU0 benchmark.")
            if len(cpu1_list) != 1:
                raise ValueError("Select exactly 1 CPU1 benchmark (cache app).")
            if not cpu2_list:
                raise ValueError("Select at least 1 CPU2 (Embench) benchmark.")

            return cpu0_list, cpu1_list[0], set(cpu2_list)

        def run_plot(self):
            try:
                self._validate_settings()
                plot_types = self._get_selected_plot_types()
                cpu0_list, cpu1bench, cpu2_set = self._validate_selections()
            except Exception as e:
                messagebox.showerror("Invalid input", str(e))
                return

            self.btn_run.config(state="disabled")
            self.btn_autotune.config(state="disabled")
            self.progress.start()
            self.status.set("Running...")

            args = {
                "interf": self.interf_dir.get(),
                "cc": self.cc_dir.get(),
                "outdir": self.outdir.get(),
                "cpu0_list": cpu0_list,
                "cpu1": cpu1bench,
                "cpu2_set": cpu2_set,
                "plot_types": plot_types,
                "tau": {"CPU0": self.cpu0tol.get(), "CPU1": self.cpu1tol.get(), "CPU2": self.cpu2tol.get()},
                "tolf": float(self.tolfactor.get()),
                "hm_cmap": self.hm_cmap.get().strip(),
                "trees_per_row": int(self.tr_treesperrow.get()),
                "trees_style": self._build_trees_style(),
            }

            th = threading.Thread(target=self._run_thread, args=(args,), daemon=True)
            th.start()

        def _run_thread(self, args):
            try:
                data = load_all_files([args["interf"], args["cc"]])
                suite = PlotSuite(data)

                outputs = []
                for cpu0bench in args["cpu0_list"]:
                    embench_list, cfg_list, delta_by_cpu, class_by_cpu = suite.build_matrices(
                        cpu0bench, args["cpu1"], args["cpu2_set"], args["tau"], args["tolf"]
                    )

                    if "heatmap" in args["plot_types"]:
                        out = plot_delta_grouped_heatmap(
                            args["outdir"], cpu0bench, delta_by_cpu, cfg_list, embench_list,
                            args["tau"], args["tolf"], cmap=args["hm_cmap"]
                        )
                        outputs.append(out)

                    if "ridgeline" in args["plot_types"]:
                        out = plot_ridgeline_3cpus(
                            os.path.join(args["outdir"], f"ridgeline_{cpu0bench}.png"),
                            cpu0bench, cfg_list, delta_by_cpu, class_by_cpu, args["tau"], args["tolf"]
                        )
                        outputs.append(out)

                    if "trees" in args["plot_types"]:
                        out = plot_trees_grid(
                            os.path.join(args["outdir"], f"trees_{cpu0bench}.png"),
                            class_by_cpu, cfg_list, embench_list,
                            trees_per_row=args["trees_per_row"],
                            style=args["trees_style"],
                        )
                        outputs.append(out)

                self.master.after(0, self._done, outputs)

            except Exception as e:
                import traceback
                self.master.after(0, self._err, str(e) + "\n\n" + traceback.format_exc())

        def _done(self, outputs):
            self.progress.stop()
            self.btn_run.config(state="normal")
            self.btn_autotune.config(state="normal")
            self.status.set(f"Done ({len(outputs)} file(s))")
            msg = "Saved:\n" + "\n".join(outputs)
            messagebox.showinfo("Completed", msg)

        def _err(self, msg):
            self.progress.stop()
            self.btn_run.config(state="normal")
            self.btn_autotune.config(state="normal")
            self.status.set("Error")
            messagebox.showerror("Error", msg)

        def open_autotune(self):
            # (Same as before; unchanged)
            import tkinter as tk
            from tkinter import ttk, messagebox
            import threading

            try:
                self._validate_settings()
                cpu0_list, cpu1bench, cpu2_set = self._validate_selections()
            except Exception as e:
                messagebox.showerror("Invalid input", str(e))
                return

            tau = {"CPU0": self.cpu0tol.get(), "CPU1": self.cpu1tol.get(), "CPU2": self.cpu2tol.get()}
            tol_factor = float(self.tolfactor.get())

            win = tk.Toplevel(self.master)
            win.title("Auto-tune cache coloring")
            win.transient(self.master)
            win.grab_set()
            win.geometry("980x560")

            frm = ttk.Frame(win, padding=10)
            frm.pack(fill="both", expand=True)

            hdr = ttk.Frame(frm)
            hdr.pack(fill="x")
            ttk.Label(hdr, text=f"CPU1 bench: {cpu1bench}").pack(side="left")
            ttk.Label(hdr, text=f"CPU2 selected: {len(cpu2_set)}").pack(side="left", padx=16)

            status = tk.StringVar(value="Computing candidates…")
            ttk.Label(frm, textvariable=status).pack(anchor="w", pady=(8, 0))

            cols = ("cpu0", "cfg", "label", "acc", "acc_cnt", "d0", "d1", "d2", "worst")
            tree = ttk.Treeview(frm, columns=cols, show="headings", height=18)
            tree.pack(fill="both", expand=True, pady=10)

            headings = {
                "cpu0": "CPU0 bench",
                "cfg": "Config tag",
                "label": "Label",
                "acc": "Accept %",
                "acc_cnt": "Accepted/Total",
                "d0": "Mean Δ CPU0",
                "d1": "Mean Δ CPU1",
                "d2": "Mean Δ CPU2",
                "worst": "Worst mean Δ",
            }
            widths = {"cpu0": 140, "cfg": 120, "label": 70, "acc": 80, "acc_cnt": 110, "d0": 95, "d1": 95, "d2": 95, "worst": 95}
            for c in cols:
                tree.heading(c, text=headings[c])
                tree.column(c, width=widths.get(c, 90), anchor="center")

            fr_btn = ttk.Frame(frm)
            fr_btn.pack(fill="x")

            def close():
                win.destroy()

            ttk.Button(fr_btn, text="Close", command=close).pack(side="right")

            def copy_selected():
                sel = tree.selection()
                if not sel:
                    messagebox.showinfo("Copy", "Select a row first.")
                    return
                vals = tree.item(sel[0], "values")
                cfg = vals[1]
                self.master.clipboard_clear()
                self.master.clipboard_append(cfg)
                messagebox.showinfo("Copy", f"Copied config tag: {cfg}")

            ttk.Button(fr_btn, text="Copy selected cfg", command=copy_selected).pack(side="right", padx=8)

            def worker():
                try:
                    data = load_all_files([self.interf_dir.get(), self.cc_dir.get()])
                    suite = PlotSuite(data)
                    detected = detect_configs_in_scope(data, cpu0_list, cpu1bench, cpu2_set)
                    ranked = rank_configs_for_autotune(suite, cpu0_list, cpu1bench, cpu2_set, tau, tol_factor)

                    def fill():
                        status.set(f"Detected {len(detected)} configs; ranked {len(ranked)} (sorted by accept%, then CPU0 mean Δ).")
                        for r in ranked:
                            tree.insert(
                                "", "end",
                                values=(
                                    r["cpu0bench"],
                                    r["cfg"],
                                    r["cfg_label"],
                                    f"{r['accept_rate']:.2f}",
                                    f"{r['accepted']}/{r['total']}",
                                    f"{r['mean_d0']:.2f}" if np.isfinite(r["mean_d0"]) else "nan",
                                    f"{r['mean_d1']:.2f}" if np.isfinite(r["mean_d1"]) else "nan",
                                    f"{r['mean_d2']:.2f}" if np.isfinite(r["mean_d2"]) else "nan",
                                    f"{r['worst_mean']:.2f}" if np.isfinite(r["worst_mean"]) else "nan",
                                )
                            )
                        children = tree.get_children()
                        if children:
                            tree.selection_set(children[0])
                            tree.focus(children[0])

                    self.master.after(0, fill)

                except Exception as e:
                    import traceback

                    def show_err():
                        messagebox.showerror("Auto-tune failed", str(e) + "\n\n" + traceback.format_exc())
                        win.destroy()

                    self.master.after(0, show_err)

            threading.Thread(target=worker, daemon=True).start()

    root = tk.Tk()
    PlotterGUI(root)
    root.mainloop()


# -------------------------
# CLI
# -------------------------


def _add_common_args(p):
    p.add_argument("--interf-dir", "--interf_dir", dest="interf_dir", required=True)
    p.add_argument("--cc-dir", "--cc_dir", dest="cc_dir", required=True)

    p.add_argument("--cpu0bench", required=True, help="CPU0 MiBench benchmark (e.g., susanc_small)")
    p.add_argument("--cpu1bench", default=None, help="CPU1 cache bench (e.g., cache_w-C1-W1M). Optional if unique.")
    p.add_argument("--cpu2list", nargs='*', default=None,
                   help="Optional list of CPU2/Embench benchmarks (e.g., tarfind crc32). If omitted, uses all available.")

    p.add_argument("--cpu0tol", type=float, required=True)
    p.add_argument("--cpu1tol", type=float, required=True)
    p.add_argument("--cpu2tol", type=float, required=True)
    p.add_argument("--tolerancefactor", type=float, default=1.5)


def main():
    ap = argparse.ArgumentParser(prog=os.path.basename(__file__))
    sub = ap.add_subparsers(dest="cmd", required=True)

    sub.add_parser("gui", help="Launch Tkinter GUI")

    ap_hm = sub.add_parser("heatmap")
    _add_common_args(ap_hm)
    ap_hm.add_argument("--outdir", default="./evalplots")
    ap_hm.add_argument("--cmap", default="viridis")

    ap_rg = sub.add_parser("ridgeline")
    _add_common_args(ap_rg)
    ap_rg.add_argument("--outpng", default=None)

    ap_tr = sub.add_parser("trees")
    _add_common_args(ap_tr)
    ap_tr.add_argument("--outpng", default=None)
    ap_tr.add_argument("--treesperrow", type=int, default=11)

    args = ap.parse_args()

    if args.cmd == "gui":
        launch_gui()
        return

    tau = {"CPU0": args.cpu0tol, "CPU1": args.cpu1tol, "CPU2": args.cpu2tol}

    data = load_all_files([args.interf_dir, args.cc_dir])
    suite = PlotSuite(data)

    cpu2_subset = None if args.cpu2list is None else set(args.cpu2list)

    if args.cmd == "heatmap":
        embench_list, cfg_list, delta_by_cpu, class_by_cpu = suite.build_matrices(
            args.cpu0bench, args.cpu1bench, cpu2_subset, tau, args.tolerancefactor
        )
        out = plot_delta_grouped_heatmap(
            out_dir=args.outdir,
            cpu0_bench=args.cpu0bench,
            delta_by_cpu=delta_by_cpu,
            cfg_list=cfg_list,
            embench_list=embench_list,
            tau_by_cpu=tau,
            tol_factor=args.tolerancefactor,
            cmap=args.cmap,
        )
        print(f"Heatmap saved to {out}")

    elif args.cmd == "ridgeline":
        embench_list, cfg_list, delta_by_cpu, class_by_cpu = suite.build_matrices(
            args.cpu0bench, args.cpu1bench, cpu2_subset, tau, args.tolerancefactor
        )
        outpng = args.outpng or os.path.join("./ridgeline", f"ridgeline3cpus_{args.cpu0bench}.png")
        out = plot_ridgeline_3cpus(outpng, args.cpu0bench, cfg_list, delta_by_cpu, class_by_cpu, tau, args.tolerancefactor)
        print(f"Ridgeline plot saved to {out}")

    elif args.cmd == "trees":
        embench_list, cfg_list, class_by_cpu = suite.build_class_matrices(
            args.cpu0bench, args.cpu1bench, cpu2_subset, tau, args.tolerancefactor
        )
        outpng = args.outpng or os.path.join("./decisiontrees", f"treesgrid_{args.cpu0bench}.png")
        out = plot_trees_grid(outpng, class_by_cpu, cfg_list, embench_list, trees_per_row=args.treesperrow, style=DEFAULT_TREES_STYLE)
        print(f"Decision trees saved to {out}")


if __name__ == "__main__":
    main()