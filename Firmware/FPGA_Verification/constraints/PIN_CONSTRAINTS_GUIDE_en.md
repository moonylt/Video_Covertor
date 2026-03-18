# Pin Constraint Check and Fix Guide

## Problem Status

⚠️ **Current pin constraints are examples and need to be modified according to actual PCB schematic**

## Updated Files

| File | Description | Status |
|------|------|------|
| `constraints/video_converter.ucf` | Main constraint file | ⚠️ Needs modification |
| `constraints/README_PINOUT.md` | Pin check guide | ✅ Created |
| `constraints/PIN_CONSTRAINTS_GUIDE.md` | This guide | ✅ Created |

## Why Modification is Needed

The pin assignments (such as `LOC = H13`) in the current UCF file are **example values**, not designed according to your actual PCB.

**Signals that must be modified**:
1. **Clock** - clk_50mhz, clk_27mhz
2. **Reset** - rst_n
3. **HDMI Input/Output** - TMDS differential pairs and parallel data
4. **SPI Flash** - flash_cs_n, clk, mosi, miso
5. **UART** - uart_tx, uart_rx
6. **Video DAC** - adv7125_red/green/blue
7. **LED/Buttons** - led[0:7], btn_n[0:1]

## How to Extract Correct Pins from Schematic

### Method 1: Using Altium Designer

1. Open schematic: `Sch/Altium_VIDEO_CONVERTER_2026-03-16/.../P1.schdoc`
2. Find FPGA (U8 - XC6SLX45)
3. View pin connections
4. Record net labels and FPGA pin numbers

### Method 2: Export Pin List

In Altium:
1. `Reports` → `Bill of Materials`
2. Select FPGA pin information
3. Export to Excel or CSV

### Method 3: View PDF Schematic

Open `Sch/Video_CovertorSCH_Schematic1_2026-03-16.pdf`
Find FPGA section, record pin connections

## Steps to Modify UCF File

### Step 1: Open Constraint File

Edit `constraints/video_converter.ucf`

### Step 2: Find Signals to Modify

For example, clock signal:
```ucf
NET "clk_50mhz"  LOC = H13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

### Step 3: Modify Pin Number According to Schematic

If clk_50mhz connects to FPGA pin T13 on schematic:
```ucf
NET "clk_50mhz"  LOC = T13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

### Step 4: Save and Verify

## IO Standard Settings

Select correct IO standard according to signal type:

| Signal Type | IO Standard | Voltage |
|----------|---------|------|
| 3.3V Logic | LVCMOS33 | 3.3V |
| 2.5V Logic | LVCMOS25 | 2.5V |
| 1.8V Logic | LVCMOS18 | 1.8V |
| LVDS Differential | LVDS_25 | 2.5V |
| DDR3 | MOBILE_DDR | 1.5V |

## Common Errors

### 1. Pin Number Does Not Exist
```
ERROR:MapLib:93 - Invalid LOC constraint
```
**Solution**: Check FPGA datasheet to confirm pin

### 2. IO Standard Mismatch
```
ERROR:MapLib:101 - Invalid IOSTANDARD
```
**Solution**: Select correct IO standard according to hardware voltage

### 3. Differential Pair Polarity Error
**Solution**: Confirm P/N pin order

## Checklist

Before running implementation, confirm:

- [ ] clk_50mhz pin modified according to schematic
- [ ] clk_27mhz pin modified according to schematic
- [ ] rst_n pin modified according to schematic
- [ ] HDMI input TMDS differential pair confirmed
- [ ] HDMI output TMDS differential pair confirmed
- [ ] SPI Flash pins confirmed
- [ ] UART pins confirmed
- [ ] Video DAC pins confirmed
- [ ] LED/Buttons pins confirmed
- [ ] All IO standards correctly set

## Need Help

If you can provide:
1. Screenshot of FPGA section in schematic
2. Or pin assignment list
3. Or PDF schematic

I can help you generate the correct constraint file.

## Related Documents

- `constraints/video_converter.ucf` - Constraint file (needs modification)
- `constraints/README_PINOUT.md` - Pinout check description
- `docs/interface_spec.md` - Interface electrical specifications
- `docs/ise_import_guide.md` - ISE import guide
