//============================================================================
// Module:      video_timing_gen
// Description: 视频时序信号发生器
//
// 支持的标准时序:
//   - VGA  640x480  @ 60Hz
//   - SVGA 800x600  @ 60Hz
//   - XGA  1024x768 @ 60Hz
//   - 720p 1280x720 @ 60Hz
//   - 1080p 1920x1080 @ 60Hz
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module video_timing_gen (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 像素时钟
    input           rst_n,                // 异步复位 (低有效)
    
    //========================================================================
    // 模式选择
    //========================================================================
    input   [2:0]   video_mode,           // 视频模式选择
                                        // 0=640x480, 1=800x600, 2=1024x768
                                        // 3=1280x720, 4=1920x1080
    
    //========================================================================
    // 视频时序输出
    //========================================================================
    output          hs,                   // 行同步
    output          vs,                   // 场同步
    output          de,                   // 数据使能
    output          active_video,         // 有效视频区域
    
    //========================================================================
    // 像素位置输出
    //========================================================================
    output  [11:0]  hcount,               // 水平像素计数
    output  [11:0]  vcount,               // 垂直行计数
    
    //========================================================================
    // 状态输出
    //========================================================================
    output          timing_locked,        // 时序锁定
    output  [15:0]  h_total,              // 水平总周期
    output  [15:0]  v_total               // 垂直总行数
    
);

    //========================================================================
    // 参数定义 - 视频时序参数
    //========================================================================
    
    // 640x480 @ 60Hz (VGA)
    // 像素时钟：25.175MHz
    localparam H640_ACTIVE  = 12'd640;
    localparam H640_FP      = 12'd16;     // 前肩
    localparam H640_SYNC    = 12'd96;     // 同步脉冲
    localparam H640_BP      = 12'd48;     // 后肩
    localparam H640_TOTAL  = 12'd800;
    
    localparam V640_ACTIVE  = 12'd480;
    localparam V640_FP      = 12'd10;
    localparam V640_SYNC    = 12'd2;
    localparam V640_BP      = 12'd33;
    localparam V640_TOTAL  = 12'd525;
    
    // 800x600 @ 60Hz (SVGA)
    // 像素时钟：40MHz
    localparam H800_ACTIVE  = 12'd800;
    localparam H800_FP      = 12'd40;
    localparam H800_SYNC    = 12'd128;
    localparam H800_BP      = 12'd88;
    localparam H800_TOTAL  = 12'd1056;
    
    localparam V800_ACTIVE  = 12'd600;
    localparam V800_FP      = 12'd1;
    localparam V800_SYNC    = 12'd4;
    localparam V800_BP      = 12'd23;
    localparam V800_TOTAL  = 12'd628;
    
    // 1024x768 @ 60Hz (XGA)
    // 像素时钟：65MHz
    localparam H1024_ACTIVE = 12'd1024;
    localparam H1024_FP     = 12'd24;
    localparam H1024_SYNC   = 12'd136;
    localparam H1024_BP     = 12'd160;
    localparam H1024_TOTAL = 12'd1344;
    
    localparam V1024_ACTIVE = 12'd768;
    localparam V1024_FP     = 12'd3;
    localparam V1024_SYNC   = 12'd6;
    localparam V1024_BP     = 12'd29;
    localparam V1024_TOTAL = 12'd806;
    
    // 1280x720 @ 60Hz (720p)
    // 像素时钟：74.25MHz
    localparam H720_ACTIVE  = 12'd1280;
    localparam H720_FP      = 12'd110;
    localparam H720_SYNC    = 12'd40;
    localparam H720_BP      = 12'd220;
    localparam H720_TOTAL  = 12'd1650;
    
    localparam V720_ACTIVE  = 12'd720;
    localparam V720_FP      = 12'd5;
    localparam V720_SYNC    = 12'd5;
    localparam V720_BP      = 12'd20;
    localparam V720_TOTAL  = 12'd750;
    
    // 1920x1080 @ 60Hz (1080p)
    // 像素时钟：148.5MHz
    localparam H1080_ACTIVE = 12'd1920;
    localparam H1080_FP     = 12'd88;
    localparam H1080_SYNC   = 12'd44;
    localparam H1080_BP     = 12'd148;
    localparam H1080_TOTAL = 12'd2200;
    
    localparam V1080_ACTIVE = 12'd1080;
    localparam V1080_FP     = 12'd4;
    localparam V1080_SYNC   = 12'd5;
    localparam V1080_BP     = 12'd36;
    localparam V1080_TOTAL = 12'd1125;
    
    //========================================================================
    // 内部信号
    //========================================================================
    
    reg [11:0] h_active_end;
    reg [11:0] h_sync_end;
    reg [11:0] h_total_count;
    reg [11:0] v_active_end;
    reg [11:0] v_sync_end;
    reg [11:0] v_total_count;
    
    reg [11:0] hcount_reg;
    reg [11:0] vcount_reg;
    
    reg hs_reg;
    reg vs_reg;
    reg de_reg;
    
    //========================================================================
    // 模式选择 - 加载时序参数
    //========================================================================
    
    always @(*) begin
        case (video_mode)
            3'd0: begin  // 640x480
                h_active_end = H640_ACTIVE;
                h_sync_end = H640_ACTIVE + H640_FP;
                h_total_count = H640_TOTAL;
                v_active_end = V640_ACTIVE;
                v_sync_end = V640_ACTIVE + V640_FP;
                v_total_count = V640_TOTAL;
            end
            3'd1: begin  // 800x600
                h_active_end = H800_ACTIVE;
                h_sync_end = H800_ACTIVE + H800_FP;
                h_total_count = H800_TOTAL;
                v_active_end = V800_ACTIVE;
                v_sync_end = V800_ACTIVE + V800_FP;
                v_total_count = V800_TOTAL;
            end
            3'd2: begin  // 1024x768
                h_active_end = H1024_ACTIVE;
                h_sync_end = H1024_ACTIVE + H1024_FP;
                h_total_count = H1024_TOTAL;
                v_active_end = V1024_ACTIVE;
                v_sync_end = V1024_ACTIVE + V1024_FP;
                v_total_count = V1024_TOTAL;
            end
            3'd3: begin  // 1280x720
                h_active_end = H720_ACTIVE;
                h_sync_end = H720_ACTIVE + H720_FP;
                h_total_count = H720_TOTAL;
                v_active_end = V720_ACTIVE;
                v_sync_end = V720_ACTIVE + V720_FP;
                v_total_count = V720_TOTAL;
            end
            3'd4: begin  // 1920x1080
                h_active_end = H1080_ACTIVE;
                h_sync_end = H1080_ACTIVE + H1080_FP;
                h_total_count = H1080_TOTAL;
                v_active_end = V1080_ACTIVE;
                v_sync_end = V1080_ACTIVE + V1080_FP;
                v_total_count = V1080_TOTAL;
            end
            default: begin  // 默认 640x480
                h_active_end = H640_ACTIVE;
                h_sync_end = H640_ACTIVE + H640_FP;
                h_total_count = H640_TOTAL;
                v_active_end = V640_ACTIVE;
                v_sync_end = V640_ACTIVE + V640_FP;
                v_total_count = V640_TOTAL;
            end
        endcase
    end
    
    //========================================================================
    // 水平计数器
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcount_reg <= 12'd0;
        end else begin
            if (hcount_reg < h_total_count - 12'd1)
                hcount_reg <= hcount_reg + 12'd1;
            else
                hcount_reg <= 12'd0;
        end
    end
    
    //========================================================================
    // 垂直计数器
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vcount_reg <= 12'd0;
        end else begin
            if (hcount_reg == h_total_count - 12'd1) begin
                if (vcount_reg < v_total_count - 12'd1)
                    vcount_reg <= vcount_reg + 12'd1;
                else
                    vcount_reg <= 12'd0;
            end
        end
    end
    
    //========================================================================
    // 行同步信号生成
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hs_reg <= 1'b0;
        end else begin
            // 同步脉冲在同步区间为低
            if (hcount_reg >= h_active_end && hcount_reg < h_sync_end)
                hs_reg <= 1'b0;
            else
                hs_reg <= 1'b1;
        end
    end
    
    //========================================================================
    // 场同步信号生成
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vs_reg <= 1'b0;
        end else begin
            // 同步脉冲在同步区间为低
            if (vcount_reg >= v_active_end && vcount_reg < v_sync_end)
                vs_reg <= 1'b0;
            else
                vs_reg <= 1'b1;
        end
    end
    
    //========================================================================
    // 数据使能信号生成
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            de_reg <= 1'b0;
        end else begin
            // DE 在有效视频区域为高
            if (hcount_reg < h_active_end && vcount_reg < v_active_end)
                de_reg <= 1'b1;
            else
                de_reg <= 1'b0;
        end
    end
    
    //========================================================================
    // 输出赋值
    //========================================================================
    
    assign hcount = hcount_reg;
    assign vcount = vcount_reg;
    assign hs = hs_reg;
    assign vs = vs_reg;
    assign de = de_reg;
    assign active_video = de_reg;
    assign timing_locked = 1'b1;  // 简化，实际可添加锁定检测
    assign h_total = h_total_count;
    assign v_total = v_total_count;
    
endmodule
