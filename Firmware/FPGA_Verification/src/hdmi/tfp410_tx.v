//============================================================================
// Module:      video_output_tfp410
// Description: TFP410 DVI/HDMI 发射器接口模块
//
// TFP410 功能:
//   - 接收 24 位 RGB 并行数据
//   - 编码为 TMDS 差分信号输出
//   - 支持 DVI 和 HDMI 模式
//
// 支持分辨率:
//   - 640x480 @ 60Hz
//   - 800x600 @ 60Hz
//   - 1024x768 @ 60Hz
//   - 1280x720 @ 60Hz (720p)
//   - 1920x1080 @ 60Hz (1080p)
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module video_output_tfp410 (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 异步复位 (低有效)
    
    //========================================================================
    // 内部视频流输入
    //========================================================================
    input   [23:0]  vid_data,             // 24 位 RGB 数据 (RGB888)
    input           vid_de,               // 数据使能
    input           vid_hs,               // 行同步
    input           vid_vs,               // 场同步
    input           vid_active,           // 视频有效指示
    
    //========================================================================
    // TFP410 并行接口
    //========================================================================
    output  [23:0]  dvi_d,                // 24 位 RGB 数据输出
    output          de,                   // 数据使能输出
    output          hs,                   // 行同步输出
    output          vs,                   // 场同步输出
    input           pclk,                 // 像素时钟输入 (来自外部 PLL)

    //========================================================================
    // 状态输出
    //========================================================================
    output          tx_active,            // 发送器工作指示
    output          tx_locked             // 发送器锁定指示

);

    //========================================================================
    // 内部信号定义
    //========================================================================
    
    // 数据延迟寄存器
    reg [23:0] vid_data_delay;
    reg        vid_de_delay;
    reg        vid_hs_delay;
    reg        vid_vs_delay;
    
    // 像素计数器
    reg [10:0] pixel_count;
    
    // 帧计数器
    reg [10:0] frame_count;
    
    // 输出使能
    reg        output_en;
    
    // 测试图案发生器
    reg [1:0]  test_pattern;
    localparam PATTERN_OFF     = 2'd0;    // 正常视频
    localparam PATTERN_COLOR   = 2'd1;    // 彩条测试
    localparam PATTERN_GRID    = 2'd2;    // 网格测试
    localparam PATTERN_GRADIENT= 2'd3;    // 渐变测试
    
    //========================================================================
    // 输入视频流延迟 (用于时序对齐)
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vid_data_delay <= 24'd0;
            vid_de_delay <= 1'b0;
            vid_hs_delay <= 1'b0;
            vid_vs_delay <= 1'b0;
        end else begin
            // 延迟一级以匹配输出时序
            vid_data_delay <= vid_data;
            vid_de_delay <= vid_de;
            vid_hs_delay <= vid_hs;
            vid_vs_delay <= vid_vs;
        end
    end
    
    //========================================================================
    // 输出使能控制
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            output_en <= 1'b0;
        end else begin
            // 当视频有效时启用输出
            output_en <= vid_active;
        end
    end
    
    //========================================================================
    // TFP410 数据输出
    //========================================================================
    
    wire [23:0] output_data;
    
    // 选择正常视频或测试图案
    assign output_data = (test_pattern == PATTERN_OFF) ? vid_data_delay : test_pattern_gen;
    
    // 测试图案发生器
    wire [23:0] test_pattern_gen;
    
    generate
        genvar i;
        for (i = 0; i < 24; i = i + 1) begin : test_pattern_gen_block
            assign test_pattern_gen[i] = (test_pattern == PATTERN_COLOR) ? 
                color_bar_pattern[i] :
                (test_pattern == PATTERN_GRID) ?
                grid_pattern[i] :
                gradient_pattern[i];
        end
    endgenerate
    
    // 彩条测试图案
    reg [23:0] color_bar_pattern;
    always @(*) begin
        case (pixel_count[10:8])
            3'd0: color_bar_pattern = 24'hFF0000;  // 红色
            3'd1: color_bar_pattern = 24'h00FF00;  // 绿色
            3'd2: color_bar_pattern = 24'h0000FF;  // 蓝色
            3'd3: color_bar_pattern = 24'hFFFF00;  // 黄色
            3'd4: color_bar_pattern = 24'h00FFFF;  // 青色
            3'd5: color_bar_pattern = 24'hFF00FF;  // 品红
            3'd6: color_bar_pattern = 24'hFFFFFF;  // 白色
            3'd7: color_bar_pattern = 24'h000000;  // 黑色
            default: color_bar_pattern = 24'h000000;
        endcase
    end
    
    // 网格测试图案
    reg [23:0] grid_pattern;
    always @(*) begin
        if ((pixel_count[4:0] == 5'd0) || (frame_count[4:0] == 5'd0))
            grid_pattern = 24'hFFFFFF;  // 白色网格线
        else
            grid_pattern = 24'h000000;  // 黑色背景
    end
    
    // 渐变测试图案
    wire [23:0] gradient_pattern;
    assign gradient_pattern = {pixel_count[9:0], frame_count[9:0], 4'd0};
    
    // 最终输出
    assign dvi_d = output_en ? output_data : 24'd0;
    assign de = output_en ? vid_de_delay : 1'b0;
    assign hs = output_en ? vid_hs_delay : 1'b0;
    assign vs = output_en ? vid_vs_delay : 1'b0;

    //========================================================================
    // 像素和帧计数器
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_count <= 11'd0;
        end else if (vid_de_delay) begin
            if (pixel_count < 11'd2047)
                pixel_count <= pixel_count + 11'd1;
            else
                pixel_count <= 11'd0;
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            frame_count <= 11'd0;
        end else if (!vid_de_delay && vid_de_delay) begin
            // DE 下降沿，新行开始
            if (vid_vs_delay) begin
                // 新帧开始
                if (frame_count < 11'd1023)
                    frame_count <= frame_count + 11'd1;
                else
                    frame_count <= 11'd0;
            end
        end
    end
    
    //========================================================================
    // 状态输出
    //========================================================================
    
    assign tx_active = output_en;
    assign tx_locked = output_en;  // 简化，实际需要 PLL 锁定检测
    
    //========================================================================
    // 调试信息
    //========================================================================
    
    // 当前像素位置：pixel_count
    // 当前帧位置：frame_count
    // 测试图案模式：test_pattern
    
endmodule
