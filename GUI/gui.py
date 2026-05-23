import sys
import os
import yaml
import subprocess
from datetime import datetime

from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QCheckBox, QGroupBox, QTextEdit, QFileDialog,
    QTabWidget, QFrame, QProgressBar, QListWidget, QSplitter, QLineEdit,
    QGridLayout
)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QTextCursor


# ============================================================
# DARK THEME
# ============================================================

DARK_STYLE = """
QMainWindow, QWidget {
    background-color: #1e1e2e;
    color: #cdd6f4;
    font-family: 'Segoe UI', sans-serif;
    font-size: 13px;
}
QGroupBox {
    border: 1px solid #45475a;
    border-radius: 8px;
    margin-top: 12px;
    padding: 10px;
    font-weight: bold;
    color: #89b4fa;
}
QGroupBox::title {
    subcontrol-origin: margin;
    left: 10px;
    padding: 0 5px;
}
QPushButton {
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 8px 16px;
    font-weight: bold;
}
QPushButton:hover {
    background-color: #45475a;
    border-color: #89b4fa;
}
QPushButton:pressed {
    background-color: #89b4fa;
    color: #1e1e2e;
}
QPushButton#btn_run {
    background-color: #a6e3a1;
    color: #1e1e2e;
    font-size: 14px;
    padding: 10px 24px;
}
QPushButton#btn_run:hover { background-color: #94d197; }
QPushButton#btn_stop {
    background-color: #f38ba8;
    color: #1e1e2e;
    font-size: 14px;
    padding: 10px 24px;
}
QPushButton#btn_stop:hover { background-color: #e07090; }
QPushButton#btn_browse {
    background-color: #313244;
    padding: 6px 12px;
    font-size: 11px;
}
QCheckBox { color: #cdd6f4; spacing: 8px; }
QCheckBox::indicator {
    width: 16px; height: 16px;
    border-radius: 4px;
    border: 1px solid #45475a;
    background-color: #313244;
}
QCheckBox::indicator:checked {
    background-color: #89b4fa;
    border-color: #89b4fa;
}
QTextEdit {
    background-color: #181825;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    font-family: 'Consolas', 'Courier New', monospace;
    font-size: 12px;
    padding: 6px;
}
QTabWidget::pane {
    border: 1px solid #45475a;
    border-radius: 6px;
    background-color: #1e1e2e;
}
QTabBar::tab {
    background-color: #313244;
    color: #6c7086;
    padding: 8px 16px;
    border-top-left-radius: 6px;
    border-top-right-radius: 6px;
    margin-right: 2px;
}
QTabBar::tab:selected { background-color: #89b4fa; color: #1e1e2e; font-weight: bold; }
QTabBar::tab:hover { background-color: #45475a; color: #cdd6f4; }
QListWidget {
    background-color: #181825;
    border: 1px solid #45475a;
    border-radius: 6px;
    color: #cdd6f4;
    padding: 4px;
}
QListWidget::item { padding: 6px; border-radius: 4px; }
QListWidget::item:selected { background-color: #313244; color: #89b4fa; }
QListWidget::item:hover { background-color: #27273a; }
QLineEdit {
    background-color: #313244;
    color: #cdd6f4;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 6px 10px;
}
QLineEdit:focus { border-color: #89b4fa; }
QProgressBar {
    background-color: #313244;
    border: 1px solid #45475a;
    border-radius: 6px;
    text-align: center;
    color: #cdd6f4;
    height: 20px;
}
QProgressBar::chunk { background-color: #89b4fa; border-radius: 5px; }
QScrollArea { border: none; }
QSplitter::handle { background-color: #45475a; }
QLabel#title { font-size: 20px; font-weight: bold; color: #89b4fa; }
QLabel#subtitle { font-size: 12px; color: #6c7086; }
QFrame#separator { background-color: #45475a; max-height: 1px; }
"""


# ============================================================
# YAML inline list helper
# ============================================================

class InlineList(list):
    pass

def inline_representer(dumper, data):
    return dumper.represent_sequence('tag:yaml.org,2002:seq', data, flow_style=True)

yaml.add_representer(InlineList, inline_representer)

def convert_lists(obj):
    if isinstance(obj, list):
        return InlineList([convert_lists(i) for i in obj])
    elif isinstance(obj, dict):
        return {k: convert_lists(v) for k, v in obj.items()}
    return obj


# ============================================================
# WORKER THREAD
# ============================================================

class TestWorker(QThread):
    log_signal      = pyqtSignal(str)
    finished_signal = pyqtSignal()

    def __init__(self, config_path, skip_build):
        super().__init__()
        self.config_path = config_path
        self.skip_build  = skip_build
        self._stop       = False

    def stop(self):
        self._stop = True

    def run(self):
        cmd = ["python3", "main.py", "--config", self.config_path]
        if self.skip_build:
            cmd.append("--skip-build")

        self.log_signal.emit(f"[{datetime.now().strftime('%H:%M:%S')}] Starting: {' '.join(cmd)}\n")

        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1
            )
            for line in process.stdout:
                if self._stop:
                    process.terminate()
                    self.log_signal.emit("\n[STOPPED BY USER]\n")
                    break
                self.log_signal.emit(line)
            process.wait()
        except Exception as e:
            self.log_signal.emit(f"[ERROR] {str(e)}\n")

        self.finished_signal.emit()


# ============================================================
# TAB 1 — CONFIGURATION
# ============================================================

class ConfigEditor(QWidget):
    def __init__(self):
        super().__init__()
        self.config_path = ""
        self._build_ui()

    def _build_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(12)

        # ── Config file ──────────────────────────────────────
        file_group = QGroupBox("Configuration File")
        file_layout = QHBoxLayout(file_group)
        self.config_path_edit = QLineEdit()
        self.config_path_edit.setPlaceholderText("Path to config.yaml...")
        browse_btn = QPushButton("Browse", objectName="btn_browse")
        browse_btn.clicked.connect(self._browse_config)
        load_btn = QPushButton("Load", objectName="btn_browse")
        load_btn.clicked.connect(self._load_config)
        file_layout.addWidget(self.config_path_edit)
        file_layout.addWidget(browse_btn)
        file_layout.addWidget(load_btn)
        layout.addWidget(file_group)

        # ── Main content ─────────────────────────────────────
        content = QHBoxLayout()
        left = QVBoxLayout()

        # ILA config
        ila_group = QGroupBox("ILA Configuration")
        ila_layout = QVBoxLayout(ila_group)

        ila_layout.addWidget(QLabel("Test Types:"))
        self.cb_solo     = QCheckBox("SOLO")
        self.cb_dma      = QCheckBox("DMA")
        self.cb_dma_fpga = QCheckBox("DMA + FPGA")
        for cb in [self.cb_solo, self.cb_dma, self.cb_dma_fpga]:
            cb.setChecked(True)
            ila_layout.addWidget(cb)

        ila_layout.addSpacing(8)
        ila_layout.addWidget(QLabel("Snoop Types:"))
        self.cb_read_snoop  = QCheckBox("Read Snoop")
        self.cb_write_snoop = QCheckBox("Write Snoop")
        for cb in [self.cb_read_snoop, self.cb_write_snoop]:
            cb.setChecked(True)
            ila_layout.addWidget(cb)

        ila_layout.addSpacing(8)
        ila_layout.addWidget(QLabel("DMA Channels:"))
        ch_layout = QHBoxLayout()
        self.cb_ch = {}
        for ch in [1, 2, 4, 8]:
            cb = QCheckBox(str(ch))
            cb.setChecked(True)
            self.cb_ch[ch] = cb
            ch_layout.addWidget(cb)
        ila_layout.addLayout(ch_layout)

        ila_layout.addSpacing(8)
        ila_layout.addWidget(QLabel("Coherency:"))
        self.cb_noncoherent = QCheckBox("Non-coherent")
        self.cb_coherent    = QCheckBox("Coherent")
        for cb in [self.cb_noncoherent, self.cb_coherent]:
            cb.setChecked(True)
            ila_layout.addWidget(cb)

        left.addWidget(ila_group)

        # Hardware
        hw_group = QGroupBox("Hardware")
        hw_layout = QGridLayout(hw_group)

        hw_layout.addWidget(QLabel("Platform:"), 0, 0)
        pl = QLabel("zcu104")
        pl.setStyleSheet("color: #a6e3a1; font-weight: bold;")
        hw_layout.addWidget(pl, 0, 1)

        hw_layout.addWidget(QLabel("TCL Script:"), 1, 0)
        self.tcl_edit = QLineEdit()
        self.tcl_edit.setPlaceholderText("Path to getwaves.tcl...")
        hw_layout.addWidget(self.tcl_edit, 1, 1)

        hw_layout.addWidget(QLabel("Bitstream (non-coherent):"), 2, 0)
        self.bit0_edit = QLineEdit()
        self.bit0_edit.setPlaceholderText("Path to .bit file...")
        hw_layout.addWidget(self.bit0_edit, 2, 1)

        hw_layout.addWidget(QLabel("LTX (non-coherent):"), 3, 0)
        self.ltx0_edit = QLineEdit()
        self.ltx0_edit.setPlaceholderText("Path to .ltx file...")
        hw_layout.addWidget(self.ltx0_edit, 3, 1)

        hw_layout.addWidget(QLabel("Bitstream (coherent):"), 4, 0)
        self.bit1_edit = QLineEdit()
        self.bit1_edit.setPlaceholderText("Path to .bit file...")
        hw_layout.addWidget(self.bit1_edit, 4, 1)

        hw_layout.addWidget(QLabel("LTX (coherent):"), 5, 0)
        self.ltx1_edit = QLineEdit()
        self.ltx1_edit.setPlaceholderText("Path to .ltx file...")
        hw_layout.addWidget(self.ltx1_edit, 5, 1)

        left.addWidget(hw_group)
        left.addStretch()

        # Right: preview
        right = QVBoxLayout()
        preview_group = QGroupBox("Generated Config Preview")
        preview_layout = QVBoxLayout(preview_group)
        self.preview_text = QTextEdit()
        self.preview_text.setReadOnly(True)
        preview_layout.addWidget(self.preview_text)

        gen_btn = QPushButton("Generate Config")
        gen_btn.clicked.connect(self._generate_config)
        preview_layout.addWidget(gen_btn)

        save_btn = QPushButton("Save Config")
        save_btn.clicked.connect(self._save_config)
        preview_layout.addWidget(save_btn)

        right.addWidget(preview_group)

        content.addLayout(left, 1)
        content.addLayout(right, 1)
        layout.addLayout(content)

    def _browse_config(self):
        path, _ = QFileDialog.getOpenFileName(self, "Open Config", "", "YAML Files (*.yaml *.yml)")
        if path:
            self.config_path_edit.setText(path)
            self._load_config()

    def _load_config(self):
        path = self.config_path_edit.text()
        if not os.path.exists(path):
            return
        self.config_path = path
        with open(path) as f:
            config = yaml.safe_load(f)

        hw = config.get("hardware", {})
        self.tcl_edit.setText(hw.get("tcl_script", ""))
        for b in hw.get("bitstreams", []):
            if b.get("coherency") == 0:
                self.bit0_edit.setText(b.get("path", ""))
                self.ltx0_edit.setText(b.get("ltx", ""))
            elif b.get("coherency") == 1:
                self.bit1_edit.setText(b.get("path", ""))
                self.ltx1_edit.setText(b.get("ltx", ""))

        ila = config.get("guests", {}).get("baremetal_cci", {}).get("ila", {})
        test_types  = ila.get("test_types", [])
        snoop_types = ila.get("snoop_types", [])
        channels    = ila.get("channels", [])
        coherency   = ila.get("coherency", [])

        self.cb_solo.setChecked("TEST_TYPE_SOLO"     in test_types)
        self.cb_dma.setChecked("TEST_TYPE_DMA"       in test_types)
        self.cb_dma_fpga.setChecked("TEST_TYPE_DMA_FPGA" in test_types)
        self.cb_read_snoop.setChecked(1  in snoop_types)
        self.cb_write_snoop.setChecked(2 in snoop_types)
        for ch, cb in self.cb_ch.items():
            cb.setChecked(ch in channels)
        self.cb_noncoherent.setChecked(0 in coherency)
        self.cb_coherent.setChecked(1    in coherency)

        self._generate_config()

    def _generate_config(self):
        test_types = []
        if self.cb_solo.isChecked():     test_types.append("TEST_TYPE_SOLO")
        if self.cb_dma.isChecked():      test_types.append("TEST_TYPE_DMA")
        if self.cb_dma_fpga.isChecked(): test_types.append("TEST_TYPE_DMA_FPGA")

        snoop_types = []
        if self.cb_read_snoop.isChecked():  snoop_types.append(1)
        if self.cb_write_snoop.isChecked(): snoop_types.append(2)

        channels  = [ch for ch, cb in self.cb_ch.items() if cb.isChecked()]
        coherency = []
        if self.cb_noncoherent.isChecked(): coherency.append(0)
        if self.cb_coherent.isChecked():    coherency.append(1)

        cfg = {
            "paths": {
                "root_dir": ".",
                "configs_dir": "/configs",
                "config_templates": "/setup_generator/config_templates",
                "imgs_dir": "./wrkdir_imgs"
            },
            "setups": {
                "benchmark": "CCI_microbenchmarks",
                "list_setups": ["cci_baremetal"]
            },
            "guests": {
                "baremetal_cci": {
                    "src_dir": "../guests/baremetal/src/baremetal-app/baremetal_CCI",
                    "cpu_IDs": [[0], [0, 1, 2, 3]],
                    "ila": {
                        "test_types": test_types,
                        "snoop_types": snoop_types,
                        "channels": channels,
                        "coherency": coherency
                    }
                }
            },
            "hardware": {
                "platform": "zcu104",
                "bitstreams": [
                    {"coherency": 0, "path": self.bit0_edit.text(), "ltx": self.ltx0_edit.text()},
                    {"coherency": 1, "path": self.bit1_edit.text(), "ltx": self.ltx1_edit.text()},
                ],
                "tcl_script": self.tcl_edit.text()
            },
            "hypervisor": {
                "name": "bao",
                "src_dir": "/media/diogo/rootfs/CCI_Interference/hypervisor/bao/bao-hypervisor"
            },
            "setups_configs": {
                "cci_baremetal": {
                    "guests": ["baremetal_cci"],
                    "en_cache_coloring": False,
                    "log_ports": ["/dev/ttyUSB2"]
                }
            }
        }

        self.preview_text.setText(
            yaml.dump(convert_lists(cfg), default_flow_style=False, sort_keys=False, allow_unicode=True)
        )

    def _save_config(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save Config", "", "YAML Files (*.yaml)")
        if path:
            with open(path, "w") as f:
                f.write(self.preview_text.toPlainText())
            self.config_path_edit.setText(path)
            self.config_path = path


# ============================================================
# TAB 2 — RUN TESTS
# ============================================================

class RunTab(QWidget):
    def __init__(self, get_config_path):
        super().__init__()
        self.get_config_path = get_config_path
        self.worker = None
        self._build_ui()

    def _build_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(12)

        # Controls
        ctrl_group = QGroupBox("Test Controls")
        ctrl_layout = QHBoxLayout(ctrl_group)
        self.skip_build_cb = QCheckBox("Skip Build")
        ctrl_layout.addWidget(self.skip_build_cb)
        ctrl_layout.addStretch()
        self.run_btn  = QPushButton("▶  Run Tests", objectName="btn_run")
        self.stop_btn = QPushButton("■  Stop",      objectName="btn_stop")
        self.stop_btn.setEnabled(False)
        self.run_btn.clicked.connect(self._run)
        self.stop_btn.clicked.connect(self._stop)
        ctrl_layout.addWidget(self.run_btn)
        ctrl_layout.addWidget(self.stop_btn)
        layout.addWidget(ctrl_group)

        # Progress
        prog_group = QGroupBox("Progress")
        prog_layout = QVBoxLayout(prog_group)
        self.progress_bar = QProgressBar()
        self.progress_bar.setValue(0)
        prog_layout.addWidget(self.progress_bar)
        self.status_label = QLabel("Idle")
        self.status_label.setStyleSheet("color: #6c7086; font-style: italic;")
        prog_layout.addWidget(self.status_label)
        layout.addWidget(prog_group)

        # Splitter
        splitter = QSplitter(Qt.Horizontal)

        img_group = QGroupBox("Images")
        img_layout = QVBoxLayout(img_group)
        self.img_list = QListWidget()
        img_layout.addWidget(self.img_list)
        splitter.addWidget(img_group)

        log_group = QGroupBox("Live Log")
        log_layout = QVBoxLayout(log_group)
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        log_layout.addWidget(self.log_text)
        clear_btn = QPushButton("Clear Log", objectName="btn_browse")
        clear_btn.clicked.connect(self.log_text.clear)
        log_layout.addWidget(clear_btn)
        splitter.addWidget(log_group)
        splitter.setSizes([250, 750])

        layout.addWidget(splitter)

    def _run(self):
        config_path = self.get_config_path()
        if not config_path or not os.path.exists(config_path):
            self._log("[ERROR] No config file selected!\n")
            return
        self.run_btn.setEnabled(False)
        self.stop_btn.setEnabled(True)
        self.status_label.setText("Running...")
        self.status_label.setStyleSheet("color: #a6e3a1; font-weight: bold;")
        self.img_list.clear()
        self.log_text.clear()
        self.worker = TestWorker(config_path, self.skip_build_cb.isChecked())
        self.worker.log_signal.connect(self._log)
        self.worker.finished_signal.connect(self._finished)
        self.worker.start()

    def _stop(self):
        if self.worker:
            self.worker.stop()

    def _finished(self):
        self.run_btn.setEnabled(True)
        self.stop_btn.setEnabled(False)
        self.status_label.setText("Finished")
        self.status_label.setStyleSheet("color: #89b4fa; font-weight: bold;")

    def _log(self, text):
        self.log_text.moveCursor(QTextCursor.End)
        self.log_text.insertPlainText(text)
        self.log_text.moveCursor(QTextCursor.End)


# ============================================================
# TAB 3 — RESULTS
# ============================================================

class ResultsTab(QWidget):
    def __init__(self):
        super().__init__()
        self._build_ui()

    def _build_ui(self):
        layout = QVBoxLayout(self)
        layout.setSpacing(12)

        paths_group = QGroupBox("Paths")
        paths_layout = QGridLayout(paths_group)

        paths_layout.addWidget(QLabel("ILA CSVs folder:"), 0, 0)
        self.ila_edit = QLineEdit()
        self.ila_edit.setPlaceholderText("Folder with baremetal_cci_TEST_TYPE_* folders...")
        browse_ila = QPushButton("Browse", objectName="btn_browse")
        browse_ila.clicked.connect(lambda: self._browse_dir(self.ila_edit))
        paths_layout.addWidget(self.ila_edit, 0, 1)
        paths_layout.addWidget(browse_ila, 0, 2)

        paths_layout.addWidget(QLabel("Parsed results folder:"), 1, 0)
        self.raw_edit = QLineEdit("parsed_results")
        browse_raw = QPushButton("Browse", objectName="btn_browse")
        browse_raw.clicked.connect(lambda: self._browse_dir(self.raw_edit))
        paths_layout.addWidget(self.raw_edit, 1, 1)
        paths_layout.addWidget(browse_raw, 1, 2)

        layout.addWidget(paths_group)

        actions_group = QGroupBox("Process Results")
        actions_layout = QHBoxLayout(actions_group)

        parse_btn    = QPushButton("1 — Parse ILA CSVs")
        quantile_btn = QPushButton("2 — Compute Q95 / Q99")
        plot_btn     = QPushButton("3 — Generate Violin Plots")
        all_btn      = QPushButton("Run All", objectName="btn_run")

        parse_btn.clicked.connect(self._run_parse)
        quantile_btn.clicked.connect(self._run_quantiles)
        plot_btn.clicked.connect(self._run_plots)
        all_btn.clicked.connect(self._run_all)

        for btn in [parse_btn, quantile_btn, plot_btn, all_btn]:
            actions_layout.addWidget(btn)

        layout.addWidget(actions_group)

        log_group = QGroupBox("Output")
        log_layout = QVBoxLayout(log_group)
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        log_layout.addWidget(self.log_text)
        layout.addWidget(log_group)

    def _browse_dir(self, edit):
        path = QFileDialog.getExistingDirectory(self, "Select Folder")
        if path:
            edit.setText(path)

    def _run_script(self, cmd):
        self.log_text.append(f"$ {' '.join(cmd)}\n")
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            self.log_text.append(result.stdout)
            if result.stderr:
                self.log_text.append(f"[STDERR] {result.stderr}")
        except Exception as e:
            self.log_text.append(f"[ERROR] {str(e)}\n")

    def _run_parse(self):
        folder = self.ila_edit.text()
        if folder:
            self._run_script(["python3", "ila_waves_info.py", folder, "--output", self.raw_edit.text()])

    def _run_quantiles(self):
        self._run_script(["python3", "q95_q99.py"])

    def _run_plots(self):
        self._run_script(["python3", "gen_plot.py"])

    def _run_all(self):
        self._run_parse()
        self._run_quantiles()
        self._run_plots()


# ============================================================
# MAIN WINDOW
# ============================================================

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("CCI Interference Framework")
        self.setMinimumSize(1200, 800)
        self._build_ui()

    def _build_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QVBoxLayout(central)
        main_layout.setContentsMargins(16, 16, 16, 16)
        main_layout.setSpacing(12)

        header = QHBoxLayout()
        title    = QLabel("CCI Interference Framework", objectName="title")
        subtitle = QLabel("Master Thesis 25/26", objectName="subtitle")
        header.addWidget(title)
        header.addStretch()
        header.addWidget(subtitle)
        main_layout.addLayout(header)

        sep = QFrame(objectName="separator")
        sep.setFrameShape(QFrame.HLine)
        main_layout.addWidget(sep)

        tabs = QTabWidget()
        self.config_tab  = ConfigEditor()
        self.run_tab     = RunTab(self._get_config_path)
        self.results_tab = ResultsTab()
        tabs.addTab(self.config_tab,   "⚙  Configuration")
        tabs.addTab(self.run_tab,      "▶  Run Tests")
        tabs.addTab(self.results_tab,  "📊  Results")
        main_layout.addWidget(tabs)

        self.statusBar().showMessage("Ready")
        self.statusBar().setStyleSheet("background-color: #181825; color: #6c7086;")

    def _get_config_path(self):
        return self.config_tab.config_path


# ============================================================
# ENTRY POINT
# ============================================================

if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle("Fusion")
    app.setStyleSheet(DARK_STYLE)
    window = MainWindow()
    window.show()
    sys.exit(app.exec_())