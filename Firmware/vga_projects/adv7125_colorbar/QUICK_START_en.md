# ADV7125 VGA Color Bar Test - Quick Start

## 1. Generate PLL Core (Required!)

⚠️ **Important**: Must generate real PLL core before use!

```bash
# Method 1: GUI Generation
Tools → Clocking Wizard
- Input: 50MHz
- Output: 40MHz
- Save as: src/clk_wiz_50to40.v

# Method 2: Use XCO (if supported)
ipcoregen pll_config.xco
```

Detailed steps refer to `PLL_GENERATION_GUIDE.md`

---

## 2. Create ISE Project

1. **Open Xilinx ISE 14.7**

2. **Create New Project**
   ```
   File → New Project
   Name: adv7125_colorbar
   Location: F:\Video_Covertor\Firmware\FPGA_Verification\projects\adv7125_colorbar
   Top-level source type: HDL
   ```

3. **Set Device**
   ```
   Family: Spartan6
   Device: xc6slx45
   Package: fg484
   Speed Grade: -3
   ```

4. **Add Source Files**
   - `src/adv7125_colorbar_top.v`
   - `src/vga_colorbar_800x600.v`
   - `src/adv7125_driver_8bit.v`
   - `src/clk_wiz_50to40.v` (generated PLL core)

5. **Add Constraint File**
   - `constraints/adv7125_colorbar.ucf`

---

## 3. Synthesis and Implementation

### Method A: GUI Operation
1. Select `adv7125_colorbar_top` in Sources window
2. Double-click in Processes window:
   - **Synthesize - XST** (wait for completion)
   - **Implement** (wait for completion)
   - **Generate Programming File** (wait for completion)

### Method B: Batch Processing
```bash
# In ISE command environment
xtclsh adv7125_colorbar.tcl run
```

---

## 4. Download Bitstream

1. **Connect JTAG downloader** to FPGA
2. **Turn on FPGA power**
3. **Connect VGA display** to VGA output interface
4. **Turn on display power**, select VGA input

5. **Download in ISE**:
   ```
   Tools → iMPACT → Configure Boundary Scan
   → Right-click → Initialize Chain
   → Select .bit file → OK
   → Right-click → Program
   ```

---

## 5. Verify Output

### Expected Display Screen
```
┌────────────────────────────────────────────┐
│ White │ Yellow │ Cyan │ Green │ Magenta │ Red │ Blue │ Black │
│███ │███ │███ │███ │███ │███ │███ │   │
│███ │███ │███ │███ │███ │███ │███ │   │
│███ │███ │███ │███ │███ │███ │███ │   │
└────────────────────────────────────────────┘
```

### Oscilloscope Measurements (Optional)

| Test Point | Frequency | Amplitude | Description |
|--------|------|------|------|
| ADV7125_CLK | 40MHz | 3.3V | DAC clock |
| VGA_HS | 37.88kHz | 3.3V | Horizontal sync |
| VGA_VS | 60.32Hz | 3.3V | Vertical sync |
| ADV7125_RED[7] | ~20MHz | 3.3V | Data activity |

---

## 6. Troubleshooting

### Display Shows "No Signal"
1. ✅ Check if FPGA is programmed (DONE LED should be on)
2. ✅ Check if VGA cable is plugged in
3. ✅ Check if display input source is set to VGA
4. ✅ Measure ADV7125_CLK with oscilloscope for 40MHz
5. ✅ **Check if PLL is correctly generated and replaced**

### Has Signal But Black Screen
1. ✅ Measure ADV7125 power pins (3.3V)
2. ✅ Check if ADV7125_RESET is high level
3. ✅ Measure RGB data lines for activity
4. ✅ Check VGA_HS/VGA_VS for pulses

### Color Incorrect
1. ✅ Check RGB data line order (8-bit)
2. ✅ Confirm PCB soldering has no shorts
3. ✅ Try another display

---

## 7. Modify Test Pattern

Edit `src/vga_colorbar_800x600.v`:

### Change to Full White Screen
```verilog
assign bar_color = 24'hFFFFFF;  // Fixed white
```

### Change to Grid Pattern
```verilog
assign bar_color = ((h_count[5:0] == 6'd0) || (v_count[5:0] == 6'd0))
                   ? 24'hFFFFFF : 24'h000000;
```

---

## 8. Technical Reference

### Key Files
- `adv7125_colorbar_top.v` - Top module
- `vga_colorbar_800x600.v` - Color bar generator (800x600@60Hz)
- `adv7125_driver_8bit.v` - DAC driver (8-bit RGB)
- `clk_wiz_50to40.v` - PLL clock (**needs generation!**)
- `adv7125_colorbar.ucf` - Pin constraints

### External References
- ADV7125 Datasheet (Analog Devices)
- VESA VGA Timing Standard
- Xilinx Spartan-6 Datasheet
- `PLL_GENERATION_GUIDE.md` - PLL generation guide

---

## 9. Next Steps

✅ **After VGA test passes**:
1. Test HDMI output (TFP410)
2. Implement HDMI input to VGA output
3. Add video frame buffer (using DDR3)
4. Debug ADV7393 composite video

---

**Technical Support**: Refer to diagnosis flow in `../../docs/HDMI_DEBUG_GUIDE.md`
