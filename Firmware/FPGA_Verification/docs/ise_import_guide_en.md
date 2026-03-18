# ISE Project Import Guide

## Method 1: Use Existing Project File (Recommended)

### Step 1: Open Xilinx ISE

1. Launch **Xilinx ISE Design Suite 14.7**
2. Click `File` → `Open Project`

### Step 2: Select Project File

1. Browse to project directory:
   ```
   F:\Video_Covertor\Firmware\FPGA_Verification\
   ```
2. Select `video_converter.xise` file
3. Click `Open`

### Step 3: Verify Project Configuration

In **Sources** window, you should see the following file structure:

```
video_converter
├── Design Files
│   ├── video_converter_top.v
│   ├── rst_controller_simple.v
│   ├── sys_status_monitor_simple.v
│   ├── tfp401a_rx.v
│   ├── tfp410_tx.v
│   ├── spi_flash_ctrl.v
│   ├── uart_controller.v
│   ├── video_timing_gen.v
│   ├── video_frame_buffer.v
│   ├── adv7125_driver.v
│   └── adv7393_driver.v
├── Constraints
│   └── video_converter.ucf
└── Libraries
    └── work
```

### Step 4: Check Device Configuration

1. In **Processes** window, expand `Synthesize - XST`
2. Right-click `Synthesize - XST` → `Properties`
3. Confirm the following settings:
   - **Family**: Spartan6
   - **Device**: xc6slx45
   - **Package**: fgg484
   - **Speed**: -3

### Step 5: Run Synthesis

1. In **Processes** window, click `Synthesize - XST`
2. Wait for synthesis to complete (check bottom **Console** window)
3. Check for errors

### Step 6: Implement Project

After successful synthesis, run in sequence:

1. **Implement Design**
   - Translate
   - Map
   - Place & Route

2. Generate Bitstream
   - Generate Programming File

---

## Method 2: Manually Create Project

If Method 1 has issues, create manually:

### Step 1: New Project

1. `File` → `New Project`
2. Set project name and location:
   - **Name**: video_converter
   - **Location**: `F:\Video_Covertor\Firmware\FPGA_Verification\`
3. Select project type:
   - **Project Type**: HDL
   - **Synthesis Tool**: XST (VHDL/Verilog)
   - **Simulator**: ISim (VHDL/Verilog)
4. Click `Next`

### Step 2: Add Source Files

1. Click `Add Source`
2. Browse and select all `.v` files:
   ```
   src/top/video_converter_top.v
   src/top/rst_controller_simple.v
   src/top/sys_status_monitor_simple.v
   src/hdmi/tfp401a_rx.v
   src/hdmi/tfp410_tx.v
   src/flash/spi_flash_ctrl.v
   src/uart/uart_controller.v
   src/video/video_timing_gen.v
   src/video/video_frame_buffer.v
   src/video/adv7125_driver.v
   src/test/adv7393_driver.v
   ```
3. Click `OK` → `Next`

### Step 3: Add Constraint Files

1. Click `Add Source`
2. Select file type: `Implementation Constraints File`
3. Select `constraints/video_converter.ucf`
4. Click `OK` → `Next`

### Step 4: Configure Device

1. Select device:
   - **Family**: Spartan6
   - **Series**: Any
   - **Device**: xc6slx45
   - **Package**: fgg484
   - **Speed**: -3
2. Click `Next`

### Step 5: Complete Project Creation

1. Review project summary
2. Click `Finish`

---

## Common Problem Solutions

### Issue 1: Device Not Found

**Error**: `Device xc6slx45 not found`

**Solution**:
1. Confirm Spartan-6 support package is installed
2. `Help` → `Check for Updates`
3. Install missing device support

### Issue 2: Synthesis Error

**Error**: `Syntax error near ...`

**Solution**:
1. Check Verilog syntax
2. Confirm all modules are added
3. Check **Console** window for detailed error messages

### Issue 3: Constraint Conflict

**Error**: `Constraint override ...`

**Solution**:
1. Check UCF file
2. Confirm pin assignment has no conflicts
3. Check `Map Report`

### Issue 4: Clock Constraint Issue

**Error**: `Period constraint not met`

**Solution**:
1. Check clock frequency settings
2. Adjust timing constraints
3. Check `Timing Report`

---

## Synthesis Option Configuration

### Recommended Settings

Configure in `Synthesize - XST` → `Properties`:

```
HDL Options:
  - Top Module Name: video_converter_top
  - Compiler Effort Level: High
  - FSM Encoding Algorithm: Auto
  - Safe Implementation: No
  - FSM Style: LUT

Synthesis Options:
  - Optimization Goal: Area
  - Optimization Effort: High
  - Use Clock Enable: Auto
  - Use Sync Set: Auto
  - Use Sync Reset: Auto
  - Max Fanout: 500
  - Register Balancing: Yes
  - Register Duplication: Yes

Xilinx Specific Options:
  - Equivalent Register Removal: Yes
  - Resource Sharing: Auto
  - Shift Extraction: Yes
```

---

## Implementation Flow

### Complete Flow

```
1. Synthesize - XST
   └─> Generate .ngc file

2. Implement Design
   ├─> Translate (.ngd)
   ├─> Map (.ncd)
   ├─> Place & Route (.ncd)
   └─> Generate Programming File (.bit)
```

### View Reports

After each step completes, view corresponding report:

- **Synthesis Report**: Synthesis results
- **Map Report**: Mapping results
- **Place & Route Report**: Place and route results
- **Timing Report**: Timing analysis

---

## Bitstream Generation

### Configuration Options

In `Generate Programming File` → `Properties`:

```
Configuration Options:
  - Startup Clock: CCLK
  - Persist: 3-State
  - Done Pipe: No
  - Drive Done Pin High: No

Bitstream Options:
  - Enable Bitstream Compression: No
  - Enable Internal Done Pipe: No
  - Mask Pin: No
  - Readback: No
  - Security: No
```

### Generate Bitstream

1. Right-click `Generate Programming File`
2. Click `Run`
3. Generated bitstream file: `video_converter.bit`

---

## Download Configuration

### Using iMPACT

1. `Tools` → `iMPACT - Configure FPGAs and PROMs`
2. Select `Configure Devices using Boundary-Scan (JTAG)`
3. Select `Auto Connect`
4. Right-click FPGA → `Program`
5. Select `video_converter.bit` file
6. Click `OK` to start download

### Using Adept/Digilent

If using Digilent downloader:

1. Open Adept software
2. Select device
3. Load `video_converter.bit`
4. Click `Program`

---

## Debug Methods

### ChipScope Integration

1. Add ChipScope core to top module
2. Re-synthesize
3. Use ChipScope Pro to capture signals

### LED Debug

Use onboard LEDs:
- LED[0]: Power/Run indicator
- LED[1]: Video input status
- LED[6:2]: Reserved
- LED[7]: Video output status

### UART Debug

Output debug information through CP2102N:
- Baud rate: 115200
- Data bits: 8
- Stop bits: 1
- Parity: None

---

## Version Information

| Item | Value |
|------|-----|
| ISE Version | 14.7 |
| Device | XC6SLX45-FGG484 |
| Speed Grade | -3 |
| Project Version | 1.1 (No-DDR3) |

---

## Related Documents

- `README.md` - Project description
- `docs/architecture.md` - System architecture
- `docs/interface_spec.md` - Interface specification
- `docs/test_plan.md` - Test plan
