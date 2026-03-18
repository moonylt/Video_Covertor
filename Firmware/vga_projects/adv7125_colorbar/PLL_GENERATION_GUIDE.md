# PLL 核生成指南

## 概述
`clk_wiz_50to40.v` 需要使用 Xilinx Clocking Wizard 生成真正的 PLL 核。当前的行为级模型仅用于语法检查，不能用于实际硬件。

---

## 方法 1: 使用 Clocking Wizard GUI (推荐)

### 步骤 1: 打开 Clocking Wizard
1. 启动 Xilinx ISE 14.7
2. 菜单：**Tools → Clocking Wizard**

### 步骤 2: 设备选择
```
Device Family: Spartan6
Device: xc6slx45
Package: fg484
Speed Grade: -3
```
点击 **Next**

### 步骤 3: 时钟配置
**Input Clock 1:**
- Source: Select clock pin
- Frequency: **50.000** MHz
- Differential clock: ☐ (不勾选)

**Output Clock:**
- ☑ CLKOUT1
- Frequency: **40.000** MHz
- Used: Yes
- Buffer: **BUFG**
- Phase (degrees): **0**

点击 **Next**

### 步骤 4: PLL 设置
```
PLL Type:           PLL_ADV
Clock Feedback:     Internal
Input Buffer:       IBUFG
Reset Type:         Active High
Reset on loss of lock: No
```

**PLL Parameters (自动计算):**
```
CLKFBOUT_MULT = 4
DIVCLK_DIVIDE = 1
CLKOUT1_DIVIDE = 5
```
验证：50MHz × 4 ÷ 1 ÷ 5 = 40MHz ✓

点击 **Next**

### 步骤 5: 锁定和相位
```
Locked Output: ☑ Yes
Lock range: Default (±10%)
Phase Shift: None
Variable Phase: No
```

点击 **Next**

### 步骤 6: 完成
- Module name: `clk_wiz_50to40`
- 保存位置：`projects/adv7125_colorbar/src/clk_wiz_50to40.v`
- 点击 **Generate**

---

## 方法 2: 使用 XCO 文件

### 创建 XCO 文件
在 ISE 中创建 `clk_wiz_50to40.xco`:

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

### 生成核
```tcl
# 在 ISE Tcl 控制台执行
ipcoregen clk_wiz_50to40.xco
```

---

## 生成的端口映射

Clocking Wizard 生成的模块端口：

```verilog
module clk_wiz_50to40 (
    // Clock in ports
    input           clk_in1,      // 50MHz 输入
    input           clk_in2,      // 未使用
    // Clock out ports
    output          clk_out1,     // 40MHz 输出
    output          clk_out2,     // 未使用
    // Status and control signals
    output          locked,       // PLL 锁定指示
    input           reset,        // 复位 (高有效)
    input           clkfbin,      // 时钟反馈
    output          clkfbin       // 时钟反馈输出
);
```

### 顶层模块连接示例

```verilog
clk_wiz_50to40 u_pll (
    .clk_in1      (clk_50mhz),
    .clk_in2      (1'b0),           // 未使用
    .clk_out1     (pixel_clk),      // 40MHz 像素时钟
    .clk_out2     (),               // 未使用
    .reset        (~rst_n),         // 高有效复位
    .locked       (pll_locked),     // 锁定指示
    .clkfbin      (pixel_clk),      // 反馈时钟
    .clkfbin      ()                // 反馈输出
);
```

⚠️ **注意**: 生成的 PLL 核可能需要调整端口连接，具体取决于 Clocking Wizard 版本。

---

## 验证 PLL 配置

### 生成的参数检查
```
Input Clock:     50.000 MHz
Output Clock:    40.000 MHz
Multiplier:      4
Divide:          5
Phase:           0°
Jitter:          < 100ps (typical)
```

### 时序约束
在 UCF 文件中添加：
```ucf
TIMESPEC "TS_PIXEL_CLK" = PERIOD "pixel_clk" 25.000 ns HIGH 50%;
NET "pixel_clk" CLOCK_DEDICATED_ROUTE = FALSE;
```

---

## 常见问题

### Q1: 生成的 PLL 无法锁定
**检查:**
- 输入时钟频率是否正确 (50MHz)
- 复位信号极性是否正确
- 复位时间是否足够 (>100ns)

### Q2: 输出时钟抖动大
**解决:**
- 在 Clocking Wizard 中选择 "Low Jitter" 优化
- 检查电源去耦电容

### Q3: 综合时报错
**可能原因:**
- PLL 核版本不兼容
- 端口连接错误
- 约束文件缺失

**解决:**
- 重新生成 PLL 核
- 检查端口映射
- 添加时序约束

---

## 临时测试 (不推荐)

如果仅用于语法检查，可以保留当前的行为级模型。但下载到 FPGA 前**必须**替换为真正的 PLL 核。

```verilog
// ⚠️ 仅用于语法检查，不能用于硬件！
always @(posedge clk_in1 or posedge reset) begin
    if (reset) counter <= 0;
    else counter <= counter + 1;
    clk_out1 = counter[1];  // 近似分频
end
```

---

## 下一步

1. ✅ 生成 PLL 核
2. ✅ 替换 `clk_wiz_50to40.v`
3. ✅ 重新综合
4. ✅ 实现并生成比特流
5. ✅ 下载到 FPGA 测试

---

## 参考文档
- [Xilinx Clocking Wizard User Guide](https://www.xilinx.com/support/documentation/sw_manuals/xilinx14_7/clocking_wizard_v3_6_ug.pdf)
- [Spartan-6 Clocking Resources](https://www.xilinx.com/support/documentation/user_guides/ug382.pdf)
