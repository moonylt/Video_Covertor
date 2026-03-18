#============================================================================
# ModelSim/ISim 仿真脚本
# 用于 VIDEO_CONVERTER FPGA 验证工程
#============================================================================

# 清理之前的仿真结果
if {[file exists "work"]} {
    vdel -lib work -all
}

# 创建库
vlib work
vmap work work

#============================================================================
# 编译源文件 (按依赖顺序)
#============================================================================

# 顶层模块依赖
vlog -sv ../src/top/rst_controller.v
vlog -sv ../src/top/sys_status_monitor.v

# DDR3 模块
vlog -sv ../src/ddr3/ddr3_mig_wrapper.v

# HDMI 模块
vlog -sv ../src/hdmi/tfp401a_rx.v
vlog -sv ../src/hdmi/tfp410_tx.v

# 视频模块
vlog -sv ../src/video/video_timing_gen.v
vlog -sv ../src/video/video_frame_buffer.v
vlog -sv ../src/video/adv7125_driver.v

# Flash 模块
vlog -sv ../src/flash/spi_flash_ctrl.v

# UART 模块
vlog -sv ../src/uart/uart_controller.v

# 顶层模块
vlog -sv ../src/top/video_converter_top.v

# Testbench
vlog -sv ../src/test/system_testbench.v

#============================================================================
# 仿真配置
#============================================================================

# 优化选项
vsim -voptargs="+acc" work.system_testbench

# 添加波形
do waves.do

# 运行仿真
run 1ms

# 查看结果
wave zoom full
