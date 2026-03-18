# Video_Covertor - FPGA 视频转换器

基于 FPGA 的视频信号转换项目，支持 HDMI 输入/输出转换。

Based on Spartan-6 with HDMI in/out, VGA output, S-Video output etc. Supports scaler, frame buffer, PIP in the future.

## 📁 项目结构 / Project Structure

```
Video_Covertor/
├── Firmware/              # 固件代码 / Firmware
│   └── FPGA_Verification/
│       ├── src/          # Verilog 源代码 / Source
│       ├── sim/          # 仿真文件 / Simulation
│       ├── constraints/  # 引脚约束文件 / Constraints
│       ├── projects/     # 子项目 / Sub-projects
│       └── docs/         # 技术文档 / Documentation
├── Sch/                  # Altium 原理图和 PCB 设计 / Schematics & PCB
│   ├── Altium_VIDEO_CONVERTER_2026-03-16/
│   ├── BOM_*.xlsx        # 物料清单 / Bill of Materials
│   └── Netlist_*.tel     # 网表 / Netlist
└── README.md             # 项目说明 / Project Description
```

## 🔧 硬件要求 / Hardware Requirements

- FPGA: Xilinx Spartan-6
- HDMI 输入接口 / HDMI Input
- HDMI/AV 输出接口 / HDMI/AV Output
- DDR3 内存模块 / DDR3 Memory Module

## 📋 主要功能 / Features

- HDMI 视频信号采集 / HDMI Video Capture
- 帧缓存处理（DDR3）/ Frame Buffer (DDR3)
- 视频格式转换 / Video Format Conversion
- 多路输出支持 / Multi-output Support
- 缩放功能 / Scaler
- 画中画（未来支持）/ PIP (Future)

## 🚀 快速开始 / Quick Start

### 1. 打开 ISE 项目 / Open ISE Project

```bash
cd Firmware/FPGA_Verification
# 使用 Xilinx ISE 打开 video_converter.xise / Open with Xilinx ISE
```

### 2. 导入约束 / Import Constraints

```bash
# 使用 constraints/video_converter.ucf
```

### 3. 生成比特流 / Generate Bitstream

在 ISE 中执行 / In ISE:
- Synthesize
- Implement
- Generate Programming File

### 4. 烧录到 FPGA / Program FPGA

使用 iMPACT 或 Adept 工具烧录 `.bit` 文件 / Use iMPACT or Adept to program `.bit` file

## 📄 文档 / Documentation

| 文档 / Document | 说明 / Description |
|------|------|
| [QUICK_START.md](Firmware/FPGA_Verification/QUICK_START.md) | 快速入门指南 / Quick Start Guide |
| [PROJECT_COMPLETE.md](Firmware/FPGA_Verification/PROJECT_COMPLETE.md) | 项目完成报告 / Project Report |
| [docs/](Firmware/FPGA_Verification/docs/) | 详细技术文档 / Technical Docs |

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
