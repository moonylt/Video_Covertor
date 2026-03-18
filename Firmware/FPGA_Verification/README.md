# VIDEO_CONVERTER FPGA 验证工程

## 项目概述

本项目是 VIDEO_CONVERTER 硬件平台的 FPGA 功能验证工程，基于 Xilinx Spartan-6 XC6SLX45-3FGG484I FPGA。

**当前版本：最小系统 (仅 HDMI 直通)**

### 主要功能

- **HDMI/DVI 视频输入** - TFP401A 接收器接口 (并行 RGB)
- **HDMI/DVI 视频输出** - TFP410 发射器接口 (并行 RGB)
- **用户接口** - 按键 + LED 指示灯

### 不使用的功能 (已注释)

- **DDR3 内存** - 接口固定为空闲电平
- **SPI Flash** - 仅用于 FPGA 配置，无需用户逻辑
- **UART 串口** - 未使用
- **ADV7125 (VGA DAC)** - 暂时不使用，已注释
- **ADV7393 (CVBS 编码器)** - 暂时不使用，已注释

### 系统架构 (直通模式)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         VIDEO_CONVERTER Top Level                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │   TFP401A    │────▶│   Direct     │────▶│   TFP410     │            │
│  │  HDMI Input  │     │   Connect    │     │ HDMI Output  │            │
│  │ (TMDS→RGB)   │     │   (RGB)      │     │ (RGB→TMDS)   │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│                                                                          │
│  [ADV7125 VGA] - 暂时不使用                                              │
│  [ADV7393 CVBS] - 暂时不使用                                             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 信号流说明

```
HDMI 输入 → TMDS 差分 → TFP401A → 24 位 RGB+ 同步 → FPGA
                                              ↓
                    ┌───────────────────────────┼───────────────────┐
                    ↓                           ↓                   ↓
                TFP410                    ADV7125 (VGA)       ADV7393 (CVBS)
                    ↓
            TMDS 差分 → HDMI 输出
```

**注意**：FPGA 处理的是**并行 RGB 数字视频数据**，不是 TMDS 差分信号！

## 目录结构

```
FPGA_Verification/
├── README.md                          # 项目说明
├── docs/
│   ├── SIGNAL_FLOW.md                 # 信号流说明
│   └── interface_spec.md              # 接口规范
├── src/
│   ├── top/
│   │   ├── video_converter_top.v      # 顶层模块
│   │   ├── clk_wiz_50to100.v          # PLL 时钟模块
│   │   ├── rst_controller_simple.v    # 复位控制器
│   │   └── sys_status_monitor_simple.v# 状态监控
│   └── hdmi/
│       ├── tfp401a_rx.v               # TFP401A 输入驱动
│       └── tfp410_tx.v                # TFP410 输出驱动
├── constraints/
│   └── video_converter.ucf            # 引脚约束
└── sim/
    ├── run_sim.do                     # 仿真脚本
    └── waves.do                       # 波形配置
```

**源文件统计**：6 个 Verilog 文件 + 1 个 UCF 约束文件

## 开发环境

- **FPGA 工具**: Xilinx ISE 14.7
- **仿真工具**: ModelSim / ISim
- **语言**: Verilog HDL
- **目标器件**: XC6SLX45-3FGG484I

## 快速开始

### 1. 打开 ISE 工程

```
File → Open Project → video_converter.xise
```

### 2. 综合与实现

```
Processes 窗口:
1. Synthesize - XST → Run
2. Implement Design → Run
3. Generate Programming File → Run
```

### 3. 下载比特流

```
Tools → iMPACT → Configure Devices → Auto Connect → Program
```

## 引脚分配摘要

### 时钟和复位

| 信号 | 引脚 | 说明 |
|------|------|------|
| clk_50mhz | AA12 | 50MHz 系统时钟 |
| clk_27mhz | AB13 | 27MHz 视频时钟 |
| rst_n | T6 | 全局复位 |

### 视频输入 (TFP401A → FPGA)

| 信号 | 引脚数 | 说明 |
|------|--------|------|
| tfp401_dvi_d[0:23] | 24 | 24 位 RGB 数据 |
| tfp401_de/hs/vs | 3 | 同步信号 |
| tfp401_pclk | 1 | 像素时钟 |

### 视频输出 (FPGA → TFP410)

| 信号 | 引脚数 | 说明 |
|------|--------|------|
| tfp410_dvi_d[0:23] | 24 | 24 位 RGB 数据 |
| tfp410_de/hs/vs | 3 | 同步信号 |
| tfp410_pclk | 1 | 像素时钟 |

### 其他接口

| 接口 | 引脚数 | 说明 |
|------|--------|------|
| 按键 | 2 | 用户按键 |
| LED | 8 | 状态指示 |
| JTAG | 4 | 下载调试 |

详细约束见：`constraints/video_converter.ucf`

## 支持的视频格式

| 格式 | 分辨率 | 刷新率 | 像素时钟 |
|------|--------|--------|----------|
| VGA | 640x480 | 60Hz | 25.175 MHz |
| SVGA | 800x600 | 60Hz | 40.000 MHz |
| XGA | 1024x768 | 60Hz | 65.000 MHz |
| 720p | 1280x720 | 60Hz | 74.250 MHz |
| 1080p | 1920x1080 | 60Hz | 148.500 MHz |

## 状态指示

### LED 含义

| LED | 说明 |
|-----|------|
| LED0 | 电源/运行指示 (常亮) |
| LED1 | 视频输入状态 |
| LED6 | 视频输入活动 |
| LED7 | 视频输出状态 |

### 按键功能

| 按键 | 功能 |
|------|------|
| BTN0 | 保留 |
| BTN1 | 保留 |

## 版本历史

| 版本 | 日期 | 作者 | 说明 |
|------|------|------|------|
| 1.3 | 2026-03-16 | FPGA Team | 注释 ADV7125/ADV7393，最小系统 |
| 1.2 | 2026-03-16 | FPGA Team | 移除 SPI/UART，简化工程 |
| 1.1 | 2026-03-16 | FPGA Team | 修正 TMDS 理解错误 |
| 1.0 | 2026-03-16 | FPGA Team | 初始版本 |

## 相关文档

- `docs/SIGNAL_FLOW.md` - 信号流详细说明
- `docs/architecture.md` - 系统架构
- `constraints/video_converter.ucf` - 完整引脚约束

## 注意事项

1. **TMDS 信号不连接 FPGA** - 由 TFP401A/TFP410 处理
2. **DDR3 接口悬空** - 代码中固定为空闲电平
3. **SPI Flash 仅用于配置** - 无需用户逻辑
4. **UART 未使用** - 相关代码已移除
