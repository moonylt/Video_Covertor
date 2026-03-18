#============================================================================
# ModelSim 波形配置文件
# VIDEO_CONVERTER FPGA 验证工程
#============================================================================

# 添加顶层信号
add wave -noupdate -divider "=== System Signals ==="
add wave -noupdate /system_testbench/clk_50mhz
add wave -noupdate /system_testbench/clk_27mhz
add wave -noupdate /system_testbench/rst_n
add wave -noupdate /system_testbench/led

# DUT 内部信号
add wave -noupdate -divider "=== DUT Top Level ==="
add wave -noupdate /system_testbench/u_dut/sys_clk
add wave -noupdate /system_testbench/u_dut/sys_rst_n
add wave -noupdate /system_testbench/u_dut/test_point

# DDR3 接口
add wave -noupdate -divider "=== DDR3 Interface ==="
add wave -noupdate /system_testbench/u_dut/ddr3_dq
add wave -noupdate /system_testbench/u_dut/ddr3_addr
add wave -noupdate /system_testbench/u_dut/ddr3_ba
add wave -noupdate /system_testbench/u_dut/ddr3_ras_n
add wave -noupdate /system_testbench/u_dut/ddr3_cas_n
add wave -noupdate /system_testbench/u_dut/ddr3_we_n
add wave -noupdate /system_testbench/u_dut/ddr3_init_calib_complete

# HDMI 输入
add wave -noupdate -divider "=== HDMI Input (TFP401A) ==="
add wave -noupdate /system_testbench/tfp401_dvi_d
add wave -noupdate /system_testbench/tfp401_de
add wave -noupdate /system_testbench/tfp401_hs
add wave -noupdate /system_testbench/tfp401_vs
add wave -noupdate /system_testbench/tfp401_pclk

# HDMI 输出
add wave -noupdate -divider "=== HDMI Output (TFP410) ==="
add wave -noupdate /system_testbench/tfp410_dvi_d
add wave -noupdate /system_testbench/tfp410_de
add wave -noupdate /system_testbench/tfp410_hs
add wave -noupdate /system_testbench/tfp410_vs
add wave -noupdate /system_testbench/tfp410_pclk

# 视频帧缓冲
add wave -noupdate -divider "=== Video Frame Buffer ==="
add wave -noupdate /system_testbench/u_dut/u_frame_buf/wr_addr
add wave -noupdate /system_testbench/u_dut/u_frame_buf/wr_en
add wave -noupdate /system_testbench/u_dut/u_frame_buf/rd_addr
add wave -noupdate /system_testbench/u_dut/u_frame_buf/rd_en

# SPI Flash
add wave -noupdate -divider "=== SPI Flash ==="
add wave -noupdate /system_testbench/flash_cs_n
add wave -noupdate /system_testbench/flash_clk
add wave -noupdate /system_testbench/flash_mosi
add wave -noupdate /system_testbench/flash_miso
add wave -noupdate /system_testbench/u_dut/u_flash_ctrl/state

# UART
add wave -noupdate -divider "=== UART ==="
add wave -noupdate /system_testbench/uart_tx
add wave -noupdate /system_testbench/uart_rx

# 视频 DAC
add wave -noupdate -divider "=== Video DAC (ADV7125) ==="
add wave -noupdate /system_testbench/adv7125_red
add wave -noupdate /system_testbench/adv7125_green
add wave -noupdate /system_testbench/adv7125_blue
add wave -noupdate /system_testbench/adv7125_clk

#============================================================================
# 波形显示配置
#============================================================================

# 设置 radix
radix hex

# 设置颜色
configure wave -signalnamewidth 1
configure wave -timeline 0
configure wave -timelineunits ns
