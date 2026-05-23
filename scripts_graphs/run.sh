#!/bin/bash

echo "======================================"
echo "Running snoop latencies processing..."
echo "======================================"

# -----------------------------
# STEP 1 - ILA Waves Info
# -----------------------------
echo ""
echo "[1/3] ILA Waves Info..."
python3 ila_waves_info.py

# -----------------------------
# STEP 2 - GENERATE Q95/Q99
# -----------------------------
echo ""
echo "[2/3] Generating Q95/Q99 filtered datasets..."
python3 q95_q99.py

# -----------------------------
# STEP 3 - GENERATE VIOLIN PLOTS
# -----------------------------
echo ""
echo "[3/3] Generating violin plots..."
python3 gen_plot.py

echo ""
echo "==============================================="
echo "Snoop Latencies Process completed successfully."
echo "==============================================="