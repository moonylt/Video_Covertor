# FPGA 工程完整性和导入指南

## ✅ 工程文件完整性确认

### 所有必需模块已创建

| 模块 | 文件路径 | 状态 |
|------|----------|------|
| **顶层模块** | src/top/video_converter_top.v | ✅ |
| **PLL 时钟** | src/top/clk_wiz_50to100.v | ✅ |
| **复位控制器** | src/top/rst_controller_simple.v | ✅ |
| **状态监控** | src/top/sys_status_monitor_simple.v | ✅ |
| **HDMI 输入** | src/hdmi/tfp401a_rx.v | ✅ |
| **HDMI 输出** | src/hdmi/tfp410_tx.v | ✅ |
| **SPI Flash** | src/flash/spi_flash_ctrl.v | ✅ |
| **UART** | src/uart/uart_controller.v | ✅ |
| **视频时序** | src/video/video_timing_gen.v | ✅ |
| **ADV7125** | src/video/adv7125_driver.v | ✅ |
| **ADV7393** | src/test/adv7393_driver.v | ✅ |

**总计：11 个核心模块，全部已创建 ✅**

---

## 📁 完整文件列表

### 源文件 (12 个)
```
src/top/video_converter_top.v          ← 顶层模块
src/top/clk_wiz_50to100.v              ← PLL 时钟生成
src/top/rst_controller_simple.v        ← 复位控制
src/top/sys_status_monitor_simple.v    ← 状态监控
src/hdmi/tfp401a_rx.v                  ← HDMI 输入
src/hdmi/tfp410_tx.v                   ← HDMI 输出
src/flash/spi_flash_ctrl.v             ← SPI Flash
src/uart/uart_controller.v             ← UART
src/video/video_timing_gen.v           ← 视频时序
src/video/adv7125_driver.v             ← ADV7125 DAC
src/test/adv7393_driver.v              ← ADV7393 编码器
src/test/system_testbench.v            ← 仿真测试
```

### 约束文件 (1 个)
```
constraints/video_converter.ucf        ← 引脚约束
```

### 工程文件 (3 个)
```
video_converter.xise                   ← ISE 工程
video_converter.prj                    ← 源文件列表
video_converter.scr                    ← 综合脚本
```

---

## 🚀 ISE 导入步骤

### 方法 1：直接打开工程（推荐）

```
1. 打开 Xilinx ISE 14.7
2. File → Open Project
3. 浏览到：F:\Video_Covertor\Firmware\FPGA_Verification\
4. 选择：video_converter.xise
5. 点击 Open
6. 完成！
```

### 方法 2：手动创建工程

如果方法 1 有问题，手动创建：

```
1. File → New Project
   - Name: video_converter
   - Location: F:\Video_Covertor\Firmware\FPGA_Verification

2. Project Type: HDL, XST, ISim

3. Add Source (添加所有 12 个 .v 文件)

4. Add Constraints: video_converter.ucf

5. Device: XC6SLX45, FGG484, -3
```

---

## ⚙️ 综合与实现

### 在 Processes 窗口中运行：

```
1. Synthesize - XST
   └─ 右键 → Run

2. Implement Design
   ├─ Translate
   ├─ Map
   └─ Place & Route
   └─ 右键 → Run

3. Generate Programming File
   └─ 右键 → Run
```

生成 `video_converter.bit` 后即可下载。

---

## 📊 预期综合结果

### 资源使用预估

| 资源 | 预估用量 | 总资源 | 使用率 |
|------|----------|--------|--------|
| Slice LUTs | ~1500 | 27,288 | ~5% |
| Slice Registers | ~1000 | 27,288 | ~4% |
| IOBs | ~180 | ~400 | ~45% |
| PLL | 1 | 4 | 25% |

### 综合输出示例

```
INFO:Synthesis - Unit <video_converter_top> synthesized.
INFO:Synthesis - Unit <clk_wiz_50to100> synthesized.
INFO:Synthesis - Unit <rst_controller_simple> synthesized.
INFO:Synthesis - Unit <sys_status_monitor_simple> synthesized.
INFO:Synthesis - Unit <video_input_tf401a> synthesized.
INFO:Synthesis - Unit <video_output_tfp410> synthesized.
INFO:Synthesis - Unit <spi_flash_controller> synthesized.
INFO:Synthesis - Unit <uart_controller> synthesized.
INFO:Synthesis - Unit <adv7125_driver> synthesized.
INFO:Synthesis - Unit <adv7393_driver> synthesized.
```

---

## ⚠️ 注意事项

### 1. PLL 时钟模块

`clk_wiz_50to100.v` 是**行为级模型**，用于：
- ✅ 仿真验证
- ✅ 初步综合测试

**如需下载到硬件**，建议用 Xilinx Clocking Wizard 生成真实 PLL：

```
1. ISE → IP Catalog → Clocking Wizard
2. 配置：
   - Input: 50MHz
   - Output 1: 100MHz
   - Output 2: 74.25MHz
3. 生成后替换 clk_wiz_50to100.v
```

### 2. 未使用的模块

以下模块已创建但当前未使用：
- `video_frame_buffer.v` - DDR3 帧缓冲（保留）
- `ddr3_mig_wrapper.v` - DDR3 控制器（保留）

综合时会自动优化掉。

### 3. DDR3 引脚

DDR3 所有引脚已固定为空闲电平，不会影响硬件。

---

## 🔧 常见问题

### Q1: 综合时报错 "module not defined"

**解决**：确认所有 11 个源文件都已添加到工程。

### Q2: 找不到器件 XC6SLX45

**解决**：安装 Spartan-6 支持包。

### Q3: 约束冲突

**解决**：检查 UCF 文件，确认引脚分配正确。

### Q4: PLL 无法锁定

**解决**：使用真实的 Clocking Wizard IP 替换行为级模型。

---

## 📖 相关文档

| 文档 | 说明 |
|------|------|
| `README.md` | 项目总览 |
| `QUICK_START.md` | 快速参考 |
| `docs/ise_import_guide.md` | 详细导入指南 |
| `docs/module_checklist.md` | 模块检查清单 |
| `docs/architecture.md` | 系统架构 |

---

## ✅ 完整性检查命令

在工程目录执行：

```bash
# 检查所有源文件
dir src\*.v /s /b

# 应返回 13 个文件（12 个源文件 + 1 个旧文件）
```

---

## 版本信息

| 项目 | 值 |
|------|-----|
| 工程版本 | 1.1 (No-DDR3) |
| 创建日期 | 2026-03-16 |
| 目标器件 | XC6SLX45-FGG484-3 |
| 模块数量 | 11 个核心模块 |
| 状态 | ✅ 完整可用 |
