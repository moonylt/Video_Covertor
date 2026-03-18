# Synthesis Error Fix Summary

## Fix Date
2026-03-16

## All Fixed Bugs

### 1. UART Controller - rx_shift_reg Type Error

**File**: `src/uart/uart_controller.v` (Line 84)

**Error**:
```
ERROR:HDLCompiler:271 - Cannot index into non-array rx_shift_reg
```

**Fix**:
```verilog
// Before
reg             rx_shift_reg;

// After
reg   [7:0]     rx_shift_reg;
```

---

### 2. UART Controller - FIFO Full Flag Constant Truncation

**File**: `src/uart/uart_controller.v` (Line 275)

**Warning**:
```
WARNING:HDLCompiler:568 - Constant value is truncated to fit in <6> bits.
```

**Fix**:
```verilog
// Before
assign rx_fifo_full = (rx_fifo_count_reg == 6'd64);

// After
assign rx_fifo_full = (rx_fifo_count_reg >= 6'd63);
```

---

### 3. Status Monitor Module - clk Index Error (Simple Version)

**File**: `src/top/sys_status_monitor_simple.v` (Lines 140, 157)

**Error**:
```
ERROR:HDLCompiler:271 - Cannot index into non-array clk
ERROR:HDLCompiler:598 - Module <sys_status_monitor_simple> ignored
```

**Fix**:
Add LED blink counter, replace `clk[24]` and `clk[22]`:

```verilog
// Add new
reg [24:0] blink_counter;
wire       blink_slow;
wire       blink_fast;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        blink_counter <= 25'd0;
    else
        blink_counter <= blink_counter + 25'd1;
end

assign blink_slow = blink_counter[24];
assign blink_fast = blink_counter[20];

// Use in LED control
led_reg <= {7'd0, blink_slow};  // Replace clk[24]
led_reg <= {8{blink_fast}};      // Replace clk[22]
```

---

### 4. Status Monitor Module - clk Index Error (Full Version)

**File**: `src/top/sys_status_monitor.v` (Lines 181, 208)

**Error**:
```
ERROR:HDLCompiler:271 - Cannot index into non-array clk
```

**Fix**: Same as simple version, add blink counter

---

### 5. ADV7393 Driver - output Port Type Error

**File**: `src/test/adv7393_driver.v` (Line 130)

**Error**:
```
ERROR:HDLCompiler:329 - Target <std_sel> of concurrent assignment should be a net type.
ERROR:HDLCompiler:598 - Module <adv7393_driver> ignored due to previous errors.
```

**Fix**:
```verilog
// Before
reg         std_sel;
assign std_sel = 1'b0;  // reg cannot use assign

// After
wire        std_sel = 1'b0;  // 0=NTSC, 1=PAL
```

---

## Fixed File List

| File | Status |
|------|------|
| src/uart/uart_controller.v | ✅ Fixed |
| src/top/sys_status_monitor_simple.v | ✅ Fixed |
| src/top/sys_status_monitor.v | ✅ Fixed |
| src/test/adv7393_driver.v | ✅ Fixed |
| src/flash/spi_flash_ctrl.v | ✅ Fixed |

---

### 6. SPI Flash Controller - Multiple Errors

**File**: `src/flash/spi_flash_ctrl.v` (Lines 81-84, 129-130, 333)

**Errors**:
```
ERROR:HDLCompiler:472 - Illegal character in binary number
ERROR:HDLCompiler:329 - Target <flash_wp_n> should be a net type
ERROR:HDLCompiler:329 - Target <flash_hold_n> should be a net type
ERROR:HDLCompiler:329 - Target <status_reg> should be a net type
```

**Fixes**:

1. **Status Register Bit Definition** - Change to integer:
```verilog
// Before (error)
localparam SR_BUSY    = 1'b0;
localparam SR_BP0     = 1'b2;  // Illegal binary number

// After (correct)
localparam SR_BUSY    = 0;     // Bit 0
localparam SR_BP0     = 2;     // Bit 2
```

2. **output reg with assign** - Change to wire:
```verilog
// Before (error)
output reg  flash_wp_n;
assign flash_wp_n = 1'b1;

// After (correct)
output      flash_wp_n;
assign flash_wp_n = 1'b1;
```

3. **status_reg type** - Separate reg and wire:
```verilog
// Before
reg [7:0] status_reg;
assign status_reg = status_reg_buf;

// After
reg [7:0] status_reg_buf;
wire [7:0] status_reg;
assign status_reg = status_reg_buf;
```

---

## Verification Steps

Re-synthesize in ISE:

```
1. Process → Cleanup Project Files
2. Process → Synthesize - XST → Run
3. View synthesis report
```

**Expected Results**:
```
INFO:Synthesis - Unit <uart_controller> synthesized.
INFO:Synthesis - Unit <sys_status_monitor_simple> synthesized.
INFO:Synthesis - Unit <sys_status_monitor> synthesized.

ERROR:   0
WARNING: 0
```

---

## Technical Notes

### Why can't we use `clk[24]`?

In Verilog, `clk` is a single-bit wire/reg signal, not an array. The correct blink generation method is:

```verilog
// ❌ Wrong
led <= clk[24];

// ✅ Correct
reg [24:0] counter;
always @(posedge clk) counter <= counter + 1;
wire blink = counter[24];
```

### Why does `6'd64` have issues?

The range of 6-bit unsigned numbers is 0-63, `6'd64` will be truncated to 0. Should use:
- `>= 6'd63` (consider full when count reaches 63)
- Or increase bit width to 7 bits `7'd64`

---

## Related Documents

- `fix_summary.txt` - Synthesis fix summary
- `docs/uart_fix.md` - UART fix description
