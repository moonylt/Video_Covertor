# Video_Converter - FPGA Video Converter

FPGA-based video signal conversion project supporting HDMI input/output conversion.

## 📁 Project Structure

```
Video_Covertor/
├── Firmware/              # Firmware code
│   └── FPGA_Verification/
│       ├── src/          # Verilog source code
│       ├── sim/          # Simulation files
│       ├── constraints/  # Pin constraint files
│       ├── projects/     # Sub-projects
│       └── docs/         # Technical documentation
├── Sch/                  # Altium schematics and PCB design
│   ├── Altium_VIDEO_CONVERTER_2026-03-16/
│   ├── BOM_*.xlsx        # Bill of Materials
│   └── Netlist_*.tel     # Netlist files
└── README.md             # Project description
```

## 🔧 Hardware Requirements

- FPGA: Xilinx Spartan-6
- HDMI input interface
- HDMI/AV output interface
- DDR3 memory module

## 📋 Main Features

- HDMI video signal acquisition
- Frame buffer processing (DDR3)
- Video format conversion
- Multi-channel output support

## 🚀 Quick Start

### 1. Open ISE Project

```bash
cd Firmware/FPGA_Verification
# Open video_converter.xise with Xilinx ISE
```

### 2. Import Constraints

```bash
# Use constraints/video_converter.ucf
```

### 3. Generate Bitstream

Execute in ISE:
- Synthesize
- Implement
- Generate Programming File

### 4. Program FPGA

Use iMPACT or Adept tool to program the `.bit` file

## 📄 Documentation

| Document | Description |
|------|------|
| [QUICK_START.md](Firmware/FPGA_Verification/QUICK_START.md) | Quick start guide |
| [PROJECT_COMPLETE.md](Firmware/FPGA_Verification/PROJECT_COMPLETE.md) | Project completion report |
| [docs/](Firmware/FPGA_Verification/docs/) | Detailed technical documentation |

## 🛠️ Tool Versions

- Xilinx ISE 14.7
- Altium Designer
- ModelSim (Simulation)

## 📝 Notes

⚠️ **License File**: `xilinx_ise.lic` is a license file, do not upload to public repositories.

## 📅 Project Date

March 2026

## 📧 Contact

For questions, please submit an Issue or contact the project maintainers.
