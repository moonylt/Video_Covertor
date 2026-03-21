# Video_Covertor - FPGA 视频转换器

基于 FPGA 的视频信号转换项目，支持 HDMI 输入/输出转换。

Based on Spartan-6 with HDMI in/out, VGA output, S-Video output etc. Supports scaler, frame buffer, PIP in the future.

## 📁 项目结构 / Project Structure

```
Video_Covertor/
├── Firmware/                      # 固件代码 / Firmware
│   ├── hdmi_vga_combined/         # ✅ HDMI + VGA 双输出工程 (推荐)
│   │   ├── src/                   # Verilog 源代码
│   │   ├── constraints/           # 引脚约束文件
│   │   └── README.md              # 使用说明
│   ├── FPGA_Verification/         # 主项目 (开发中)
│   │   ├── src/                   # Verilog 源代码
│   │   ├── sim/                   # 仿真文件
│   │   ├── constraints/           # 引脚约束文件
│   │   └── docs/                  # 技术文档
│   └── vga_projects/              # VGA 独立测试工程
│       └── adv7125_colorbar/      # ADV7125 彩条测试
├── Sch/                           # Altium 原理图和 PCB 设计
│   ├── Altium_VIDEO_CONVERTER_2026-03-16/
│   ├── BOM_*.xlsx                 # 物料清单
│   └── Netlist_*.tel              # 网表
└── README.md
```

## 🔧 硬件要求 / Hardware Requirements

| 组件 | 型号 |
|------|------|
| FPGA | Xilinx Spartan-6 XC6SLX45-3FGG484I |
| HDMI 接收器 | TFP401A |
| HDMI 发送器 | TFP410 |
| VGA DAC | ADV7125 (8-bit RGB) |
| 视频编码器 | ADV7393 (CVBS/S-Video) |
| DDR3L | 256MB |
| 系统时钟 | 50MHz |

## 📋 主要功能 / Features

- HDMI 视频信号采集 / HDMI Video Capture
- HDMI 视频信号输出 / HDMI Video Output
- VGA 模拟视频输出 / VGA Analog Output
- CVBS/S-Video 输出 / Composite Video Output
- 帧缓存处理 (DDR3) / Frame Buffer (DDR3)
- 视频格式转换 / Video Format Conversion
- 缩放功能 / Scaler
- 画中画（未来支持）/ PIP (Future)

## 🚀 快速开始 / Quick Start

### 推荐：HDMI + VGA 双输出测试

```bash
cd Firmware/hdmi_vga_combined
```

**功能：**
| 输出接口 | 分辨率 | 刷新率 | 芯片 |
|----------|--------|--------|------|
| HDMI | 1280x720 | 60Hz | TFP410 |
| VGA | 800x600 | 60Hz | ADV7125 |

**测试模式：** 按 BTN0 切换测试图案（白/红/绿/蓝/彩条/网格）

**使用步骤：**
1. 用 Xilinx ISE Clocking Wizard 生成 PLL (74.25MHz + 40MHz)
2. 替换 `src/clk_wiz_dual.v`
3. 编译下载到 FPGA
4. 连接 HDMI 和 VGA 显示器测试

详见：[hdmi_vga_combined/README.md](Firmware/hdmi_vga_combined/README.md)

### 其他工程

| 工程 | 路径 | 说明 | 状态 |
|------|------|------|------|
| HDMI + VGA 双输出 | `Firmware/hdmi_vga_combined/` | 同时输出测试图案 | ✅ 可用 |
| VGA 彩条测试 | `Firmware/vga_projects/adv7125_colorbar/` | ADV7125 独立测试 | ✅ 可用 |
| 主项目 | `Firmware/FPGA_Verification/` | 完整视频转换功能 | 🚧 开发中 |

## 📄 文档 / Documentation

| 文档 | 说明 |
|------|------|
| [HDMI+VGA 工程](Firmware/hdmi_vga_combined/README.md) | 双输出测试工程说明 |
| [VGA 工程](Firmware/vga_projects/adv7125_colorbar/) | VGA 彩条测试 |
| [技术文档](Firmware/FPGA_Verification/docs/) | 详细技术文档 |

## 🛠️ 工具版本 / Tool Versions

- Xilinx ISE 14.7
- Altium Designer
- ModelSim（仿真 / Simulation）

## 📝 注意事项 / Notes

⚠️ **许可证文件**：`xilinx_ise.lic` 为授权文件，请勿上传到公共仓库。
⚠️ **License File**: `xilinx_ise.lic` is a license file, do not upload to public repository.

## 📅 项目日期 / Date

2026 年 3 月 / March 2026

## 📧 联系方式 / Contact

如有问题，请提交 Issue 或联系项目维护者。
For issues, please submit an Issue or contact the project maintainer.