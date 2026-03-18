//============================================================================
// Module:      adv7125_colorbar_top
// Description: ADV7125 VGA 彩条测试顶层模块
//              生成 8 色彩条图案输出到 VGA 显示器
//
// 功能:
//   - 8 色彩条：白、黄、青、绿、紫、红、蓝、黑
//   - 分辨率：800x600 @ 60Hz
//   - 像素时钟：40MHz
//   - RGB 数据：8 位 (根据原理图)
//
// Author:      FPGA Verification Team
// Date:        2026-03-17
// Version:     1.1 (8-bit RGB)
//============================================================================

`timescale 1ns / 1ps

module adv7125_colorbar_top (
    //========================================================================
    // 时钟和复位
    //========================================================================
    input           clk_50mhz,          // 50MHz 系统时钟
    input           rst_n,              // 全局复位，低有效

    //========================================================================
    // DDR3L - 固定电平 (不使用)
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
    // ADV7125 VGA 输出 (8 位 RGB)
    //========================================================================
    output  [7:0]   adv7125_red,        // 红色数据 (8 位)
    output  [7:0]   adv7125_green,      // 绿色数据 (8 位)
    output  [7:0]   adv7125_blue,       // 蓝色数据 (8 位)
    output          adv7125_clk,        // DAC 时钟
    output          adv7125_blank_n,    // 消隐控制

    //========================================================================
    // VGA 同步信号
    //========================================================================
    output          vga_hs,             // 行同步
    output          vga_vs              // 场同步
);

    //========================================================================
    // 内部信号
    //========================================================================
    wire            pixel_clk;          // 40MHz 像素时钟
    wire            pixel_clk_buf;      // 缓冲后像素时钟
    wire            pll_locked;
    wire            sys_rst_n;
    
    // 彩条信号
    wire    [23:0]  color_data;
    wire            color_de;
    wire            color_hs;
    wire            color_vs;
    wire            color_active;

    //========================================================================
    // PLL 时钟生成 (50MHz -> 40MHz)
    //========================================================================
    clk_wiz_50to40 u_pll (
        .clk_in1      (clk_50mhz),
        .clk_out1     (pixel_clk),      // 40MHz 像素时钟
        .reset        (~rst_n),
        .locked       (pll_locked)
    );

    //========================================================================
    // 时钟缓冲
    //========================================================================
    BUFG u_bufg_clk (
        .I(pixel_clk),
        .O(pixel_clk_buf)
    );

    //========================================================================
    // 复位控制 (简单同步释放)
    //========================================================================
    reg rst_sync1, rst_sync2;
    
    always @(posedge pixel_clk_buf) begin
        rst_sync1 <= ~rst_n;
        rst_sync2 <= rst_sync1;
    end
    
    assign sys_rst_n = ~rst_sync2;

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
    // 彩条测试图案发生器 (800x600@60Hz)
    //========================================================================
    vga_colorbar_800x600 u_colorbar (
        .clk            (pixel_clk_buf),
        .rst_n          (sys_rst_n),
        
        .rgb_data       (color_data),
        .de             (color_de),
        .hs             (color_hs),
        .vs             (color_vs),
        .active         (color_active)
    );

    //========================================================================
    // ADV7125 驱动 (8 位 RGB)
    //========================================================================
    // 注意：根据原理图，ADV7125 使用 8 位 RGB 数据
    // 通过电阻排 RN14(红色), RN19/RN20(绿色), RN16/RN17(蓝色) 连接
    adv7125_driver_8bit u_adv7125 (
        .clk            (pixel_clk_buf),
        .rst_n          (sys_rst_n),
        
        .vid_data       (color_data),
        .vid_de         (color_de),
        .vid_hs         (color_hs),
        .vid_vs         (color_vs),
        
        .dac_red        (adv7125_red),
        .dac_green      (adv7125_green),
        .dac_blue       (adv7125_blue),
        .dac_clk        (adv7125_clk),
        .dac_blank_n    (adv7125_blank_n),
        .dac_active     ()
    );

    //========================================================================
    // VGA 同步输出
    //========================================================================
    assign vga_hs = color_hs;
    assign vga_vs = color_vs;

endmodule
