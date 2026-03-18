# ADV7125 VGA Color Bar Test Project

## Project Overview
Standalone ADV7125 VGA output test project to verify if VGA video DAC is working correctly.

## Features
- **Output Signal**: 8-color bar test pattern
- **Color Bar Sequence**: White, Yellow, Cyan, Green, Magenta, Red, Blue, Black (left to right)
- **Resolution**: 800x600 @ 60Hz
- **Pixel Clock**: 40MHz
- **Interface**: ADV7125 RGB DAC (**8-bit**, according to schematic)

## Hardware Connections (According to Netlist)

### ADV7125 Pin Assignment
| Signal | FPGA Pin | ADV7125 Pin | Resistor Network |
|------|----------|-----------|--------|
| R[7] | T7 | 48 | RN20.3 |
| R[6] | AB8 | 47 | RN20.4 |
| R[5] | AA8 | 46 | RN15.1 |
| R[4] | Y8 | 45 | RN15.2 |
| R[3] | W8 | 44 | RN15.3 |
| R[2] | W9 | 43 | RN15.4 |
| R[1] | R7 | 42 | RN14.1 |
| R[0] | T10 | 41 | RN14.2 |
| G[7] | AB5 | 10 | RN18.3 |
| G[6] | U6 | 9 | RN18.4 |
| G[5] | W6 | 8 | RN19.1 |
| G[4] | AB6 | 7 | RN19.2 |
| G[3] | AA6 | 6 | RN19.3 |
| G[2] | Y6 | 5 | RN19.4 |
| G[1] | AB7 | 4 | RN20.1 |
| G[0] | V7 | 3 | RN20.2 |
| B[7] | AA2 | 23 | RN16.1 |
| B[6] | AB2 | 22 | RN16.2 |
| B[5] | Y3 | 21 | RN16.3 |
| B[4] | W4 | 20 | RN16.4 |
| B[3] | AB3 | 19 | RN17.1 |
| B[2] | Y4 | 18 | RN17.2 |
| B[1] | AA4 | 17 | RN17.3 |
| B[0] | AB4 | 16 | RN17.4 |
| CLK | AB11 | 24 | - |
| BLANK_N | Y5 | 11 | RN18.7 |
| HSYNC | T8 | 12 | RN24.7 |
| VSYNC | R8 | 13 | RN24.8 |

### Important Note
⚠️ **RGB data is 8-bit** (not 10-bit!)
- Confirmed according to netlist `Netlist_Schematic1_2026-03-16.tel`
- ADV7125 connects through resistor networks, 8 bits per color channel
- Resistor networks: RN14 (Red), RN19/RN20 (Green), RN16/RN17 (Blue)

## File Structure
```
projects/adv7125_colorbar/
├── src/
│   ├── adv7125_colorbar_top.v    # Top module
│   ├── vga_colorbar_800x600.v    # Color bar generator
│   ├── clk_wiz_50to40.v          # PLL clock (40MHz)
│   └── adv7125_driver_8bit.v     # ADV7125 driver (8-bit RGB)
├── constraints/
│   └── adv7125_colorbar.ucf      # Pin constraints (according to netlist)
└── README.md                      # This file
```

## Quick Start

### Method 1: Using ISE Project Navigator
1. Open Xilinx ISE 14.7
2. Create new project:
   - Project location: `F:\Video_Covertor\Firmware\FPGA_Verification\projects\adv7125_colorbar`
   - Project name: `adv7125_colorbar`
   - Top module type: `HDL`
   - Device: `XC6SLX45-3FGG484`
3. Add source files:
   - `src/adv7125_colorbar_top.v`
   - `src/vga_colorbar_800x600.v`
   - `src/clk_wiz_50to40.v`
   - `src/adv7125_driver_8bit.v`
4. Add constraint file:
   - `constraints/adv7125_colorbar.ucf`
5. Generate bitstream
6. Download to FPGA

### Method 2: Using Tcl Script
```bash
# Execute in ISE command environment
xtclsh adv7125_colorbar.tcl run
```

## Expected Results

### Display Output
- Should display 8 vertical color stripes
- Left to right: White, Yellow, Cyan, Green, Magenta, Red, Blue, Black
- Each color bar width approximately 100 pixels (800/8)

### Oscilloscope Measurement Points
| Test Point | Signal | Expected Value |
|--------|------|--------|
| ADV7125_CLK | DAC Clock | 40MHz square wave |
| ADV7125_BLANK_N | Blanking | High level (active area) |
| VGA_HS | Horizontal Sync | 37.88kHz pulse |
| VGA_VS | Vertical Sync | 60.32Hz pulse |
| ADV7125_RED[7] | Data | ~20MHz activity |

## Troubleshooting

### Issue 1: Display No Signal
**Check Items:**
1. Measure if ADV7125_CLK has 40MHz signal
2. Check if VGA_HS/VGA_VS has sync pulses
3. Confirm display input source is selected correctly (VGA/Analog)
4. Check if VGA connector is plugged in properly

### Issue 2: Has Signal But No Image
**Check Items:**
1. Measure RGB data lines with oscilloscope for activity
2. Check ADV7125 power supply voltage (3.3V analog/digital)
3. Confirm ADV7125_RESET pin is high level
4. Check ADV7125 reference current setting resistor (R87 = 1kΩ)

### Issue 3: Image Color Incorrect
**Check Items:**
1. Confirm RGB data line order is correct (8-bit)
2. Check PCB soldering for shorts/opens
3. Verify ADV7125 BLANK_N signal polarity
4. Check if resistor networks RN14-RN20 are soldered correctly

## ADV7125 Key Pins

| Pin | Function | Voltage | Description |
|------|------|------|------|
| DVDD (13,25,28,31,34,39,40) | Digital Power | 3.3V | Digital section supply |
| AVDD (14,26,27,32,33,38) | Analog Power | 3.3V | Analog section supply |
| RESET (35) | Reset | 3.3V | High level for operation |
| CLK (24) | Clock Input | 3.3V | 40MHz pixel clock |
| BLANK_N (11) | Blanking | 3.3V | Low level disables output |
| R[7:0] (48:41) | Red Data | 3.3V | 8-bit RGB data |
| G[7:0] (10:3) | Green Data | 3.3V | 8-bit RGB data |
| B[7:0] (23:16) | Blue Data | 3.3V | 8-bit RGB data |
| VREF (36) | Reference Voltage | 1.24V | Internal bandgap reference |

## Timing Specifications (800x600@60Hz)

```
Horizontal Timing:
  Active pixels: 800
  Front porch: 40
  Sync pulse: 128 (low level)
  Back porch: 88
  Total: 1056 pixel cycles

Vertical Timing:
  Active lines: 600
  Front porch: 1
  Sync pulse: 4 (low level)
  Back porch: 23
  Total: 628 lines

Pixel Clock: 40.000 MHz
Horizontal Frequency: 37.88 kHz
Vertical Frequency: 60.32 Hz
```

## Revision History

| Version | Date | Change Description |
|------|------|----------|
| 1.0 | 2026-03-17 | Initial version (error: used 10-bit RGB) |
| 1.1 | 2026-03-17 | Corrected to 8-bit RGB (according to netlist) |

## Reference Documents
- [ADV7125 Datasheet](https://www.analog.com/media/en/technical-documentation/data-sheets/ADV7125.pdf)
- [VESA VGA Timing Standard](https://vesa.org/)
- `Netlist_Schematic1_2026-03-16.tel` - Schematic netlist
- `../../docs/HDMI_DEBUG_GUIDE.md` - Hardware debug guide
