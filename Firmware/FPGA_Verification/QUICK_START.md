# ISE 工程导入 - 快速参考卡

## 一键导入（方法一）

```
1. 打开 Xilinx ISE 14.7
2. File → Open Project
3. 选择：video_converter.xise
4. 点击 Open
```

## 手动创建（方法二）

```
1. File → New Project
   - Name: video_converter
   - Location: F:\Video_Covertor\Firmware\FPGA_Verification

2. Project Type:
   - HDL
   - XST (VHDL/Verilog)
   - ISim

3. Add Source (所有 .v 文件):
   ✓ src/top/video_converter_top.v
   ✓ src/top/rst_controller_simple.v
   ✓ src/top/sys_status_monitor_simple.v
   ✓ src/hdmi/tfp401a_rx.v
   ✓ src/hdmi/tfp410_tx.v
   ✓ src/flash/spi_flash_ctrl.v
   ✓ src/uart/uart_controller.v
   ✓ src/video/video_timing_gen.v
   ✓ src/video/video_frame_buffer.v
   ✓ src/video/adv7125_driver.v
   ✓ src/test/adv7393_driver.v

4. Add Constraints:
   ✓ constraints/video_converter.ucf

5. Device Configuration:
   - Family: Spartan6
   - Device: xc6slx45
   - Package: fgg484
   - Speed: -3
```

## 综合与实现流程

```
Processes 窗口操作顺序:

1. Synthesize - XST          [右键 → Run]
   ↓
2. Implement Design          [右键 → Run]
   ├─ Translate
   ├─ Map
   └─ Place & Route
   ↓
3. Generate Programming File [右键 → Run]
   ↓
生成：video_converter.bit
```

## 下载比特流

```
1. Tools → iMPACT
2. Configure Devices using Boundary-Scan (JTAG)
3. Auto Connect
4. 右键 FPGA → Program
5. 选择：video_converter.bit
6. OK
```

## 关键设置检查

### 综合设置
```
Synthesize - XST → Properties:
- Top Module: video_converter_top
- Effort Level: High
- Max Fanout: 500
```

### 器件设置
```
Device: XC6SLX45-FGG484-3
```

### 约束文件
```
video_converter.ucf (已包含所有引脚约束)
```

## 预期结果

### 综合报告
```
- Total LUTs: ~2000-3000
- Total Registers: ~1500-2000
- IOs: ~200
```

### 实现报告
```
- Slice LUTs: < 15%
- Slice Registers: < 10%
- Timing: 所有约束满足
```

## 故障排除

| 问题 | 解决 |
|------|------|
| 找不到器件 | 安装 Spartan-6 支持包 |
| 语法错误 | 检查 Verilog 版本兼容性 |
| 约束冲突 | 查看 Map Report |
| 时序违例 | 调整约束或优化代码 |

## 联系支持

详细文档：`docs/ise_import_guide.md`
