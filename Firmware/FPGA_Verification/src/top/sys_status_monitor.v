//============================================================================
// Module:      sys_status_monitor
// Description: 系统状态监控模块
//
// 功能:
//   - 监控系统各模块工作状态
//   - 控制 LED 指示灯
//   - 响应按键输入
//   - 提供调试状态输出
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module sys_status_monitor (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 异步复位 (低有效)
    
    //========================================================================
    // 模块状态输入
    //========================================================================
    input           ddr3_calib_done,      // DDR3 校准完成
    input           vid_in_active,        // 视频输入有效
    input           vid_out_active,       // 视频输出有效
    input           flash_ready,          // Flash 就绪
    
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
    reg btn_released;

    // LED 闪烁计数器
    reg [24:0] blink_counter;
    wire       blink_slow;      // 慢速闪烁
    wire       blink_fast;      // 快速闪烁
    
    // LED 控制
    reg [7:0] led_reg;
    
    // 状态机
    reg [3:0] state_reg;
    localparam ST_INIT      = 4'd0;
    localparam ST_DDR3_INIT = 4'd1;
    localparam ST_VIDEO_IN  = 4'd2;
    localparam ST_VIDEO_OUT = 4'd3;
    localparam ST_RUNNING   = 4'd4;
    localparam ST_ERROR     = 4'd15;
    
    // 错误标志
    reg ddr3_error;
    reg video_in_error;
    reg video_out_error;
    
    //========================================================================
    // LED 闪烁计数器
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            blink_counter <= 25'd0;
        else
            blink_counter <= blink_counter + 25'd1;
    end
    
    assign blink_slow = blink_counter[24];     // 约 0.6Hz @ 50MHz
    assign blink_fast = blink_counter[20];     // 约 10Hz @ 50MHz
    
    //========================================================================
    // 按键消抖
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            btn_sync <= 2'd0;
            debounce_cnt <= 20'd0;
            btn_pressed <= 1'b0;
            btn_released <= 1'b0;
        end else begin
            // 同步按键输入
            btn_sync <= {btn_sync[0], btn_n[0]};
            
            // 消抖计数
            if (!btn_sync[1]) begin
                if (debounce_cnt < 20'd100000)  // 约 1ms @ 100MHz
                    debounce_cnt <= debounce_cnt + 20'd1;
                else if (!btn_pressed)
                    btn_pressed <= 1'b1;
            end else begin
                debounce_cnt <= 20'd0;
                btn_pressed <= 1'b0;
            end
            
            // 释放检测
            btn_released <= btn_pressed && !btn_sync[1];
        end
    end
    
    //========================================================================
    // 状态机
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= ST_INIT;
            ddr3_error <= 1'b0;
            video_in_error <= 1'b0;
            video_out_error <= 1'b0;
        end else begin
            case (state_reg)
                ST_INIT: begin
                    // 初始状态，等待 DDR3 校准
                    if (ddr3_calib_done)
                        state_reg <= ST_RUNNING;
                    else
                        state_reg <= ST_DDR3_INIT;
                end
                
                ST_DDR3_INIT: begin
                    // DDR3 初始化中
                    if (ddr3_calib_done)
                        state_reg <= ST_RUNNING;
                    else if (debounce_cnt == 20'd100000)  // 超时检测
                        ddr3_error <= 1'b1;
                end
                
                ST_VIDEO_IN: begin
                    // 视频输入检测
                    if (vid_in_active)
                        state_reg <= ST_RUNNING;
                end
                
                ST_VIDEO_OUT: begin
                    // 视频输出检测
                    if (vid_out_active)
                        state_reg <= ST_RUNNING;
                end
                
                ST_RUNNING: begin
                    // 正常运行状态
                    if (!ddr3_calib_done)
                        state_reg <= ST_DDR3_INIT;
                    else if (!vid_in_active)
                        state_reg <= ST_VIDEO_IN;
                    else if (!vid_out_active)
                        state_reg <= ST_VIDEO_OUT;
                end
                
                ST_ERROR: begin
                    // 错误状态
                    if (rst_n && !ddr3_error && !video_in_error && !video_out_error)
                        state_reg <= ST_INIT;
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
                
                ST_DDR3_INIT: begin
                    // LED0 闪烁表示 DDR3 初始化中
                    led_reg <= {7'd0, blink_slow};
                end

                ST_VIDEO_IN: begin
                    led_reg <= 8'b00000100;  // LED2 亮
                end

                ST_VIDEO_OUT: begin
                    led_reg <= 8'b00001000;  // LED3 亮
                end

                ST_RUNNING: begin
                    // 正常运行：根据状态显示
                    led_reg <= {
                        !vid_out_active,      // LED7: 视频输出状态
                        !vid_in_active,       // LED6: 视频输入状态
                        !flash_ready,         // LED5: Flash 状态
                        ddr3_calib_done,      // LED4: DDR3 就绪
                        vid_out_active,       // LED3: 视频输出正常
                        vid_in_active,        // LED2: 视频输入正常
                        ddr3_calib_done,      // LED1: DDR3 正常
                        1'b1                  // LED0: 电源/运行指示
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
