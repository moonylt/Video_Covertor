# ADV7125 VGA 彩条测试 - 快速开始

## 1. 生成 PLL 核 (必须!)

⚠️ **重要**: 使用前必须生成真正的 PLL 核!

```bash
# 方法 1: GUI 生成
Tools → Clocking Wizard
- Input: 50MHz
- Output: 40MHz
- 保存为：src/clk_wiz_50to40.v

# 方法 2: 使用 XCO (如果支持)
ipcoregen pll_config.xco
```

详细步骤参考 `PLL_GENERATION_GUIDE.md`

---

## 2. 创建 ISE 项目

1. **打开 Xilinx ISE 14.7**

2. **创建新项目**
   ```
   File → New Project
   Name: adv7125_colorbar
   Location: F:\Video_Covertor\Firmware\FPGA_Verification\projects\adv7125_colorbar
   Top-level source type: HDL
   ```

3. **设置器件**
   ```
   Family: Spartan6
   Device: xc6slx45
   Package: fg484
   Speed Grade: -3
   ```

4. **添加源文件**
   - `src/adv7125_colorbar_top.v`
   - `src/vga_colorbar_800x600.v`
   - `src/adv7125_driver_8bit.v`
   - `src/clk_wiz_50to40.v` (生成的 PLL 核)

5. **添加约束文件**
   - `constraints/adv7125_colorbar.ucf`

---

## 3. 综合和实现

### 方法 A: GUI 操作
1. 在 Sources 窗口选择 `adv7125_colorbar_top`
2. 在 Processes 窗口双击:
   - **Synthesize - XST** (等待完成)
   - **Implement** (等待完成)
   - **Generate Programming File** (等待完成)

### 方法 B: 批处理
```bash
# 在 ISE 命令行环境
xtclsh adv7125_colorbar.tcl run
```

---

## 4. 下载比特流

1. **连接 JTAG 下载器** 到 FPGA
2. **打开 FPGA 电源**
3. **连接 VGA 显示器** 到 VGA 输出接口
4. **打开显示器电源**,选择 VGA 输入

5. **在 ISE 中下载**:
   ```
   Tools → iMPACT → Configure Boundary Scan
   → 右键 → Initialize Chain
   → 选择 .bit 文件 → OK
   → 右键 → Program
   ```

---

## 5. 验证输出

### 预期显示器画面
```
┌────────────────────────────────────────────┐
│ 白 │ 黄 │ 青 │ 绿 │ 紫 │ 红 │ 蓝 │ 黑 │
│███ │███ │███ │███ │███ │███ │███ │   │
│███ │███ │███ │███ │███ │███ │███ │   │
│███ │███ │███ │███ │███ │███ │███ │   │
└────────────────────────────────────────────┘
```

### 示波器测量 (可选)

| 测试点 | 频率 | 幅度 | 说明 |
|--------|------|------|------|
| ADV7125_CLK | 40MHz | 3.3V | DAC 时钟 |
| VGA_HS | 37.88kHz | 3.3V | 行同步 |
| VGA_VS | 60.32Hz | 3.3V | 场同步 |
| ADV7125_RED[7] | ~20MHz | 3.3V | 数据活动 |

---

## 6. 故障排查

### 显示器显示"无信号"
1. ✅ 检查 FPGA 是否已下载 (DONE LED 应亮起)
2. ✅ 检查 VGA 线是否插好
3. ✅ 检查显示器输入源是否选择 VGA
4. ✅ 用示波器测量 ADV7125_CLK 是否有 40MHz
5. ✅ **检查 PLL 是否已正确生成和替换**

### 有信号但黑屏
1. ✅ 测量 ADV7125 电源引脚 (3.3V)
2. ✅ 检查 ADV7125_RESET 是否为高电平
3. ✅ 测量 RGB 数据线是否有活动
4. ✅ 检查 VGA_HS/VGA_VS 是否有脉冲

### 颜色不正确
1. ✅ 检查 RGB 数据线序 (8 位)
2. ✅ 确认 PCB 焊接无短路
3. ✅ 尝试其他显示器

---

## 7. 修改测试图案

编辑 `src/vga_colorbar_800x600.v`:

### 改为全白屏幕
```verilog
assign bar_color = 24'hFFFFFF;  // 固定白色
```

### 改为网格图案
```verilog
assign bar_color = ((h_count[5:0] == 6'd0) || (v_count[5:0] == 6'd0)) 
                   ? 24'hFFFFFF : 24'h000000;
```

---

## 8. 技术参考

### 关键文件
- `adv7125_colorbar_top.v` - 顶层模块
- `vga_colorbar_800x600.v` - 彩条发生器 (800x600@60Hz)
- `adv7125_driver_8bit.v` - DAC 驱动 (8 位 RGB)
- `clk_wiz_50to40.v` - PLL 时钟 (**需要生成!**)
- `adv7125_colorbar.ucf` - 引脚约束

### 外部参考
- ADV7125 Datasheet (Analog Devices)
- VESA VGA 时序标准
- Xilinx Spartan-6 Datasheet
- `PLL_GENERATION_GUIDE.md` - PLL 生成指南

---

## 9. 下一步

✅ **VGA 测试通过后**:
1. 测试 HDMI 输出 (TFP410)
2. 实现 HDMI 输入到 VGA 输出
3. 添加视频帧缓冲 (使用 DDR3)
4. 调试 ADV7393 复合视频

---

**技术支持**: 参考 `../../docs/HDMI_DEBUG_GUIDE.md` 中的诊断流程
