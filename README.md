# Video_Covertor - FPGA 视频转换器

基于 FPGA 的视频信号转换项目，支持 HDMI 输入/输出转换。

## 📁 项目结构

```
Video_Covertor/
├── Firmware/              # 固件代码
│   └── FPGA_Verification/
│       ├── src/          # Verilog 源代码
│       ├── sim/          # 仿真文件
│       ├── constraints/  # 引脚约束文件
│       ├── projects/     # 子项目
│       └── docs/         # 技术文档
├── Sch/                  # Altium 原理图和 PCB 设计
│   ├── Altium_VIDEO_CONVERTER_2026-03-16/
│   ├── BOM_*.xlsx        # 物料清单
│   └── Netlist_*.tel     # 网表文件
└── README.md             # 项目说明
```

## 🔧 硬件要求

- FPGA: Xilinx Spartan-6
- HDMI 输入接口
- HDMI/AV 输出接口
- DDR3 内存模块

## 📋 主要功能

- HDMI 视频信号采集
- 帧缓存处理（DDR3）
- 视频格式转换
- 多路输出支持

## 🚀 快速开始

### 1. 打开 ISE 项目

```bash
cd Firmware/FPGA_Verification
# 使用 Xilinx ISE 打开 video_converter.xise
```

### 2. 导入约束

```bash
# 使用 constraints/video_converter.ucf
```

### 3. 生成比特流

在 ISE 中执行：
- Synthesize
- Implement
- Generate Programming File

### 4. 烧录到 FPGA

使用 iMPACT 或 Adept 工具烧录 `.bit` 文件

## 📄 文档

| 文档 | 说明 |
|------|------|
| [QUICK_START.md](Firmware/FPGA_Verification/QUICK_START.md) | 快速入门指南 |
| [PROJECT_COMPLETE.md](Firmware/FPGA_Verification/PROJECT_COMPLETE.md) | 项目完成报告 |
| [docs/](Firmware/FPGA_Verification/docs/) | 详细技术文档 |

## 🛠️ 工具版本

- Xilinx ISE 14.7
- Altium Designer
- ModelSim（仿真）

## 📝 注意事项

⚠️ **许可证文件**：`xilinx_ise.lic` 为授权文件，请勿上传到公共仓库。

## 📅 项目日期

2026 年 3 月

## 📧 联系方式

如有问题，请提交 Issue 或联系项目维护者。
