# ISE Project Import - Quick Reference Card

## One-Click Import (Method 1)

```
1. Open Xilinx ISE 14.7
2. File → Open Project
3. Select: video_converter.xise
4. Click Open
```

## Manual Creation (Method 2)

```
1. File → New Project
   - Name: video_converter
   - Location: F:\Video_Covertor\Firmware\FPGA_Verification

2. Project Type:
   - HDL
   - XST (VHDL/Verilog)
   - ISim

3. Add Source (all .v files):
   ✓ src/top/video_converter_top.v
   ✓ src/top/rst_controller_simple.v
   ✓ src/top/sys_status_monitor_simple.v
   ✓ src/hdmi/tfp401a_rx.v
   ✓ src/hdmi/tfp410_tx.v
   ✓ src/flash/spi_flash_ctrl.v
   ✓ src/uart/uart_controller.v
   ✓ src/video/video_timing_gen.v
   ✓ src/video/video_frame_buffer.v
   ✓ src/video/adv7125_driver.v
   ✓ src/test/adv7393_driver.v

4. Add Constraints:
   ✓ constraints/video_converter.ucf

5. Device Configuration:
   - Family: Spartan6
   - Device: xc6slx45
   - Package: fgg484
   - Speed: -3
```

## Synthesis and Implementation Flow

```
Processes Window Operation Sequence:

1. Synthesize - XST          [Right-click → Run]
   ↓
2. Implement Design          [Right-click → Run]
   ├─ Translate
   ├─ Map
   └─ Place & Route
   ↓
3. Generate Programming File [Right-click → Run]
   ↓
Generate: video_converter.bit
```

## Download Bitstream

```
1. Tools → iMPACT
2. Configure Devices using Boundary-Scan (JTAG)
3. Auto Connect
4. Right-click FPGA → Program
5. Select: video_converter.bit
6. OK
```

## Key Settings Check

### Synthesis Settings
```
Synthesize - XST → Properties:
- Top Module: video_converter_top
- Effort Level: High
- Max Fanout: 500
```

### Device Settings
```
Device: XC6SLX45-FGG484-3
```

### Constraint File
```
video_converter.ucf (includes all pin constraints)
```

## Expected Results

### Synthesis Report
```
- Total LUTs: ~2000-3000
- Total Registers: ~1500-2000
- IOs: ~200
```

### Implementation Report
```
- Slice LUTs: < 15%
- Slice Registers: < 10%
- Timing: All constraints met
```

## Troubleshooting

| Problem | Solution |
|------|------|
| Device not found | Install Spartan-6 support package |
| Syntax error | Check Verilog version compatibility |
| Constraint conflict | Check Map Report |
| Timing violation | Adjust constraints or optimize code |

## Contact Support

Detailed documentation: `docs/ise_import_guide.md`
