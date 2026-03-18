//============================================================================
// Module:      hdmi_test_pattern
// Description: HDMI 调试测试图案发生器
//              支持多种测试图案，用于诊断 TFP410 输出
//
// 测试模式 (通过 mode 选择):
//   mode=0: 全白屏幕
//   mode=1: 全红屏幕
//   mode=2: 全绿屏幕
//   mode=3: 全蓝屏幕
//   mode=4: 8 色彩条
//   mode=5: 网格图案
//
// 支持分辨率：720p @ 60Hz (1280x720)
// 像素时钟：74.25MHz
//
// Author:      FPGA Verification Team
// Date:        2026-03-17
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module hdmi_test_pattern (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 74.25MHz 像素时钟
    input           rst_n,                // 异步复位 (低有效)
    input   [2:0]   mode,                 // 测试图案选择
    
    //========================================================================
    // HDMI 输出接口
    //========================================================================
    output  [23:0]  hdmi_data,            // 24 位 RGB 数据
    output          hdmi_de,              // 数据使能
    output          hdmi_hs,              // 行同步
    output          hdmi_vs,              // 场同步
    
    //========================================================================
    // 状态指示
    //========================================================================
    output          active,               // 视频输出有效指示
    output          locked                // 发生器锁定指示
);

    //========================================================================
    // 本地参数定义 - 720p@60Hz 时序
    //========================================================================
    localparam H_ACTIVE     = 12'd1280;
    localparam H_FRONT      = 12'd110;
    localparam H_SYNC       = 12'd40;
    localparam H_BACK       = 12'd220;
    localparam H_TOTAL      = 12'd1650;
    
    localparam V_ACTIVE     = 11'd720;
    localparam V_FRONT      = 11'd5;
    localparam V_SYNC       = 11'd5;
    localparam V_BACK       = 11'd20;
    localparam V_TOTAL      = 11'd750;
    
    localparam BAR_WIDTH    = 12'd160;    // 1280/8
    
    //========================================================================
    // 内部信号
    //========================================================================
    reg [11:0] h_count;
    reg [10:0] v_count;
    reg hs_reg;
    reg vs_reg;
    reg de_reg;
    reg [23:0] pixel_data;
    
    //========================================================================
    // 计数器
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) h_count <= 12'd0;
        else if (h_count >= H_TOTAL - 1'b1) h_count <= 12'd0;
        else h_count <= h_count + 12'd1;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) v_count <= 11'd0;
        else if (h_count == H_TOTAL - 1'b1) begin
            if (v_count >= V_TOTAL - 1'b1) v_count <= 11'd0;
            else v_count <= v_count + 11'd1;
        end
    end
    
    //========================================================================
    // 同步信号
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) hs_reg <= 1'b1;
        else hs_reg <= (h_count >= H_ACTIVE + H_FRONT && 
                        h_count < H_ACTIVE + H_FRONT + H_SYNC) ? 1'b0 : 1'b1;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) vs_reg <= 1'b1;
        else vs_reg <= (v_count >= V_ACTIVE + V_FRONT && 
                        v_count < V_ACTIVE + V_FRONT + V_SYNC) ? 1'b0 : 1'b1;
    end
    
    //========================================================================
    // 数据使能
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) de_reg <= 1'b0;
        else de_reg <= (h_count < H_ACTIVE && v_count < V_ACTIVE) ? 1'b1 : 1'b0;
    end
    
    //========================================================================
    // 测试图案生成
    //========================================================================
    wire [2:0] bar_index = h_count / BAR_WIDTH;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data <= 24'd0;
        end else if (de_reg) begin
            case (mode)
                3'd0: pixel_data <= 24'hFFFFFF;  // 全白
                3'd1: pixel_data <= 24'hFF0000;  // 全红
                3'd2: pixel_data <= 24'h00FF00;  // 全绿
                3'd3: pixel_data <= 24'h0000FF;  // 全蓝
                3'd4: begin  // 8 色彩条
                    case (bar_index)
                        3'd0: pixel_data <= 24'hFFFFFF;  // 白
                        3'd1: pixel_data <= 24'hFFFF00;  // 黄
                        3'd2: pixel_data <= 24'h00FFFF;  // 青
                        3'd3: pixel_data <= 24'h00FF00;  // 绿
                        3'd4: pixel_data <= 24'hFF00FF;  // 紫
                        3'd5: pixel_data <= 24'hFF0000;  // 红
                        3'd6: pixel_data <= 24'h0000FF;  // 蓝
                        3'd7: pixel_data <= 24'h000000;  // 黑
                        default: pixel_data <= 24'h000000;
                    endcase
                end
                3'd5: begin  // 网格
                    if ((h_count[5:0] == 6'd0) || (v_count[5:0] == 6'd0))
                        pixel_data <= 24'hFFFFFF;
                    else
                        pixel_data <= 24'h000000;
                end
                default: pixel_data <= 24'h000000;
            endcase
        end
    end
    
    //========================================================================
    // 输出
    //========================================================================
    assign hdmi_data = de_reg ? pixel_data : 24'h000000;
    assign hdmi_de   = de_reg;
    assign hdmi_hs   = hs_reg;
    assign hdmi_vs   = vs_reg;
    assign active    = de_reg;
    assign locked    = 1'b1;

endmodule
