# VIDEO_CONVERTER FPGA 工程 - 信号流说明

## 正确的信号流理解

### 系统架构

```
                    HDMI 输入接口
                         │
                         ▼
              ┌─────────────────────┐
              │   TMDS 差分信号     │  ← 不连接 FPGA
              │  (3 对数据 +1 对时钟) │
              └─────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │    U2 - TFP401A     │  ← HDMI 接收器
              │   (TMDS 解码器)      │
              └─────────────────────┘
                         │
                         ▼ 24 位 RGB + DE/HS/VS/PCLK
              ┌─────────────────────┐
              │      FPGA (U8)      │  ← 处理并行数字视频数据
              │  XC6SLX45-3FGG484I  │     (不是 TMDS 信号！)
              └─────────────────────┘
                         │
                         ▼ 24 位 RGB + DE/HS/VS/PCLK
              ┌─────────────────────┐
              │    U3 - TFP410      │  ← HDMI 发射器
              │   (TMDS 编码器)      │
              └─────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   TMDS 差分信号     │  ← 不连接 FPGA
              │  (3 对数据 +1 对时钟) │
              └─────────────────────┘
                         │
                         ▼
                    HDMI 输出接口
```

## FPGA 引脚分配总结

### 视频输入 (TFP401A → FPGA)

| 信号 | 引脚数 | FPGA 引脚 | 说明 |
|------|--------|-----------|------|
| tfp401_dvi_d[0:7] | 8 | C5,A5,D6,C6,A6,B6,C7,A7 | 蓝色通道 |
| tfp401_dvi_d[8:15] | 8 | D7,D8,A8,B8,C8,A9,C9,D9 | 绿色通道 |
| tfp401_dvi_d[16:23] | 8 | C14,B14,A14,D15,C15,A15,E16,C16 | 红色通道 |
| tfp401_de | 1 | C17 | 数据使能 |
| tfp401_hs | 1 | A18 | 行同步 |
| tfp401_vs | 1 | B18 | 场同步 |
| tfp401_pclk | 1 | B10 | 像素时钟 |
| **合计** | **27** | | |

### 视频输出 (FPGA → TFP410)

| 信号 | 引脚数 | FPGA 引脚 | 说明 |
|------|--------|-----------|------|
| tfp410_dvi_d[0:7] | 8 | W10,T11,R11,T12,U12,Y12,V13,T14 | 蓝色通道 |
| tfp410_dvi_d[8:15] | 8 | W14,AB14,Y14,W15,AB15,T16,Y16,AB16 | 绿色通道 |
| tfp410_dvi_d[16:23] | 8 | AA16,Y17,AB17,V18,W18,AB18,AA18,AB19 | 红色通道 |
| tfp410_de | 1 | Y11 | 数据使能 |
| tfp410_hs | 1 | Y10 | 行同步 |
| tfp410_vs | 1 | AA10 | 场同步 |
| tfp410_pclk | 1 | AB12 | 像素时钟 |
| **合计** | **27** | | |

### 其他接口

| 接口 | 信号数 | 说明 |
|------|--------|------|
| 时钟 | 2 | 50MHz (AA12), 27MHz (AB13) |
| 复位 | 1 | rst_n (T6) |
| SPI Flash | 6 | flash_cs/clk/mosi/miso/wp/hold |
| UART | 2 | uart_tx (V17), uart_rx (R15) |
| ADV7125 | 33 | RGB 数据 + 时钟 + 控制 |
| ADV7393 | 20 | 视频数据 + 时钟 + 控制 |
| 按键 | 3 | btn_n[0:2] |
| LED | 1 | led[0] |
| JTAG | 4 | TCK/TDI/TDO/TMS |
| I2C | 4 | DVI/HDMI I2C |

## 重要说明

### ❌ 错误理解
- TMDS 差分信号直接连接 FPGA
- FPGA 处理 TMDS 编码/解码

### ✅ 正确理解
- **TMDS 差分信号不连接 FPGA**
- **TFP401A 将 TMDS 解码为并行 RGB 数据**
- **TFP410 将并行 RGB 数据编码为 TMDS**
- **FPGA 只处理并行数字视频数据 (24 位 RGB + 同步信号)**

## 视频数据格式

### TFP401A 输出到 FPGA

```
tfp401_dvi_d[23:16] - 红色数据 (R7-R0)
tfp401_dvi_d[15:8]  - 绿色数据 (G7-G0)
tfp401_dvi_d[7:0]   - 蓝色数据 (B7-B0)
tfp401_de           - 数据使能 (高有效)
tfp401_hs           - 行同步 (高有效)
tfp401_vs           - 场同步 (高有效)
tfp401_pclk         - 像素时钟 (上升沿采样)
```

### FPGA 输出到 TFP410

```
tfp410_dvi_d[23:16] - 红色数据 (R7-R0)
tfp410_dvi_d[15:8]  - 绿色数据 (G7-G0)
tfp410_dvi_d[7:0]   - 蓝色数据 (B7-B0)
tfp410_de           - 数据使能 (高有效)
tfp410_hs           - 行同步 (高有效)
tfp410_vs           - 场同步 (高有效)
tfp410_pclk         - 像素时钟 (上升沿采样)
```

## 修改的文件

1. `src/top/video_converter_top.v` - 移除 TMDS 差分端口
2. `constraints/video_converter.ucf` - 移除 TMDS 约束

## 支持的视频格式

| 格式 | 分辨率 | 刷新率 | 像素时钟 |
|------|--------|--------|----------|
| VGA | 640x480 | 60Hz | 25.175 MHz |
| SVGA | 800x600 | 60Hz | 40.000 MHz |
| XGA | 1024x768 | 60Hz | 65.000 MHz |
| 720p | 1280x720 | 60Hz | 74.250 MHz |
| 1080p | 1920x1080 | 60Hz | 148.500 MHz |

## 参考资料

- TFP401A 数据手册：https://www.ti.com/product/TFP401A
- TFP410 数据手册：https://www.ti.com/product/TFP410
- Spartan-6 数据手册：https://www.xilinx.com/products/silicon-devices/fpga/spartan-6.html
