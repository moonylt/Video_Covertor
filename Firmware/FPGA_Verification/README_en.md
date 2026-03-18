# VIDEO_CONVERTER FPGA Verification Project

## Project Overview

This project is the FPGA functional verification project for the VIDEO_CONVERTER hardware platform, based on Xilinx Spartan-6 XC6SLX45-3FGG484I FPGA.

**Current Version: Minimum System (HDMI Passthrough Only)**

### Main Features

- **HDMI/DVI Video Input** - TFP401A receiver interface (parallel RGB)
- **HDMI/DVI Video Output** - TFP410 transmitter interface (parallel RGB)
- **User Interface** - Buttons + LED indicators

### Disabled Features (Commented Out)

- **DDR3 Memory** - Interface fixed at idle state
- **SPI Flash** - Only for FPGA configuration, no user logic required
- **UART Serial** - Not used
- **ADV7125 (VGA DAC)** - Not used temporarily, commented out
- **ADV7393 (CVBS Encoder)** - Not used temporarily, commented out

### System Architecture (Passthrough Mode)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VIDEO_CONVERTER Top Level                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │   TFP401A    │────▶│   Direct     │────▶│   TFP410     │            │
│  │  HDMI Input  │     │   Connect    │     │ HDMI Output  │            │
│  │ (TMDS→RGB)   │     │   (RGB)      │     │ (RGB→TMDS)   │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│                                                                          │
│  [ADV7125 VGA] - Not used temporarily                                    │
│  [ADV7393 CVBS] - Not used temporarily                                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Signal Flow Description

```
HDMI Input → TMDS Differential → TFP401A → 24-bit RGB+ Sync → FPGA
                                              ↓
                    ┌───────────────────────────┼───────────────────┐
                    ↓                           ↓                   ↓
                TFP410                    ADV7125 (VGA)       ADV7393 (CVBS)
                    ↓
            TMDS Differential → HDMI Output
```

**Note**: The FPGA processes **parallel RGB digital video data**, not TMDS differential signals!

## Directory Structure

```
FPGA_Verification/
├── README.md                          # Project description
├── docs/
│   ├── SIGNAL_FLOW.md                 # Signal flow description
│   └── interface_spec.md              # Interface specification
├── src/
│   ├── top/
│   │   ├── video_converter_top.v      # Top-level module
│   │   ├── clk_wiz_50to100.v          # PLL clock module
│   │   ├── rst_controller_simple.v    # Reset controller
│   │   └── sys_status_monitor_simple.v# Status monitoring
│   └── hdmi/
│       ├── tfp401a_rx.v               # TFP401A input driver
│       └── tfp410_tx.v                # TFP410 output driver
├── constraints/
│   └── video_converter.ucf            # Pin constraints
└── sim/
    ├── run_sim.do                     # Simulation script
    └── waves.do                       # Waveform configuration
```

**Source File Statistics**: 6 Verilog files + 1 UCF constraint file

## Development Environment

- **FPGA Tool**: Xilinx ISE 14.7
- **Simulation Tool**: ModelSim / ISim
- **Language**: Verilog HDL
- **Target Device**: XC6SLX45-3FGG484I

## Quick Start

### 1. Open ISE Project

```
File → Open Project → video_converter.xise
```

### 2. Synthesize and Implement

```
Processes Window:
1. Synthesize - XST → Run
2. Implement Design → Run
3. Generate Programming File → Run
```

### 3. Download Bitstream

```
Tools → iMPACT → Configure Devices → Auto Connect → Program
```

## Pin Assignment Summary

### Clock and Reset

| Signal | Pin | Description |
|------|------|------|
| clk_50mhz | AA12 | 50MHz system clock |
| clk_27mhz | AB13 | 27MHz video clock |
| rst_n | T6 | Global reset |

### Video Input (TFP401A → FPGA)

| Signal | Pin Count | Description |
|------|--------|------|
| tfp401_dvi_d[0:23] | 24 | 24-bit RGB data |
| tfp401_de/hs/vs | 3 | Sync signals |
| tfp401_pclk | 1 | Pixel clock |

### Video Output (FPGA → TFP410)

| Signal | Pin Count | Description |
|------|--------|------|
| tfp410_dvi_d[0:23] | 24 | 24-bit RGB data |
| tfp410_de/hs/vs | 3 | Sync signals |
| tfp410_pclk | 1 | Pixel clock |

### Other Interfaces

| Interface | Pin Count | Description |
|------|--------|------|
| Buttons | 2 | User buttons |
| LED | 8 | Status indicators |
| JTAG | 4 | Download/Debug |

Detailed constraints see: `constraints/video_converter.ucf`

## Supported Video Formats

| Format | Resolution | Refresh Rate | Pixel Clock |
|------|--------|--------|----------|
| VGA | 640x480 | 60Hz | 25.175 MHz |
| SVGA | 800x600 | 60Hz | 40.000 MHz |
| XGA | 1024x768 | 60Hz | 65.000 MHz |
| 720p | 1280x720 | 60Hz | 74.250 MHz |
| 1080p | 1920x1080 | 60Hz | 148.500 MHz |

## Status Indicators

### LED Meanings

| LED | Description |
|-----|------|
| LED0 | Power/Run indicator (always on) |
| LED1 | Video input status |
| LED6 | Video input activity |
| LED7 | Video output status |

### Button Functions

| Button | Function |
|------|------|
| BTN0 | Reserved |
| BTN1 | Reserved |

## Version History

| Version | Date | Author | Description |
|------|------|------|------|
| 1.3 | 2026-03-16 | FPGA Team | Commented ADV7125/ADV7393, minimum system |
| 1.2 | 2026-03-16 | FPGA Team | Removed SPI/UART, simplified project |
| 1.1 | 2026-03-16 | FPGA Team | Fixed TMDS misunderstanding |
| 1.0 | 2026-03-16 | FPGA Team | Initial version |

## Related Documents

- `docs/SIGNAL_FLOW.md` - Detailed signal flow description
- `docs/architecture.md` - System architecture
- `constraints/video_converter.ucf` - Complete pin constraints

## Notes

1. **TMDS signals not connected to FPGA** - Processed by TFP401A/TFP410
2. **DDR3 interface floating** - Fixed at idle state in code
3. **SPI Flash for configuration only** - No user logic required
4. **UART not used** - Related code removed
