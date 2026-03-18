# ISE 工程导入指南

## 方法一：使用已创建的工程文件（推荐）

### 步骤 1：打开 Xilinx ISE

1. 启动 **Xilinx ISE Design Suite 14.7**
2. 点击 `File` → `Open Project`

### 步骤 2：选择工程文件

1. 浏览到工程目录：
   ```
   F:\Video_Covertor\Firmware\FPGA_Verification\
   ```
2. 选择 `video_converter.xise` 文件
3. 点击 `打开`

### 步骤 3：验证工程配置

在 **Sources** 窗口中，您应该看到以下文件结构：

```
video_converter
├── Design Files
│   ├── video_converter_top.v
│   ├── rst_controller_simple.v
│   ├── sys_status_monitor_simple.v
│   ├── tfp401a_rx.v
│   ├── tfp410_tx.v
│   ├── spi_flash_ctrl.v
│   ├── uart_controller.v
│   ├── video_timing_gen.v
│   ├── video_frame_buffer.v
│   ├── adv7125_driver.v
│   └── adv7393_driver.v
├── Constraints
│   └── video_converter.ucf
└── Libraries
    └── work
```

### 步骤 4：检查器件配置

1. 在 **Processes** 窗口，展开 `Synthesize - XST`
2. 右键点击 `Synthesize - XST` → `Properties`
3. 确认以下设置：
   - **Family**: Spartan6
   - **Device**: xc6slx45
   - **Package**: fgg484
   - **Speed**: -3

### 步骤 5：运行综合

1. 在 **Processes** 窗口，点击 `Synthesize - XST`
2. 等待综合完成（查看底部 **Console** 窗口）
3. 检查是否有错误

### 步骤 6：实现工程

综合成功后，依次运行：

1. **Implement Design**
   - Translate
   - Map
   - Place & Route

2. 生成比特流
   - Generate Programming File

---

## 方法二：手动创建工程

如果方法一有问题，可以手动创建：

### 步骤 1：新建工程

1. `File` → `New Project`
2. 设置工程名称和位置：
   - **Name**: video_converter
   - **Location**: `F:\Video_Covertor\Firmware\FPGA_Verification\`
3. 选择工程类型：
   - **Project Type**: HDL
   - **Synthesis Tool**: XST (VHDL/Verilog)
   - **Simulator**: ISim (VHDL/Verilog)
4. 点击 `Next`

### 步骤 2：添加源文件

1. 点击 `Add Source`
2. 浏览并选择所有 `.v` 文件：
   ```
   src/top/video_converter_top.v
   src/top/rst_controller_simple.v
   src/top/sys_status_monitor_simple.v
   src/hdmi/tfp401a_rx.v
   src/hdmi/tfp410_tx.v
   src/flash/spi_flash_ctrl.v
   src/uart/uart_controller.v
   src/video/video_timing_gen.v
   src/video/video_frame_buffer.v
   src/video/adv7125_driver.v
   src/test/adv7393_driver.v
   ```
3. 点击 `OK` → `Next`

### 步骤 3：添加约束文件

1. 点击 `Add Source`
2. 选择文件类型：`Implementation Constraints File`
3. 选择 `constraints/video_converter.ucf`
4. 点击 `OK` → `Next`

### 步骤 4：配置器件

1. 选择器件：
   - **Family**: Spartan6
   - **Series**: Any
   - **Device**: xc6slx45
   - **Package**: fgg484
   - **Speed**: -3
2. 点击 `Next`

### 步骤 5：完成工程创建

1. 查看工程摘要
2. 点击 `Finish`

---

## 常见问题解决

### 问题 1：找不到器件

**错误**: `Device xc6slx45 not found`

**解决**:
1. 确认已安装 Spartan-6 支持包
2. `Help` → `Check for Updates`
3. 安装缺失的器件支持

### 问题 2：综合错误

**错误**: `Syntax error near ...`

**解决**:
1. 检查 Verilog 语法
2. 确认所有模块都已添加
3. 查看 **Console** 窗口详细错误信息

### 问题 3：约束冲突

**错误**: `Constraint override ...`

**解决**:
1. 检查 UCF 文件
2. 确认引脚分配没有冲突
3. 查看 `Map Report`

### 问题 4：时钟约束问题

**错误**: `Period constraint not met`

**解决**:
1. 检查时钟频率设置
2. 调整时序约束
3. 查看 `Timing Report`

---

## 综合选项配置

### 推荐设置

在 `Synthesize - XST` → `Properties` 中配置：

```
HDL Options:
  - Top Module Name: video_converter_top
  - Compiler Effort Level: High
  - FSM Encoding Algorithm: Auto
  - Safe Implementation: No
  - FSM Style: LUT

Synthesis Options:
  - Optimization Goal: Area
  - Optimization Effort: High
  - Use Clock Enable: Auto
  - Use Sync Set: Auto
  - Use Sync Reset: Auto
  - Max Fanout: 500
  - Register Balancing: Yes
  - Register Duplication: Yes

Xilinx Specific Options:
  - Equivalent Register Removal: Yes
  - Resource Sharing: Auto
  - Shift Extraction: Yes
```

---

## 实现流程

### 完整流程

```
1. Synthesize - XST
   └─> 生成 .ngc 文件

2. Implement Design
   ├─> Translate (.ngd)
   ├─> Map (.ncd)
   ├─> Place & Route (.ncd)
   └─> Generate Programming File (.bit)
```

### 查看报告

每个步骤完成后，查看相应报告：

- **Synthesis Report**: 综合结果
- **Map Report**: 映射结果
- **Place & Route Report**: 布局布线结果
- **Timing Report**: 时序分析

---

## 比特流生成

### 配置选项

在 `Generate Programming File` → `Properties` 中：

```
Configuration Options:
  - Startup Clock: CCLK
  - Persist: 3-State
  - Done Pipe: No
  - Drive Done Pin High: No

Bitstream Options:
  - Enable Bitstream Compression: No
  - Enable Internal Done Pipe: No
  - Mask Pin: No
  - Readback: No
  - Security: No
```

### 生成比特流

1. 右键点击 `Generate Programming File`
2. 点击 `Run`
3. 生成的比特流文件：`video_converter.bit`

---

## 下载配置

### 使用 iMPACT

1. `Tools` → `iMPACT - Configure FPGAs and PROMs`
2. 选择 `Configure Devices using Boundary-Scan (JTAG)`
3. 选择 `Auto Connect`
4. 右键点击 FPGA → `Program`
5. 选择 `video_converter.bit` 文件
6. 点击 `OK` 开始下载

### 使用 Adept/Digilent

如果使用 Digilent 下载器：

1. 打开 Adept 软件
2. 选择设备
3. 加载 `video_converter.bit`
4. 点击 `Program`

---

## 调试方法

### ChipScope 集成

1. 在顶层模块中添加 ChipScope 核
2. 重新综合
3. 使用 ChipScope Pro 抓取信号

### LED 调试

利用板载 LED：
- LED[0]: 电源/运行指示
- LED[1]: 视频输入状态
- LED[6:2]: 保留
- LED[7]: 视频输出状态

### UART 调试

通过 CP2102N 输出调试信息：
- 波特率：115200
- 数据位：8
- 停止位：1
- 校验：无

---

## 版本信息

| 项目 | 值 |
|------|-----|
| ISE 版本 | 14.7 |
| 器件 | XC6SLX45-FGG484 |
| 速度等级 | -3 |
| 工程版本 | 1.1 (No-DDR3) |

---

## 相关文档

- `README.md` - 项目说明
- `docs/architecture.md` - 系统架构
- `docs/interface_spec.md` - 接口规范
- `docs/test_plan.md` - 测试计划
