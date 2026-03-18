//============================================================================
// Module:      video_converter_top_debug
// Description: VIDEO_CONVERTER HDMI 硬件诊断顶层模块
//              用于诊断 TFP410 HDMI 输出是否正常工作
//
// 诊断功能:
//   - 通过按键切换测试图案
//   - LED 显示当前状态
//   - 支持全白/红/绿/蓝屏幕测试
//   - 支持彩条/网格测试
//
// 使用方法:
//   1. 下载比特流
//   2. 按 BTN[0] 切换测试图案
//   3. 观察显示器是否有输出
//   4. 观察 LED 状态
//
// Author:      FPGA Verification Team
// Date:        2026-03-17
// Version:     1.0 (Debug)
//============================================================================

`timescale 1ns / 1ps

module video_converter_top (
    //========================================================================
    // 时钟输入
    //========================================================================
    input           clk_50mhz,          // 50MHz 系统时钟
    input           clk_27mhz,          // 27MHz 视频时钟 (未使用)

    //========================================================================
    // 复位信号
    //========================================================================
    input           rst_n,              // 全局复位，低有效

    //========================================================================
    // DDR3L 内存接口 - 固定电平输出 (不使用)
    //========================================================================
    output  [1:0]   ddr3_dm,
    output  [15:0]  ddr3_dq,
    output  [1:0]   ddr3_dqs_n,
    output  [1:0]   ddr3_dqs_p,
    output  [13:0]  ddr3_addr,
    output  [2:0]   ddr3_ba,
    output          ddr3_ras_n,
    output          ddr3_cas_n,
    output          ddr3_we_n,
    output          ddr3_reset_n,
    output          ddr3_ck_p,
    output          ddr3_ck_n,
    output          ddr3_cke,
    output  [1:0]   ddr3_cs_n,
    output  [1:0]   ddr3_odt,

    //========================================================================
    // HDMI 输入接口 (TFP401A) - 未使用
    //========================================================================
    input   [23:0]  tfp401_dvi_d,
    input           tfp401_de,
    input           tfp401_hs,
    input           tfp401_vs,
    input           tfp401_pclk,

    //========================================================================
    // HDMI 输出接口 (TFP410)
    //========================================================================
    output  [23:0]  tfp410_dvi_d,
    output          tfp410_de,
    output          tfp410_hs,
    output          tfp410_vs,
    output          tfp410_pclk,

    //========================================================================
    // 用户接口
    //========================================================================
    input   [1:0]   btn_n,              // 用户按键
    output  [7:0]   led,                // LED 指示灯

    //========================================================================
    // 测试点
    //========================================================================
    output  [3:0]   test_point
);

    //========================================================================
    // 内部信号
    //========================================================================
    wire            sys_clk;
    wire            sys_clk_locked;
    wire            pixel_clk;
    wire            pixel_clk_buf;
    wire            sys_rst_n;
    
    // HDMI 输出信号
    wire    [23:0]  hdmi_data;
    wire            hdmi_de;
    wire            hdmi_hs;
    wire            hdmi_vs;
    wire            hdmi_active;
    
    // 测试图案控制
    reg     [2:0]   test_mode;
    reg     [2:0]   test_mode_dly;
    wire            btn0_rising;
    
    // 状态
    wire    [3:0]   sys_status;

    //========================================================================
    // 时钟管理 (PLL)
    //========================================================================
    clk_wiz_50to100 u_clk_wiz_sys (
        .clk_in1      (clk_50mhz),
        .clk_out1     (sys_clk),
        .clk_out2     (pixel_clk),
        .reset        (~rst_n),
        .locked       (sys_clk_locked)
    );

    //========================================================================
    // 复位控制
    //========================================================================
    rst_controller_simple u_rst_ctrl (
        .clk              (sys_clk),
        .rst_n            (rst_n),
        .pll_locked       (sys_clk_locked),
        .sys_rst_n        (sys_rst_n)
    );

    //========================================================================
    // DDR3 固定电平
    //========================================================================
    assign ddr3_dm      = 2'b00;
    assign ddr3_dq      = 16'bzzzzzzzzzzzzzzzz;
    assign ddr3_dqs_p   = 2'b00;
    assign ddr3_dqs_n   = 2'b00;
    assign ddr3_addr    = 14'b0;
    assign ddr3_ba      = 3'b0;
    assign ddr3_ras_n   = 1'b1;
    assign ddr3_cas_n   = 1'b1;
    assign ddr3_we_n    = 1'b1;
    assign ddr3_reset_n = 1'b1;
    assign ddr3_ck_p    = 1'b0;
    assign ddr3_ck_n    = 1'b0;
    assign ddr3_cke     = 1'b0;
    assign ddr3_cs_n    = 2'b11;
    assign ddr3_odt     = 2'b00;

    //========================================================================
    // 按键检测 (BTN0 切换测试图案)
    //========================================================================
    reg btn0_dly1, btn0_dly2;
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n) begin
            btn0_dly1 <= 1'b1;
            btn0_dly2 <= 1'b1;
            test_mode_dly <= 3'd0;
        end else begin
            btn0_dly1 <= btn_n[0];
            btn0_dly2 <= btn0_dly1;
            test_mode_dly <= test_mode;
        end
    end
    
    assign btn0_rising = !btn0_dly1 && btn0_dly2;  // 上升沿检测
    
    always @(posedge sys_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            test_mode <= 3'd0;
        else if (btn0_rising)
            test_mode <= (test_mode == 3'd5) ? 3'd0 : test_mode + 3'd1;
    end

    //========================================================================
    // 测试图案发生器
    //========================================================================
    hdmi_test_pattern u_test_pattern (
        .clk            (pixel_clk_buf),
        .rst_n          (sys_rst_n),
        .mode           (test_mode_dly),
        
        .hdmi_data      (hdmi_data),
        .hdmi_de        (hdmi_de),
        .hdmi_hs        (hdmi_hs),
        .hdmi_vs        (hdmi_vs),
        
        .active         (hdmi_active),
        .locked         ()
    );

    //========================================================================
    // 像素时钟缓冲
    //========================================================================
    BUFG u_bufg_pixel_clk (
        .I(pixel_clk),
        .O(pixel_clk_buf)
    );
    
    assign tfp410_pclk = pixel_clk_buf;

    //========================================================================
    // HDMI 输出
    //========================================================================
    assign tfp410_dvi_d = hdmi_data;
    assign tfp410_de    = hdmi_de;
    assign tfp410_hs    = hdmi_hs;
    assign tfp410_vs    = hdmi_vs;

    //========================================================================
    // LED 状态显示 (显示当前测试模式)
    //========================================================================
    // LED[0:2] = 测试模式二进制编码
    // LED[3]   = PLL 锁定指示
    // LED[4]   = HDMI 输出有效指示
    // LED[5:7] = 未使用 (熄灭)
    assign led[0] = test_mode[0];
    assign led[1] = test_mode[1];
    assign led[2] = test_mode[2];
    assign led[3] = sys_clk_locked;
    assign led[4] = hdmi_active;
    assign led[5] = 1'b0;
    assign led[6] = 1'b0;
    assign led[7] = 1'b0;

    //========================================================================
    // 测试点输出
    //========================================================================
    assign test_point[0] = sys_clk_locked;    // PLL 锁定
    assign test_point[1] = pixel_clk_buf;     // 像素时钟
    assign test_point[2] = hdmi_active;       // HDMI 数据有效
    assign test_point[3] = hdmi_de;           // 数据使能

endmodule
