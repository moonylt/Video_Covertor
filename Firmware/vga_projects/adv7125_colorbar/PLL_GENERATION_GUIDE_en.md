# PLL Core Generation Guide

## Overview
`clk_wiz_50to40.v` needs to generate a real PLL core using Xilinx Clocking Wizard. The current behavioral model is for syntax checking only and cannot be used for actual hardware.

---

## Method 1: Using Clocking Wizard GUI (Recommended)

### Step 1: Open Clocking Wizard
1. Launch Xilinx ISE 14.7
2. Menu: **Tools → Clocking Wizard**

### Step 2: Device Selection
```
Device Family: Spartan6
Device: xc6slx45
Package: fg484
Speed Grade: -3
```
Click **Next**

### Step 3: Clock Configuration
**Input Clock 1:**
- Source: Select clock pin
- Frequency: **50.000** MHz
- Differential clock: ☐ (Unchecked)

**Output Clock:**
- ☑ CLKOUT1
- Frequency: **40.000** MHz
- Used: Yes
- Buffer: **BUFG**
- Phase (degrees): **0**

Click **Next**

### Step 4: PLL Settings
```
PLL Type:           PLL_ADV
Clock Feedback:     Internal
Input Buffer:       IBUFG
Reset Type:         Active High
Reset on loss of lock: No
```

**PLL Parameters (Auto-calculated):**
```
CLKFBOUT_MULT = 4
DIVCLK_DIVIDE = 1
CLKOUT1_DIVIDE = 5
```
Verification: 50MHz × 4 ÷ 1 ÷ 5 = 40MHz ✓

Click **Next**

### Step 5: Lock and Phase
```
Locked Output: ☑ Yes
Lock range: Default (±10%)
Phase Shift: None
Variable Phase: No
```

Click **Next**

### Step 6: Complete
- Module name: `clk_wiz_50to40`
- Save location: `projects/adv7125_colorbar/src/clk_wiz_50to40.v`
- Click **Generate**

---

## Method 2: Using XCO File

### Create XCO File
Create `clk_wiz_50to40.xco` in ISE:

```
BEGIN PLL_ADV
  PARAM CLKIN1_FREQ = 50.0
  PARAM CLKOUT1_FREQ = 40.0
  PARAM CLKFBOUT_MULT = 4
  PARAM DIVCLK_DIVIDE = 1
  PARAM CLKOUT1_DIVIDE = 5
  PARAM CLKIN1_BUFFER = IBUFG
  PARAM CLKFBOUT_BUFFER = BUFG
  PARAM CLKOUT1_BUFFER = BUFG
  PARAM RESET_TYPE = ACTIVE_HIGH
  PARAM LOCKED_OUTPUT = true
END
```

### Generate Core
```tcl
# Execute in ISE Tcl console
ipcoregen clk_wiz_50to40.xco
```

---

## Generated Port Mapping

Clocking Wizard generated module ports:

```verilog
module clk_wiz_50to40 (
    // Clock in ports
    input           clk_in1,      // 50MHz input
    input           clk_in2,      // Unused
    // Clock out ports
    output          clk_out1,     // 40MHz output
    output          clk_out2,     // Unused
    // Status and control signals
    output          locked,       // PLL lock indicator
    input           reset,        // Reset (active high)
    input           clkfbin,      // Clock feedback
    output          clkfbin       // Clock feedback output
);
```

### Top Module Connection Example

```verilog
clk_wiz_50to40 u_pll (
    .clk_in1      (clk_50mhz),
    .clk_in2      (1'b0),           // Unused
    .clk_out1     (pixel_clk),      // 40MHz pixel clock
    .clk_out2     (),               // Unused
    .reset        (~rst_n),         // Active high reset
    .locked       (pll_locked),     // Lock indicator
    .clkfbin      (pixel_clk),      // Feedback clock
    .clkfbin      ()                // Feedback output
);
```

⚠️ **Note**: Generated PLL core may need port connection adjustments depending on Clocking Wizard version.

---

## Verify PLL Configuration

### Generated Parameters Check
```
Input Clock:     50.000 MHz
Output Clock:    40.000 MHz
Multiplier:      4
Divide:          5
Phase:           0°
Jitter:          < 100ps (typical)
```

### Timing Constraints
Add to UCF file:
```ucf
TIMESPEC "TS_PIXEL_CLK" = PERIOD "pixel_clk" 25.000 ns HIGH 50%;
NET "pixel_clk" CLOCK_DEDICATED_ROUTE = FALSE;
```

---

## Common Issues

### Q1: Generated PLL Cannot Lock
**Check:**
- Input clock frequency is correct (50MHz)
- Reset signal polarity is correct
- Reset time is sufficient (>100ns)

### Q2: Large Output Clock Jitter
**Solution:**
- Select "Low Jitter" optimization in Clocking Wizard
- Check power decoupling capacitors

### Q3: Error During Synthesis
**Possible Causes:**
- PLL core version incompatibility
- Port connection error
- Missing constraint file

**Solution:**
- Regenerate PLL core
- Check port mapping
- Add timing constraints

---

## Temporary Test (Not Recommended)

If only for syntax checking, you can keep the current behavioral model. But **must** replace with real PLL core before downloading to FPGA.

```verilog
// ⚠️ For syntax checking only, cannot be used for hardware!
always @(posedge clk_in1 or posedge reset) begin
    if (reset) counter <= 0;
    else counter <= counter + 1;
    clk_out1 = counter[1];  // Approximate division
end
```

---

## Next Steps

1. ✅ Generate PLL core
2. ✅ Replace `clk_wiz_50to40.v`
3. ✅ Re-synthesize
4. ✅ Implement and generate bitstream
5. ✅ Download to FPGA for testing

---

## Reference Documents
- [Xilinx Clocking Wizard User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx14_7/clocking_wizard_v3_6_ug.pdf)
- [Spartan-6 Clocking Resources](https://www.xilinx.com/support/documentation/user_guides/ug382.pdf)
