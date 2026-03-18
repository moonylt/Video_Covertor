//============================================================================
// Module:      rst_controller
// Description: 系统复位控制器
//
// 功能:
//   - 上电复位管理
//   - PLL 锁定检测
//   - DDR3 校准完成等待
//   - 系统复位同步
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module rst_controller (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 外部复位 (低有效)
    
    //========================================================================
    // 锁定/完成信号
    //========================================================================
    input           pll_locked,           // PLL 锁定指示
    input           ddr3_calib_done,      // DDR3 校准完成
    
    //========================================================================
    // 系统复位输出
    //========================================================================
    output          sys_rst_n,            // 系统复位 (低有效)
    output          ddr3_rst_n            // DDR3 复位 (低有效)
    
);

    //========================================================================
    // 内部信号定义
    //========================================================================
    
    reg [3:0] rst_sync;
    reg [15:0] rst_counter;
    reg       rst_release;
    reg       ddr3_rst_release;
    
    localparam RST_COUNT_MAX = 16'd1000;  // 复位保持时间 (约 10us @ 100MHz)
    localparam DDR3_RST_COUNT_MAX = 16'd50000;  // DDR3 复位保持时间 (约 500us)
    
    //========================================================================
    // 外部复位同步
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_sync <= 4'd0;
        end else begin
            rst_sync <= {rst_sync[2:0], 1'b1};
        end
    end
    
    //========================================================================
    // 系统复位释放控制
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rst_counter <= 16'd0;
            rst_release <= 1'b0;
        end else if (!rst_sync[3]) begin
            // 外部复位有效，清零计数器
            rst_counter <= 16'd0;
            rst_release <= 1'b0;
        end else if (!pll_locked) begin
            // PLL 未锁定，保持复位
            rst_counter <= 16'd0;
            rst_release <= 1'b0;
        end else begin
            // PLL 锁定，开始计数
            if (rst_counter < RST_COUNT_MAX) begin
                rst_counter <= rst_counter + 16'd1;
                rst_release <= 1'b0;
            end else begin
                rst_release <= 1'b1;
            end
        end
    end
    
    assign sys_rst_n = rst_release;
    
    //========================================================================
    // DDR3 复位释放控制
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ddr3_rst_release <= 1'b0;
        end else if (!rst_sync[3]) begin
            ddr3_rst_release <= 1'b0;
        end else if (!ddr3_calib_done) begin
            ddr3_rst_release <= 1'b0;
        end else begin
            ddr3_rst_release <= 1'b1;
        end
    end
    
    assign ddr3_rst_n = ddr3_rst_release;
    
endmodule
