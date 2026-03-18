# VIDEO_CONVERTER 模块完整性检查

## 顶层模块实例化清单

`video_converter_top.v` 中实例化的所有模块：

| 实例名 | 模块名 | 文件位置 | 状态 |
|--------|--------|----------|------|
| u_clk_wiz_sys | clk_wiz_50to100 | src/top/clk_wiz_50to100.v | ✅ 已创建 |
| u_rst_ctrl | rst_controller_simple | src/top/rst_controller_simple.v | ✅ 已创建 |
| u_vid_in | video_input_tf401a | src/hdmi/tfp401a_rx.v | ✅ 已创建 |
| u_vid_out | video_output_tfp410 | src/hdmi/tfp410_tx.v | ✅ 已创建 |
| u_flash_ctrl | spi_flash_controller | src/flash/spi_flash_ctrl.v | ✅ 已创建 |
| u_uart_ctrl | uart_controller | src/uart/uart_controller.v | ✅ 已创建 |
| u_adv7125_drv | adv7125_driver | src/video/adv7125_driver.v | ✅ 已创建 |
| u_adv7393_drv | adv7393_driver | src/test/adv7393_driver.v | ✅ 已创建 |
| u_status | sys_status_monitor_simple | src/top/sys_status_monitor_simple.v | ✅ 已创建 |

## 完整文件列表

### 顶层模块 (src/top/)
- [x] video_converter_top.v
- [x] clk_wiz_50to100.v (PLL 行为级模型)
- [x] rst_controller_simple.v
- [x] sys_status_monitor_simple.v

### HDMI 模块 (src/hdmi/)
- [x] tfp401a_rx.v (video_input_tf401a)
- [x] tfp410_tx.v (video_output_tfp410)

### Flash 模块 (src/flash/)
- [x] spi_flash_ctrl.v

### UART 模块 (src/uart/)
- [x] uart_controller.v

### 视频模块 (src/video/)
- [x] video_timing_gen.v
- [x] video_frame_buffer.v (未使用，但保留)
- [x] adv7125_driver.v

### 测试模块 (src/test/)
- [x] adv7393_driver.v
- [x] system_testbench.v (仿真用)

### 约束文件 (constraints/)
- [x] video_converter.ucf

### 工程文件
- [x] video_converter.xise
- [x] video_converter.prj
- [x] video_converter.scr

## 工程导入检查清单

导入 ISE 前请确认：

- [ ] 所有 12 个 Verilog 源文件已创建
- [ ] 约束文件 video_converter.ucf 存在
- [ ] 工程文件 video_converter.xise 存在
- [ ] 器件配置正确：XC6SLX45-FGG484-3

## 综合前检查

运行以下命令验证文件完整性：

```bash
# 在工程目录执行
dir src\*.v /s /b
```

应返回 15 个文件（12 个源文件 + 1 个 testbench + 2 个旧文件）

## 预期综合结果

```
Synthesizing unit <video_converter_top>...
Synthesizing unit <clk_wiz_50to100>...
Synthesizing unit <rst_controller_simple>...
Synthesizing unit <sys_status_monitor_simple>...
Synthesizing unit <video_input_tf401a>...
Synthesizing unit <video_output_tfp410>...
Synthesizing unit <spi_flash_controller>...
Synthesizing unit <uart_controller>...
Synthesizing unit <adv7125_driver>...
Synthesizing unit <adv7393_driver>...
```

## 注意事项

1. **clk_wiz_50to100.v** 是行为级模型
   - 用于仿真和初步验证
   - 实际硬件需要使用 Xilinx Clocking Wizard 生成真实 PLL IP

2. **video_frame_buffer.v** 当前未使用
   - 保留用于将来恢复 DDR3 功能
   - 综合时会自动优化掉

3. **DDR3 引脚** 已固定为空闲电平
   - 不会影响硬件
   - 可以安全留空

## 生成真实 PLL IP（可选）

如需生成真实的 PLL IP 核：

1. 打开 Xilinx ISE
2. IP Catalog → Clocking Wizard
3. 配置参数：
   - Input Clock: 50MHz
   - Output Clock 1: 100MHz
   - Output Clock 2: 74.25MHz
4. 生成 IP 并替换 clk_wiz_50to100.v

## 版本信息

- 工程版本：1.1 (No-DDR3)
- 最后更新：2026-03-16
- 模块总数：9 个（不含 testbench）
