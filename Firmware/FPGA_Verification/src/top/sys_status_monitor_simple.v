//============================================================================
// Module:      sys_status_monitor_simple
// Description: 系统状态监控模块 (简化版 - 无 DDR3 依赖)
//
// 功能:
//   - 监控系统工作状态
//   - 控制 LED 指示灯
//   - 响应按键输入
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module sys_status_monitor_simple (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 异步复位 (低有效)

    //========================================================================
    // 模块状态输入
    //========================================================================
    input           vid_in_active,        // 视频输入有效
    input           vid_out_active,       // 视频输出有效
    
    //========================================================================
    // 用户接口
    //========================================================================
    input   [1:0]   btn_n,                // 用户按键 (低有效)
    output  [7:0]   led,                  // LED 指示灯
    
    //========================================================================
    // 状态输出
    //========================================================================
    output  [3:0]   status                // 系统状态码
    
);

    //========================================================================
    // 内部信号定义
    //========================================================================
    
    // 按键消抖
    reg [1:0] btn_sync;
    reg [19:0] debounce_cnt;
    reg btn_pressed;
    
    // LED 闪烁计数器
    reg [24:0] blink_counter;
    wire       blink_slow;      // 慢速闪烁
    wire       blink_fast;      // 快速闪烁
    
    // LED 控制
    reg [7:0] led_reg;
    
    // LED 闪烁计数器
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            blink_counter <= 25'd0;
        else
            blink_counter <= blink_counter + 25'd1;
    end
    
    assign blink_slow = blink_counter[24];     // 约 0.6Hz @ 50MHz
    assign blink_fast = blink_counter[20];     // 约 10Hz @ 50MHz

    // 状态机
    reg [3:0] state_reg;
    localparam ST_INIT      = 4'd0;
    localparam ST_VIDEO_IN  = 4'd1;
    localparam ST_RUNNING   = 4'd2;
    localparam ST_ERROR     = 4'd15;
    
    //========================================================================
    // 按键消抖
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync <= 2'd0;
            debounce_cnt <= 20'd0;
            btn_pressed <= 1'b0;
        end else begin
            btn_sync <= {btn_sync[0], btn_n[0]};
            
            if (!btn_sync[1]) begin
                if (debounce_cnt < 20'd100000)
                    debounce_cnt <= debounce_cnt + 20'd1;
                else if (!btn_pressed)
                    btn_pressed <= 1'b1;
            end else begin
                debounce_cnt <= 20'd0;
                btn_pressed <= 1'b0;
            end
        end
    end
    
    //========================================================================
    // 状态机
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= ST_INIT;
        end else begin
            case (state_reg)
                ST_INIT: begin
                    if (vid_in_active)
                        state_reg <= ST_RUNNING;
                    else
                        state_reg <= ST_VIDEO_IN;
                end
                
                ST_VIDEO_IN: begin
                    if (vid_in_active)
                        state_reg <= ST_RUNNING;
                end
                
                ST_RUNNING: begin
                    if (!vid_in_active)
                        state_reg <= ST_VIDEO_IN;
                end
                
                ST_ERROR: begin
                    if (rst_n && vid_in_active)
                        state_reg <= ST_RUNNING;
                end
                
                default: begin
                    state_reg <= ST_INIT;
                end
            endcase
        end
    end
    
    //========================================================================
    // LED 控制
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_reg <= 8'd0;
        end else begin
            case (state_reg)
                ST_INIT: begin
                    led_reg <= 8'b00000001;  // LED0 亮
                end
                
                ST_VIDEO_IN: begin
                    // LED0 闪烁表示等待视频输入
                    led_reg <= {7'd0, blink_slow};
                end

                ST_RUNNING: begin
                    // 正常运行状态
                    led_reg <= {
                        !vid_out_active,      // LED7: 视频输出状态
                        !vid_in_active,       // LED6: 视频输入状态
                        6'b111111             // LED5-0: 保留/运行指示
                    };
                end

                ST_ERROR: begin
                    // 错误状态：所有 LED 快速闪烁
                    led_reg <= {8{blink_fast}};
                end
                
                default: begin
                    led_reg <= 8'd0;
                end
            endcase
        end
    end
    
    assign led = led_reg;
    assign status = state_reg;
    
endmodule
