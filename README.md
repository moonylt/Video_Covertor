# Video_Covertor - FPGA Video Converter

[![中文](https://img.shields.io/badge/中文-简体-blue)](README_CN.md) [![English](https://img.shields.io/badge/English-EN-green)](README_EN.md)

FPGA-based video signal conversion project supporting HDMI input/output conversion.

Based on Spartan-6 with HDMI in/out, VGA output, S-Video output. Supports scaler, frame buffer, and PIP.

## 📊 System Block Diagram

```
                    ┌─────────────────────────────────────────────────────┐
                    │                    Video Converter                   │
                    └─────────────────────────────────────────────────────┘
                                            ▲
                                            │ HDMI In
                    ┌─────────────────────────────────────────────────────┐
   HDMI Source ────│  TFP401A   ┌───────────────────────┐    TFP410    │───► HDMI Display
                    │  Receiver  │                       │  Transmitter │
                    └────────────│      Spartan-6 FPGA   │──────────────┘
                                 │      (XC6SLX45)       │
                    ┌────────────│                       │──────────────┐
                    │  DDR3L     │    ┌───────────┐      │   ADV7125    │───► VGA Monitor
                    │  256MB     │    │  Scaler   │      │   VGA DAC    │
                    │  Frame     │    │  Buffer   │      │──────────────┘
                    │  Buffer    │    │  PIP      │      │   ADV7393    │───► CVBS/S-Video
                    └────────────│    └───────────┘      │   Encoder    │
                                 │                       │──────────────┘
                    ┌────────────│      50MHz CLK        │──────────────┐
                    │   Buttons  │                       │    LEDs      │
                    │   (BTN0)   │                       │   (Status)   │
                    └────────────┴───────────────────────┴──────────────┘
```

---

## 📁 Project Structure

```
Video_Covertor/
├── Firmware/                      # Firmware
│   ├── hdmi_vga_combined/         # ✅ HDMI + VGA dual output (Recommended)
│   │   ├── src/                   # Verilog source
│   │   ├── constraints/           # Pin constraints
│   │   └── README.md
│   ├── FPGA_Verification/         # Main project (In development)
│   │   ├── src/
│   │   ├── sim/
│   │   ├── constraints/
│   │   └── docs/
│   └── vga_projects/              # VGA test projects
│       └── adv7125_colorbar/
├── Sch/                           # Altium schematics and PCB
│   ├── Altium_VIDEO_CONVERTER_2026-03-16/
│   ├── BOM_*.xlsx
│   └── Netlist_*.tel
└── README.md
```

## 🔧 Hardware Requirements

| Component | Model |
|-----------|-------|
| FPGA | Xilinx Spartan-6 XC6SLX45-3FGG484I |
| HDMI Receiver | TFP401A |
| HDMI Transmitter | TFP410 |
| VGA DAC | ADV7125 (8-bit RGB) |
| Video Encoder | ADV7393 (CVBS/S-Video) |
| DDR3L | 256MB |
| System Clock | 50MHz |

## 📋 Features

- HDMI Video Capture
- HDMI Video Output
- VGA Analog Output
- CVBS/S-Video Output
- Frame Buffer (DDR3)
- Video Format Conversion
- Scaler
- PIP (Future)

## 🚀 Quick Start

### Recommended: HDMI + VGA Dual Output Test

```bash
cd Firmware/hdmi_vga_combined
```

**Features:**
| Output | Resolution | Refresh | Chip |
|--------|------------|---------|------|
| HDMI | 1280x720 | 60Hz | TFP410 |
| VGA | 800x600 | 60Hz | ADV7125 |

**Test Mode:** Press BTN0 to cycle through test patterns (white/red/green/blue/colorbar/grid)

**Steps:**
1. Use Xilinx ISE Clocking Wizard to generate PLL (74.25MHz + 40MHz)
2. Replace `src/clk_wiz_dual.v`
3. Compile and download to FPGA
4. Connect HDMI and VGA monitors to test

See: [hdmi_vga_combined/README.md](Firmware/hdmi_vga_combined/README.md)

### Other Projects

| Project | Path | Description | Status |
|---------|------|-------------|--------|
| HDMI + VGA | `Firmware/hdmi_vga_combined/` | Dual output test | ✅ Ready |
| VGA Colorbar | `Firmware/vga_projects/adv7125_colorbar/` | ADV7125 test | ✅ Ready |
| Main Project | `Firmware/FPGA_Verification/` | Full video conversion | 🚧 WIP |

## 📄 Documentation

| Doc | Description |
|-----|-------------|
| [HDMI+VGA Project](Firmware/hdmi_vga_combined/README.md) | Dual output test guide |
| [VGA Project](Firmware/vga_projects/adv7125_colorbar/) | VGA colorbar test |
| [Technical Docs](Firmware/FPGA_Verification/docs/) | Detailed documentation |

## 🛠️ Tool Versions

- Xilinx ISE 14.7
- Altium Designer
- ModelSim

## 📝 Notes

⚠️ **License File**: `xilinx_ise.lic` is a license file, do not upload to public repository.

## 📅 Date

March 2026

## 📧 Contact

For issues, please submit an Issue or contact the project maintainer.