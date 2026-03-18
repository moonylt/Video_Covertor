//============================================================================
// Module:      video_input_tf401a
// Description: TFP401A DVI/HDMI 接收器接口模块
//
// TFP401A 功能:
//   - 接收 TMDS 差分信号
//   - 解码为 24 位 RGB 并行数据
//   - 输出 DE, HS, VS 同步信号
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

module video_input_tf401a (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 异步复位 (低有效)
    
    //========================================================================
    // TFP401A 并行接口
    //========================================================================
    input   [23:0]  dvi_d,                // 24 位 RGB 数据 (RGB888)
    input           de,                   // 数据使能 (Data Enable)
    input           hs,                   // 行同步 (Horizontal Sync)
    input           vs,                   // 场同步 (Vertical Sync)
    input           pclk,                 // 像素时钟
    
    //========================================================================
    // 内部视频流输出
    //========================================================================
    output  reg [23:0] vid_data,          // 同步后的视频数据
    output  reg        vid_de,            // 同步后的 DE
    output  reg        vid_hs,            // 同步后的 HS
    output  reg        vid_vs,            // 同步后的 VS
    output             vid_active         // 视频有效指示
    
);

    //========================================================================
    // 内部信号定义
    //========================================================================
    
    // 同步寄存器
    reg [2:0] de_sync;
    reg [2:0] hs_sync;
    reg [2:0] vs_sync;
    
    // 数据延迟寄存器
    reg [23:0] dvi_d_delay1;
    reg [23:0] dvi_d_delay2;
    
    // 视频时序检测
    reg [11:0] hcount;                    // 水平计数器
    reg [11:0] vcount;                    // 垂直计数器
    reg [11:0] hactive;                   // 水平有效像素
    reg [11:0] vactive;                   // 垂直有效行数
    
    // 状态机
    reg [1:0] sync_state;
    localparam SYNC_IDLE   = 2'd0;
    localparam SYNC_DETECT = 2'd1;
    localparam SYNC_LOCKED = 2'd2;
    localparam SYNC_LOST   = 2'd3;
    
    // 同步锁定指示
    wire sync_locked;
    wire sync_stable;
    
    //========================================================================
    // 输入信号同步 (跨时钟域处理)
    //========================================================================
    
    // TFP401A 数据在 pclk 时钟域，需要同步到系统时钟域
    // 假设系统时钟频率 >= 2 倍 pclk
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            de_sync <= 3'd0;
            hs_sync <= 3'd0;
            vs_sync <= 3'd0;
            dvi_d_delay1 <= 24'd0;
            dvi_d_delay2 <= 24'd0;
        end else begin
            // 同步控制信号
            de_sync <= {de_sync[1:0], de};
            hs_sync <= {hs_sync[1:0], hs};
            vs_sync <= {vs_sync[1:0], vs};
            
            // 延迟视频数据以匹配同步信号
            dvi_d_delay1 <= dvi_d;
            dvi_d_delay2 <= dvi_d_delay1;
        end
    end
    
    //========================================================================
    // 视频时序检测模块
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcount <= 12'd0;
            vcount <= 12'd0;
            hactive <= 12'd0;
            vactive <= 12'd0;
        end else begin
            // 水平计数
            if (de_sync[2]) begin
                if (hcount < 12'd4095)
                    hcount <= hcount + 12'd1;
            end else begin
                hcount <= 12'd0;
            end
            
            // 垂直计数 (在 DE 下降沿计数)
            if (!de_sync[2] && de_sync[1]) begin
                if (vcount < 12'd4095)
                    vcount <= vcount + 12'd1;
            end else if (!vs_sync[2]) begin
                vcount <= 12'd0;
            end
            
            // 记录最大有效值
            if (hcount > hactive && de_sync[2])
                hactive <= hcount;
            if (vcount > vactive && !de_sync[2] && de_sync[1])
                vactive <= vcount;
        end
    end
    
    //========================================================================
    // 同步状态机
    //========================================================================
    
    reg [15:0] stable_counter;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_state <= SYNC_IDLE;
            stable_counter <= 16'd0;
        end else begin
            case (sync_state)
                SYNC_IDLE: begin
                    if (de_sync[2] || hs_sync[2] || vs_sync[2])
                        sync_state <= SYNC_DETECT;
                end
                
                SYNC_DETECT: begin
                    if (de_sync[2] && hs_sync[2] && vs_sync[2]) begin
                        if (stable_counter < 16'd65535)
                            stable_counter <= stable_counter + 16'd1;
                        if (stable_counter >= 16'd1000)
                            sync_state <= SYNC_LOCKED;
                    end else begin
                        stable_counter <= 16'd0;
                        sync_state <= SYNC_IDLE;
                    end
                end
                
                SYNC_LOCKED: begin
                    if (!de_sync[2] || !hs_sync[2] || !vs_sync[2]) begin
                        if (stable_counter > 16'd0)
                            stable_counter <= stable_counter - 16'd1;
                        if (stable_counter == 16'd0)
                            sync_state <= SYNC_LOST;
                    end
                end
                
                SYNC_LOST: begin
                    sync_state <= SYNC_IDLE;
                end
            endcase
        end
    end
    
    assign sync_locked = (sync_state == SYNC_LOCKED);
    assign sync_stable = sync_locked;
    
    //========================================================================
    // 视频数据输出 (同步后)
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vid_data <= 24'd0;
            vid_de <= 1'b0;
            vid_hs <= 1'b0;
            vid_vs <= 1'b0;
        end else begin
            // 输出同步后的信号
            vid_de <= de_sync[2];
            vid_hs <= hs_sync[2];
            vid_vs <= vs_sync[2];
            
            // 视频数据在 DE 有效时输出
            if (de_sync[2])
                vid_data <= dvi_d_delay2;
            else
                vid_data <= 24'd0;
        end
    end
    
    assign vid_active = sync_locked;
    
    //========================================================================
    // 调试输出 (可选)
    //========================================================================
    
    // 当前检测到的分辨率信息
    // hactive: 水平有效像素数
    // vactive: 垂直有效行数
    // 例如：1280x720 @ 60Hz
    
endmodule
