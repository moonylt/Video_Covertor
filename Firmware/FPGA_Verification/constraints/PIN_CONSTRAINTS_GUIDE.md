# 管脚约束检查与修复指南

## 问题状态

⚠️ **当前管脚约束是示例性的，需要根据实际 PCB 原理图修改**

## 已更新的文件

| 文件 | 说明 | 状态 |
|------|------|------|
| `constraints/video_converter.ucf` | 主约束文件 | ⚠️ 需要修改 |
| `constraints/README_PINOUT.md` | 管脚检查指南 | ✅ 已创建 |
| `constraints/PIN_CONSTRAINTS_GUIDE.md` | 本指南 | ✅ 已创建 |

## 为什么需要修改

当前的 UCF 文件中的引脚分配（如 `LOC = H13`）是**示例值**，不是根据您的实际 PCB 设计的。

**必须修改的信号**：
1. **时钟** - clk_50mhz, clk_27mhz
2. **复位** - rst_n
3. **HDMI 输入/输出** - TMDS 差分对和并行数据
4. **SPI Flash** - flash_cs_n, clk, mosi, miso
5. **UART** - uart_tx, uart_rx
6. **视频 DAC** - adv7125_red/green/blue
7. **LED/按键** - led[0:7], btn_n[0:1]

## 如何从原理图提取正确的引脚

### 方法 1：使用 Altium Designer

1. 打开原理图：`Sch/Altium_VIDEO_CONVERTER_2026-03-16/.../P1.schdoc`
2. 找到 FPGA (U8 - XC6SLX45)
3. 查看每个引脚的连接
4. 记录网络标号和 FPGA 引脚号

### 方法 2：导出引脚列表

在 Altium 中：
1. `Reports` → `Bill of Materials`
2. 选择 FPGA 引脚信息
3. 导出为 Excel 或 CSV

### 方法 3：查看 PDF 原理图

打开 `Sch/Video_CovertorSCH_Schematic1_2026-03-16.pdf`
查找 FPGA 部分，记录引脚连接

## 修改 UCF 文件的步骤

### 步骤 1：打开约束文件

编辑 `constraints/video_converter.ucf`

### 步骤 2：找到需要修改的信号

例如，时钟信号：
```ucf
NET "clk_50mhz"  LOC = H13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

### 步骤 3：根据原理图修改引脚号

如果原理图上 clk_50mhz 连接到 FPGA 的 T13 引脚：
```ucf
NET "clk_50mhz"  LOC = T13 | IOSTANDARD = LVCMOS33 | PERIOD = 20.000 ns;
```

### 步骤 4：保存并验证

## IO 标准设置

根据信号类型选择正确的 IO 标准：

| 信号类型 | IO 标准 | 电压 |
|----------|---------|------|
| 3.3V 逻辑 | LVCMOS33 | 3.3V |
| 2.5V 逻辑 | LVCMOS25 | 2.5V |
| 1.8V 逻辑 | LVCMOS18 | 1.8V |
| LVDS 差分 | LVDS_25 | 2.5V |
| DDR3 | MOBILE_DDR | 1.5V |

## 常见错误

### 1. 引脚号不存在
```
ERROR:MapLib:93 - Invalid LOC constraint
```
**解决**：检查 FPGA 数据手册确认引脚

### 2. IO 标准不匹配
```
ERROR:MapLib:101 - Invalid IOSTANDARD
```
**解决**：根据硬件电压选择正确的 IO 标准

### 3. 差分对极性错误
**解决**：确认 P/N 引脚顺序

## 检查清单

在运行实现之前，请确认：

- [ ] clk_50mhz 引脚已根据原理图修改
- [ ] clk_27mhz 引脚已根据原理图修改
- [ ] rst_n 引脚已根据原理图修改
- [ ] HDMI 输入 TMDS 差分对已确认
- [ ] HDMI 输出 TMDS 差分对已确认
- [ ] SPI Flash 引脚已确认
- [ ] UART 引脚已确认
- [ ] 视频 DAC 引脚已确认
- [ ] LED/按键引脚已确认
- [ ] 所有 IO 标准正确设置

## 需要帮助

如果您可以提供：
1. 原理图中 FPGA 部分的截图
2. 或引脚分配列表
3. 或 PDF 原理图

我可以帮助您生成正确的约束文件。

## 相关文档

- `constraints/video_converter.ucf` - 约束文件（需要修改）
- `constraints/README_PINOUT.md` - 管脚检查说明
- `docs/interface_spec.md` - 接口电气规格
- `docs/ise_import_guide.md` - ISE 导入指南
