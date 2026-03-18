# VIDEO_CONVERTER Pin Constraint Check Guide

## Problem Description

The pin assignments in the current `video_converter.ucf` are **examples** and need to be verified and modified according to the actual PCB schematic.

## Signals That Must Be Confirmed

### 1. Clock and Reset (Critical)

| Signal | Current Assignment | Need to Confirm | Schematic Location |
|------|----------|----------|------------|
| clk_50mhz | H13 | ⚠️ **Must confirm** | Crystal Y1 connects to FPGA |
| clk_27mhz | G13 | ⚠️ **Must confirm** | Crystal Y2 connects to FPGA |
| rst_n | M14 | ⚠️ **Must confirm** | Reset button |

### 2. HDMI Input (U2 - TFP401A)

**TMDS Differential Pairs** - Must confirm according to schematic:

| Signal | Current Assignment | Schematic Net Label |
|------|----------|----------------|
| tmds_rx_clk_p/n | A5/A6 | TMDS_RX_CLK_P/N |
| tmds_rx_data0_p/n | B5/B6 | TMDS_RX_D0_P/N |
| tmds_rx_data1_p/n | C5/C6 | TMDS_RX_D1_P/N |
| tmds_rx_data2_p/n | D5/D6 | TMDS_RX_D2_P/N |

**Parallel Data Output** - Must confirm according to schematic:
```
tfp401_dvi_d[0:23] - Check TFP401A D0-D23 connections to FPGA pins
tfp401_de, tfp401_hs, tfp401_vs, tfp401_pclk - Check corresponding connections
```

### 3. HDMI Output (U3 - TFP410)

Similarly need to confirm TMDS differential pairs and parallel data input connections.

### 4. Other Interfaces

| Interface | Signals | Need to Confirm |
|------|------|----------|
| SPI Flash | flash_cs_n, clk, mosi, miso | ⚠️ Check U123 connections |
| UART | uart_tx, uart_rx | ⚠️ Check U104 connections |
| ADV7125 | dac_red/green/blue[0:9], clk | ⚠️ Check U4 connections |
| ADV7393 | data[0:19], clk, load, std | ⚠️ Check U111 connections |
| LED/Buttons | led[0:7], btn_n[0:1] | ⚠️ Check connectors |

## How to Extract Correct Pins from Schematic

### Step 1: Open Altium Schematic

1. Open `Sch/Altium_VIDEO_CONVERTER_2026-03-16/VIDEO_CONVERTER/Board1/Schematic1/P1.schdoc`
2. Find FPGA device (U8 - XC6SLX45)
3. View pin connections for each Bank

### Step 2: Extract FPGA Pins

For each signal that needs constraints:

1. Find net label in schematic
2. View which FPGA pin it connects to
3. Record pin number (such as A5, B5, etc.)

### Step 3: Update UCF File

Modify `video_converter.ucf`, replace example pins with actual pins:

```ucf
# Example (needs modification)
NET "clk_50mhz"  LOC = H13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;

# Actual value (according to schematic)
NET "clk_50mhz"  LOC = <actual pin> | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

## Common Constraint Issues

### Issue 1: Pin Number Does Not Exist

**Error**: `ERROR:MapLib:93 - Invalid LOC constraint`

**Cause**: Pin number is wrong or does not exist

**Solution**: Check FPGA datasheet to confirm pin

### Issue 2: IO Standard Mismatch

**Error**: `ERROR:MapLib:101 - Invalid IOSTANDARD`

**Cause**: IO standard does not match hardware

**Solution**:
- LVDS differential pair: `IOSTANDARD = LVDS_25`
- 3.3V logic: `IOSTANDARD = LVCMOS33`
- 2.5V logic: `IOSTANDARD = LVCMOS25`

### Issue 3: DDR Pin Constraint Error

**Note**: DDR3 pins are currently unused and fixed at idle state

If DDR3 is enabled in the future, need to use `IOSTANDARD = MOBILE_DDR`

## Complete Constraint File Template

See `video_converter.ucf` file, but **all LOC values need to be modified according to schematic**.

## Checklist

Before running synthesis and implementation, confirm:

- [ ] Clock pins confirmed according to schematic
- [ ] Reset pins confirmed according to schematic
- [ ] HDMI input TMDS differential pairs confirmed
- [ ] HDMI input parallel data confirmed
- [ ] HDMI output TMDS differential pairs confirmed
- [ ] SPI Flash pins confirmed
- [ ] UART pins confirmed
- [ ] Video DAC pins confirmed
- [ ] LED/Buttons pins confirmed
- [ ] All IO standards correctly set

## Need Help

If you have PDF schematic or can export pin list, I can help you generate the correct constraint file.

**Required Information**:
1. FPGA pin assignment table (exported from Altium)
2. Or screenshot of FPGA section in schematic
3. Or connector information from BOM

## Related Documents

- `constraints/video_converter.ucf` - Current constraint file (needs modification)
- `docs/interface_spec.md` - Interface electrical specifications
- `README.md` - Project description
