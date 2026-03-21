//============================================================================
// Module:      vga_colorbar_800x600
// Description: VGA 测试图案发生器 (支持多种测试模式)
//              800x600 @ 60Hz 分辨率
//
// 时序参数:
//   水平：800 + 40 (前肩) + 128 (同步) + 88 (后肩) = 1056
//   垂直：600 + 1 (前肩) + 4 (同步) + 23 (后肩) = 628
//   像素时钟：40MHz
//
// 测试模式 (通过 mode 选择):
//   mode=0: 全白屏幕
//   mode=1: 全红屏幕
//   mode=2: 全绿屏幕
//   mode=3: 全蓝屏幕
//   mode=4: 8 色彩条
//   mode=5: 网格图案
//============================================================================

`timescale 1ns / 1ps

module vga_colorbar_800x600 (
    input           clk,                  // 40MHz 像素时钟
    input           rst_n,                // 异步复位
    input   [2:0]   mode,                 // 测试图案选择

    output  [23:0]  rgb_data,             // RGB888 数据
    output          de,                   // 数据使能
    output          hs,                   // 行同步
    output          vs,                   // 场同步
    output          active                // 视频有效指示
);

    //========================================================================
    // 时序参数 (800x600 @ 60Hz)
    //========================================================================
    localparam H_ACTIVE     = 11'd800;
    localparam H_FRONT      = 11'd40;
    localparam H_SYNC       = 11'd128;
    localparam H_BACK       = 11'd88;
    localparam H_TOTAL      = 11'd1056;

    localparam V_ACTIVE     = 11'd600;
    localparam V_FRONT      = 11'd1;
    localparam V_SYNC       = 11'd4;
    localparam V_BACK       = 11'd23;
    localparam V_TOTAL      = 11'd628;

    localparam BAR_WIDTH    = 11'd100;    // 800/8 = 100

    //========================================================================
    // 内部信号
    //========================================================================
    reg [10:0] h_count;
    reg [10:0] v_count;
    reg hs_reg;
    reg vs_reg;
    reg de_reg;
    wire [2:0] bar_index;
    wire [23:0] bar_color;
    reg [23:0] pixel_data;

    //========================================================================
    // 水平计数器
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            h_count <= 11'd0;
        else if (h_count >= H_TOTAL - 1'b1)
            h_count <= 11'd0;
        else
            h_count <= h_count + 11'd1;
    end

    //========================================================================
    // 垂直计数器
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            v_count <= 11'd0;
        else if (h_count == H_TOTAL - 1'b1) begin
            if (v_count >= V_TOTAL - 1'b1)
                v_count <= 11'd0;
            else
                v_count <= v_count + 11'd1;
        end
    end

    //========================================================================
    // 行同步信号 (低有效)
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            hs_reg <= 1'b1;
        else if (h_count >= H_ACTIVE + H_FRONT &&
                 h_count < H_ACTIVE + H_FRONT + H_SYNC)
            hs_reg <= 1'b0;
        else
            hs_reg <= 1'b1;
    end

    //========================================================================
    // 场同步信号 (低有效)
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            vs_reg <= 1'b1;
        else if (v_count >= V_ACTIVE + V_FRONT &&
                 v_count < V_ACTIVE + V_FRONT + V_SYNC)
            vs_reg <= 1'b0;
        else
            vs_reg <= 1'b1;
    end

    //========================================================================
    // 数据使能信号
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            de_reg <= 1'b0;
        else if (h_count < H_ACTIVE && v_count < V_ACTIVE)
            de_reg <= 1'b1;
        else
            de_reg <= 1'b0;
    end

    //========================================================================
    // 彩条位置计算
    //========================================================================
    assign bar_index = (h_count < H_ACTIVE) ? (h_count / BAR_WIDTH) : 3'd7;

    //========================================================================
    // 彩条颜色生成 (SMPTE 标准)
    //========================================================================
    assign bar_color =
        (bar_index == 3'd0) ? 24'hFFFFFF :  // 白色
        (bar_index == 3'd1) ? 24'hFFFF00 :  // 黄色
        (bar_index == 3'd2) ? 24'h00FFFF :  // 青色
        (bar_index == 3'd3) ? 24'h00FF00 :  // 绿色
        (bar_index == 3'd4) ? 24'hFF00FF :  // 紫色
        (bar_index == 3'd5) ? 24'hFF0000 :  // 红色
        (bar_index == 3'd6) ? 24'h0000FF :  // 蓝色
                              24'h000000;   // 黑色

    //========================================================================
    // 测试图案生成 (支持多种模式)
    //========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_data <= 24'd0;
        end else if (de_reg) begin
            case (mode)
                3'd0: pixel_data <= 24'hFFFFFF;  // 全白
                3'd1: pixel_data <= 24'hFF0000;  // 全红
                3'd2: pixel_data <= 24'h00FF00;  // 全绿
                3'd3: pixel_data <= 24'h0000FF;  // 全蓝
                3'd4: pixel_data <= bar_color;   // 8 色彩条
                3'd5: begin  // 网格
                    if ((h_count[5:0] == 6'd0) || (v_count[5:0] == 6'd0))
                        pixel_data <= 24'hFFFFFF;
                    else
                        pixel_data <= 24'h000000;
                end
                default: pixel_data <= bar_color;  // 默认彩条
            endcase
        end
    end

    //========================================================================
    // 输出赋值
    //========================================================================
    assign rgb_data = de_reg ? pixel_data : 24'h000000;
    assign de       = de_reg;
    assign hs       = hs_reg;
    assign vs       = vs_reg;
    assign active   = de_reg;

endmodule