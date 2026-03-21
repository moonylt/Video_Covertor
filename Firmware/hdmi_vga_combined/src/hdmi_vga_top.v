//============================================================================
// Module:      hdmi_vga_top
// Description: HDMI + VGA 双输出测试工程顶层模块
//              同时输出彩条测试图案到 HDMI (TFP410) 和 VGA (ADV7125)
//
// 功能:
//   - HDMI 输出: 720p @ 60Hz (1280x720), 像素时钟 74.25MHz
//   - VGA 输出:  800x600 @ 60Hz, 像素时钟 40MHz
//   - 通过按键切换测试图案
//   - 支持全白/红/绿/蓝/彩条/网格测试
//
// 使用方法:
//   1. 用 Xilinx Clocking Wizard 生成 PLL:
//      - 输入: 50MHz
//      - 输出1: 74.25MHz (HDMI)
//      - 输出2: 40MHz (VGA)
//      - 替换 clk_wiz_dual.v
//   2. 编译并下载
//   3. 按 BTN0 切换测试图案
//
// Author:      FPGA Verification Team
// Date:        2026-03-21
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module hdmi_vga_top (
    //========================================================================
    // 时钟输入
    //========================================================================
    input           clk_50mhz,          // 50MHz 系统时钟

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
    // HDMI 输出接口 (TFP410) - 720p @ 60Hz
    //========================================================================
    output  [23:0]  tfp410_dvi_d,       // 24位 RGB 数据
    output          tfp410_de,          // 数据使能
    output          tfp410_hs,          // 行同步
    output          tfp410_vs,          // 场同步
    output          tfp410_pclk,        // 像素时钟

    //========================================================================
    // ADV7125 VGA 输出 (8位 RGB)
    //========================================================================
    output  [7:0]   adv7125_red,        // 红色数据 (8位)
    output  [7:0]   adv7125_green,      // 绿色数据 (8位)
    output  [7:0]   adv7125_blue,       // 蓝色数据 (8位)
    output          adv7125_clk,        // DAC 时钟
    output          adv7125_blank_n,    // 消隐控制

    //========================================================================
    // VGA 同步信号
    //========================================================================
    output          vga_hs,             // 行同步
    output          vga_vs,             // 场同步

    //========================================================================
    // 用户接口
    //========================================================================
    input   [1:0]   btn_n,              // 用户按键

    //========================================================================
    // 测试点
    //========================================================================
    output  [3:0]   test_point
);

    //========================================================================
    // 内部信号
    //========================================================================
    // 时钟和复位
    wire            hdmi_clk;           // 74.25MHz HDMI 像素时钟
    wire            vga_clk;            // 40MHz VGA 像素时钟
    wire            pll_locked;
    wire            sys_rst_n;

    // HDMI 输出信号
    wire    [23:0]  hdmi_data;
    wire            hdmi_de;
    wire            hdmi_hs;
    wire            hdmi_vs;
    wire            hdmi_active;

    // VGA 输出信号
    wire    [23:0]  vga_data;
    wire            vga_de;
    wire            vga_hs_int;
    wire            vga_vs_int;
    wire            vga_active;

    // 测试图案控制
    reg     [2:0]   test_mode;
    reg     [2:0]   test_mode_sync_hdmi;
    reg     [2:0]   test_mode_sync_vga;
    wire            btn0_rising;

    //========================================================================
    // PLL 时钟生成 (需要用 Clocking Wizard 替换)
    //========================================================================
    // 输入: 50MHz
    // 输出1: 74.25MHz (HDMI 720p)
    // 输出2: 40MHz (VGA 800x600)
    clk_wiz_dual u_pll (
        .clk_in1      (clk_50mhz),
        .clk_out1     (hdmi_clk),       // 74.25MHz
        .clk_out2     (vga_clk),        // 40MHz
        .reset        (~rst_n),
        .locked       (pll_locked)
    );

    //========================================================================
    // 复位控制
    //========================================================================
    reg [3:0] rst_sync_hdmi, rst_sync_vga;

    always @(posedge hdmi_clk or negedge rst_n) begin
        if (!rst_n)
            rst_sync_hdmi <= 4'b0;
        else if (pll_locked)
            rst_sync_hdmi <= {rst_sync_hdmi[2:0], 1'b1};
    end

    always @(posedge vga_clk or negedge rst_n) begin
        if (!rst_n)
            rst_sync_vga <= 4'b0;
        else if (pll_locked)
            rst_sync_vga <= {rst_sync_vga[2:0], 1'b1};
    end

    assign sys_rst_n = rst_sync_hdmi[3] & rst_sync_vga[3];

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

    always @(posedge hdmi_clk or negedge rst_n) begin
        if (!rst_n) begin
            btn0_dly1 <= 1'b1;
            btn0_dly2 <= 1'b1;
        end else begin
            btn0_dly1 <= btn_n[0];
            btn0_dly2 <= btn0_dly1;
        end
    end

    assign btn0_rising = !btn0_dly1 && btn0_dly2;  // 上升沿检测 (低有效按键)

    always @(posedge hdmi_clk or negedge rst_n) begin
        if (!rst_n)
            test_mode <= 3'd0;
        else if (btn0_rising)
            test_mode <= (test_mode == 3'd5) ? 3'd0 : test_mode + 3'd1;
    end

    // 同步 test_mode 到各时钟域
    always @(posedge hdmi_clk) begin
        test_mode_sync_hdmi <= test_mode;
    end

    always @(posedge vga_clk) begin
        test_mode_sync_vga <= test_mode;
    end

    //========================================================================
    // HDMI 测试图案发生器 (720p @ 60Hz)
    //========================================================================
    hdmi_test_pattern u_hdmi_pattern (
        .clk            (hdmi_clk),
        .rst_n          (rst_sync_hdmi[3]),
        .mode           (test_mode_sync_hdmi),

        .hdmi_data      (hdmi_data),
        .hdmi_de        (hdmi_de),
        .hdmi_hs        (hdmi_hs),
        .hdmi_vs        (hdmi_vs),

        .active         (hdmi_active),
        .locked         ()
    );

    //========================================================================
    // VGA 测试图案发生器 (800x600 @ 60Hz)
    //========================================================================
    vga_colorbar_800x600 u_vga_pattern (
        .clk            (vga_clk),
        .rst_n          (rst_sync_vga[3]),
        .mode           (test_mode_sync_vga),  // 添加测试模式选择

        .rgb_data       (vga_data),
        .de             (vga_de),
        .hs             (vga_hs_int),
        .vs             (vga_vs_int),
        .active         (vga_active)
    );

    //========================================================================
    // HDMI 输出
    //========================================================================
    assign tfp410_dvi_d = hdmi_data;
    assign tfp410_de    = hdmi_de;
    assign tfp410_hs    = hdmi_hs;
    assign tfp410_vs    = hdmi_vs;

    // 使用 ODDR2 驱动 HDMI 像素时钟
    ODDR2 #(
        .DDR_ALIGNMENT("NONE"),
        .INIT(1'b0),
        .SRTYPE("SYNC")
    ) u_oddr2_hdmi_pclk (
        .Q              (tfp410_pclk),
        .C0             (hdmi_clk),
        .C1             (~hdmi_clk),
        .CE             (1'b1),
        .D0             (1'b1),
        .D1             (1'b0),
        .R              (1'b0),
        .S              (1'b0)
    );

    //========================================================================
    // VGA 输出 (ADV7125)
    //========================================================================
    // RGB 数据截取高8位
    assign adv7125_red   = vga_data[23:16];
    assign adv7125_green = vga_data[15:8];
    assign adv7125_blue  = vga_data[7:0];
    assign adv7125_clk   = vga_clk;
    assign adv7125_blank_n = vga_de;

    // VGA 同步输出
    assign vga_hs = vga_hs_int;
    assign vga_vs = vga_vs_int;

    //========================================================================
    // 测试点输出
    //========================================================================
    assign test_point[0] = pll_locked;      // PLL 锁定
    assign test_point[1] = hdmi_active;     // HDMI 有效
    assign test_point[2] = vga_active;      // VGA 有效
    assign test_point[3] = hdmi_de;         // HDMI DE

endmodule