//============================================================================
// Module:      clk_wiz_dual
// Description: 双输出 PLL 时钟生成器
//              输入: 50MHz
//              输出1: 74.25MHz (HDMI 720p)
//              输出2: 40MHz (VGA 800x600)
//
// ⚠️ 重要：此文件是占位代码！
// 请使用 Xilinx Clocking Wizard 生成真正的 PLL 核
//
// 生成步骤:
// 1. 打开 Xilinx ISE 14.7
// 2. Tools → Clocking Wizard
// 3. 配置如下:
//    - Device: Spartan-6, xc6slx45fgg484-3
//    - Input Clock 1: 50.000 MHz
//    - Output Clock 1: 74.25 MHz (CLKOUT1) - HDMI 720p
//    - Output Clock 2: 40.00 MHz (CLKOUT2) - VGA 800x600
//    - PLL: PLL_ADV
//    - Reset: Active High
//    - Locked: Yes
// 4. 生成后保存为 clk_wiz_dual.v
//============================================================================

`timescale 1ns / 1ps

module clk_wiz_dual (
    input           clk_in1,        // 50MHz 输入时钟
    output          clk_out1,       // 74.25MHz HDMI 像素时钟
    output          clk_out2,       // 40MHz VGA 像素时钟
    input           reset,          // 复位 (高有效)
    output          locked          // PLL 锁定指示
);

    //========================================================================
    // ⚠️ 警告：这是临时占位代码！
    // 实际使用时必须用 Xilinx Clocking Wizard 生成的 PLL 核替换
    //========================================================================

    // 临时占位：输出 50MHz (实际应该是 74.25MHz 和 40MHz)
    reg clk_out1_reg;
    reg clk_out2_reg;
    reg locked_reg;

    // 临时分频 (仅用于语法检查)
    reg [3:0] cnt1;
    reg [2:0] cnt2;

    always @(posedge clk_in1 or posedge reset) begin
        if (reset) begin
            cnt1 <= 4'd0;
            clk_out1_reg <= 1'b0;
        end else begin
            cnt1 <= cnt1 + 4'd1;
            if (cnt1 == 4'd0)
                clk_out1_reg <= ~clk_out1_reg;
        end
    end

    always @(posedge clk_in1 or posedge reset) begin
        if (reset) begin
            cnt2 <= 3'd0;
            clk_out2_reg <= 1'b0;
        end else begin
            cnt2 <= cnt2 + 3'd1;
            if (cnt2 == 3'd0)
                clk_out2_reg <= ~clk_out2_reg;
        end
    end

    // 临时锁定指示
    reg [15:0] lock_cnt;
    always @(posedge clk_in1 or posedge reset) begin
        if (reset) begin
            lock_cnt <= 16'd0;
            locked_reg <= 1'b0;
        end else if (lock_cnt < 16'd1000) begin
            lock_cnt <= lock_cnt + 16'd1;
            locked_reg <= 1'b0;
        end else begin
            locked_reg <= 1'b1;
        end
    end

    assign clk_out1 = clk_out1_reg;
    assign clk_out2 = clk_out2_reg;
    assign locked = locked_reg;

endmodule