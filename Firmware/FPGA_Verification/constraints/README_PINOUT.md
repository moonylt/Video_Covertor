# VIDEO_CONVERTER 管脚约束检查指南

## 问题说明

当前 `video_converter.ucf` 中的管脚分配是**示例性的**，需要根据实际 PCB 原理图进行验证和修改。

## 必须确认的信号

### 1. 时钟和复位（关键）

| 信号 | 当前分配 | 需要确认 | 原理图位置 |
|------|----------|----------|------------|
| clk_50mhz | H13 | ⚠️ **必须确认** | 晶振 Y1 连接到 FPGA |
| clk_27mhz | G13 | ⚠️ **必须确认** | 晶振 Y2 连接到 FPGA |
| rst_n | M14 | ⚠️ **必须确认** | 复位按键 |

### 2. HDMI 输入 (U2 - TFP401A)

**TMDS 差分对** - 必须根据原理图确认：

| 信号 | 当前分配 | 原理图网络标号 |
|------|----------|----------------|
| tmds_rx_clk_p/n | A5/A6 | TMDS_RX_CLK_P/N |
| tmds_rx_data0_p/n | B5/B6 | TMDS_RX_D0_P/N |
| tmds_rx_data1_p/n | C5/C6 | TMDS_RX_D1_P/N |
| tmds_rx_data2_p/n | D5/D6 | TMDS_RX_D2_P/N |

**并行数据输出** - 必须根据原理图确认：
```
tfp401_dvi_d[0:23] - 检查 TFP401A 的 D0-D23 连接到 FPGA 的哪些引脚
tfp401_de, tfp401_hs, tfp401_vs, tfp401_pclk - 检查对应连接
```

### 3. HDMI 输出 (U3 - TFP410)

同样需要确认 TMDS 差分对和并行数据输入的连接。

### 4. 其他接口

| 接口 | 信号 | 需要确认 |
|------|------|----------|
| SPI Flash | flash_cs_n, clk, mosi, miso | ⚠️ 检查 U123 连接 |
| UART | uart_tx, uart_rx | ⚠️ 检查 U104 连接 |
| ADV7125 | dac_red/green/blue[0:9], clk | ⚠️ 检查 U4 连接 |
| ADV7393 | data[0:19], clk, load, std | ⚠️ 检查 U111 连接 |
| LED/按键 | led[0:7], btn_n[0:1] | ⚠️ 检查连接器 |

## 如何从原理图提取正确的管脚

### 步骤 1：打开 Altium 原理图

1. 打开 `Sch/Altium_VIDEO_CONVERTER_2026-03-16/VIDEO_CONVERTER/Board1/Schematic1/P1.schdoc`
2. 找到 FPGA 器件（U8 - XC6SLX45）
3. 查看每个 Bank 的引脚连接

### 步骤 2：提取 FPGA 引脚

对于每个需要约束的信号：

1. 在原理图中找到网络标号
2. 查看连接到 FPGA 的哪个引脚
3. 记录引脚号（如 A5, B5 等）

### 步骤 3：更新 UCF 文件

修改 `video_converter.ucf`，将示例引脚替换为实际引脚：

```ucf
# 示例（需要修改）
NET "clk_50mhz"  LOC = H13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;

# 实际值（根据原理图）
NET "clk_50mhz"  LOC = <实际引脚> | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

## 常见约束问题

### 问题 1：引脚号不存在

**错误**：`ERROR:MapLib:93 - Invalid LOC constraint`

**原因**：引脚号写错或不存在

**解决**：检查 FPGA 数据手册确认引脚

### 问题 2：IO 标准不匹配

**错误**：`ERROR:MapLib:101 - Invalid IOSTANDARD`

**原因**：IO 标准与硬件不匹配

**解决**：
- LVDS 差分对：`IOSTANDARD = LVDS_25`
- 3.3V 逻辑：`IOSTANDARD = LVCMOS33`
- 2.5V 逻辑：`IOSTANDARD = LVCMOS25`

### 问题 3：DDR 引脚约束错误

**注意**：DDR3 引脚当前未使用，已固定为空闲电平

如果将来启用 DDR3，需要使用 `IOSTANDARD = MOBILE_DDR`

## 完整的约束文件模板

见 `video_converter.ucf` 文件，但**所有 LOC 值需要根据原理图修改**。

## 检查清单

在运行综合和实现之前，请确认：

- [ ] 时钟引脚已根据原理图确认
- [ ] 复位引脚已根据原理图确认
- [ ] HDMI 输入 TMDS 差分对已确认
- [ ] HDMI 输入并行数据已确认
- [ ] HDMI 输出 TMDS 差分对已确认
- [ ] SPI Flash 引脚已确认
- [ ] UART 引脚已确认
- [ ] 视频 DAC 引脚已确认
- [ ] LED/按键引脚已确认
- [ ] 所有 IO 标准正确设置

## 需要帮助

如果您有原理图的 PDF 或可以导出引脚列表，我可以帮助您生成正确的约束文件。

**所需信息**：
1. FPGA 引脚分配表（从 Altium 导出）
2. 或者原理图中 FPGA 部分的截图
3. 或者 BOM 表中的连接器信息

## 相关文档

- `constraints/video_converter.ucf` - 当前约束文件（需要修改）
- `docs/interface_spec.md` - 接口电气规格
- `README.md` - 项目说明
