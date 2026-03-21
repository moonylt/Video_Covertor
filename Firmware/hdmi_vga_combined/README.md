# HDMI + VGA 双输出测试工程

同时输出彩条测试图案到 HDMI (TFP410) 和 VGA (ADV7125) 显示器。

## 功能特性

| 输出接口 | 分辨率 | 刷新率 | 像素时钟 |
|----------|--------|--------|----------|
| HDMI (TFP410) | 1280x720 | 60Hz | 74.25MHz |
| VGA (ADV7125) | 800x600 | 60Hz | 40MHz |

## 测试模式

通过按键 BTN0 切换测试图案：

| 模式 | 图案 |
|------|------|
| 0 | 全白屏幕 |
| 1 | 全红屏幕 |
| 2 | 全绿屏幕 |
| 3 | 全蓝屏幕 |
| 4 | 8 色彩条 |
| 5 | 网格图案 |

## 文件结构

```
hdmi_vga_combined/
├── src/
│   ├── hdmi_vga_top.v           # 顶层模块
│   ├── clk_wiz_dual.v           # PLL 时钟生成 (需替换)
│   ├── hdmi_test_pattern.v      # HDMI 测试图案发生器
│   └── vga_colorbar_800x600.v   # VGA 测试图案发生器
├── constraints/
│   └── hdmi_vga_combined.ucf    # 引脚约束文件
└── README.md
```

## 使用步骤

### 1. 生成 PLL

⚠️ **重要：`clk_wiz_dual.v` 是占位代码，必须替换！**

在 Xilinx ISE 14.7 中：

1. 打开工程后，选择 `Tools → Clocking Wizard`
2. 配置参数：
   - Device: Spartan-6, xc6slx45fgg484-3
   - Input Clock 1: 50.000 MHz
   - Output Clock 1: 74.25 MHz (CLKOUT1) - HDMI 720p
   - Output Clock 2: 40.00 MHz (CLKOUT2) - VGA 800x600
   - PLL Type: PLL_ADV
   - Reset: Active High
   - Locked: Yes
3. 点击 Generate
4. 将生成的文件保存为 `clk_wiz_dual.v`，替换原文件

### 2. 创建 ISE 工程

1. 打开 Xilinx ISE 14.7
2. 创建新工程，选择：
   - Device: xc6slx45fgg484-3
3. 添加源文件：`src/*.v`
4. 添加约束文件：`constraints/hdmi_vga_combined.ucf`

### 3. 编译下载

1. 双击 Synthesize - XST
2. 双击 Implement Design
3. 双击 Generate Programming File
4. 使用 iMPACT 下载 `.bit` 文件到 FPGA

### 4. 测试

1. 连接 HDMI 显示器到 HDMI 输出口
2. 连接 VGA 显示器到 VGA 输出口
3. 按 BTN0 切换测试图案
4. 两个显示器应显示相同的测试图案

## 测试点定义

| 测试点 | 信号 |
|--------|------|
| TP0 | PLL 锁定指示 |
| TP1 | HDMI 数据有效 |
| TP2 | VGA 数据有效 |
| TP3 | HDMI DE |

## 硬件要求

- Xilinx Spartan-6 FPGA (xc6slx45fgg484-3)
- TFP410 HDMI 发送器
- ADV7125 VGA DAC
- 50MHz 系统时钟

## 日期

2026 年 3 月 21 日