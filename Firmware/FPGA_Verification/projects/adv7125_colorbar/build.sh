#!/bin/bash
# ADV7125 Color Bar Test - Build Script
# For Xilinx ISE 14.7

echo "========================================"
echo "ADV7125 VGA Color Bar Test - Build"
echo "========================================"

# 设置项目路径
PROJECT_DIR="$(dirname "$0")"
PROJECT_NAME="adv7125_colorbar"

# 进入项目目录
cd "$PROJECT_DIR"

# 检查 ISE 环境
if [ -z "$XILINX_ISE" ]; then
    echo "ERROR: Xilinx ISE environment not found!"
    echo "Please source ISE settings first:"
    echo "  source /opt/Xilinx/14.7/ISE_DS/settings64.sh"
    exit 1
fi

echo "Project: $PROJECT_NAME"
echo "Directory: $PROJECT_DIR"
echo ""

# 如果工程文件不存在，创建工程
if [ ! -f "${PROJECT_NAME}.xise" ]; then
    echo "Creating ISE project..."
    
    # 使用 project navigator 创建工程
    xflow -p xc6slx45-3-fgg484 \
          -t adv7125_colorbar_top \
          -o adv7125_colorbar.bit \
          src/adv7125_colorbar_top.v \
          src/vga_colorbar_800x600.v \
          src/clk_wiz_50to40.v \
          ../../src/video/adv7125_driver.v \
          constraints/adv7125_colorbar.ucf
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Project creation failed!"
        exit 1
    fi
fi

# 运行综合和实现
echo "Running synthesis and implementation..."
xtclsh adv7125_colorbar.tcl run

if [ $? -eq 0 ]; then
    echo ""
    echo "========================================"
    echo "Build SUCCESSFUL!"
    echo "Bitstream: ${PROJECT_NAME}/implementation/${PROJECT_NAME}.bit"
    echo "========================================"
else
    echo ""
    echo "========================================"
    echo "Build FAILED!"
    echo "Check log files for details:"
    echo "  - ${PROJECT_NAME}/implementation/${PROJECT_NAME}.ngdbuild"
    echo "  - ${PROJECT_NAME}/implementation/${PROJECT_NAME}.map"
    echo "  - ${PROJECT_NAME}/implementation/${PROJECT_NAME}.par"
    echo "========================================"
    exit 1
fi
