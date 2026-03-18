//============================================================================
// Module:      video_frame_buffer
// Description: 视频帧缓冲控制器 (使用 DDR3 作为帧缓存)
//
// 功能:
//   - 将输入视频帧写入 DDR3
//   - 从 DDR3 读取视频帧输出
//   - 支持帧率转换
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module video_frame_buffer (
    //========================================================================
    // 系统接口
    //========================================================================
    input           clk,                  // 系统时钟
    input           rst_n,                // 异步复位 (低有效)
    
    //========================================================================
    // 写入端口 (来自视频输入)
    //========================================================================
    input   [23:0]  wr_data,              // 写入数据 (RGB888)
    input           wr_en,                // 写入使能 (DE 信号)
    input           wr_hs,                // 行同步
    input           wr_vs,                // 场同步
    
    //========================================================================
    // 读取端口 (去往视频输出)
    //========================================================================
    output  [23:0]  rd_data,              // 读取数据
    input           rd_en,                // 读取使能
    input           rd_hs,                // 行同步
    input           rd_vs,                // 场同步
    
    //========================================================================
    // DDR3 接口
    //========================================================================
    output  [15:0]  ddr3_wr_data,         // DDR3 写入数据
    input   [15:0]  ddr3_rd_data,         // DDR3 读取数据
    output  [28:0]  ddr3_wr_addr,         // DDR3 写入地址
    output  [28:0]  ddr3_rd_addr,         // DDR3 读取地址
    output          ddr3_wr_en,           // DDR3 写使能
    output          ddr3_rd_en,           // DDR3 读使能
    output  [2:0]   ddr3_cmd,             // DDR3 命令
    input           ddr3_rdy,             // DDR3 就绪
    input           ddr3_wdf_rdy          // DDR3 写数据就绪
    
);

    //========================================================================
    // 参数定义
    //========================================================================
    
    // 帧缓冲区地址分配 (假设 1280x720 RGB888)
    // 每帧大小：1280 * 720 * 3 = 2,764,800 字节 = 1,382,400 字 (16 位)
    // 使用双缓冲：Buffer A (0x000000-0x14FFFF), Buffer B (0x150000-0x29FFFF)
    
    localparam [28:0] BUFFER_A_ADDR = 29'd0;
    localparam [28:0] BUFFER_B_ADDR = 29'd1400000;  // 约 1.38M 字
    
    // 视频分辨率 (720p)
    localparam [11:0] H_ACTIVE = 12'd1280;
    localparam [11:0] V_ACTIVE = 12'd720;
    
    //========================================================================
    // 内部信号定义
    //========================================================================
    
    // 写入地址计数器
    reg [28:0] wr_addr;
    reg [11:0] wr_hcount;
    reg [11:0] wr_vcount;
    reg        wr_buffer_sel;
    
    // 读取地址计数器
    reg [28:0] rd_addr;
    reg [11:0] rd_hcount;
    reg [11:0] rd_vcount;
    reg        rd_buffer_sel;
    
    // 数据缓冲
    reg [23:0] rd_data_reg;
    reg [15:0] ddr3_rd_data_delay;
    
    // 写入状态
    reg        wr_active;
    reg        wr_frame_toggle;
    
    // 读取状态
    reg        rd_active;
    reg        rd_frame_toggle;
    
    // DDR3 命令
    localparam CMD_NOP   = 3'd0;
    localparam CMD_READ  = 3'd1;
    localparam CMD_WRITE = 3'd2;
    
    reg [2:0] ddr3_cmd_reg;
    reg [28:0] ddr3_addr_reg;
    reg [15:0] ddr3_data_reg;
    reg        ddr3_wr_en_reg;
    reg        ddr3_rd_en_reg;
    
    //========================================================================
    // 写入逻辑 (视频输入 -> DDR3)
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_hcount <= 12'd0;
            wr_vcount <= 12'd0;
            wr_addr <= BUFFER_A_ADDR;
            wr_active <= 1'b0;
        end else begin
            if (wr_en) begin
                if (wr_hcount < H_ACTIVE - 12'd1) begin
                    wr_hcount <= wr_hcount + 12'd1;
                end else begin
                    wr_hcount <= 12'd0;
                    if (wr_vcount < V_ACTIVE - 12'd1)
                        wr_vcount <= wr_vcount + 12'd1;
                    else
                        wr_vcount <= 12'd0;
                end
                
                // 计算写入地址
                wr_addr <= BUFFER_A_ADDR + (wr_vcount * H_ACTIVE + wr_hcount) * 3'd2;
                
                wr_active <= 1'b1;
            end else begin
                wr_active <= 1'b0;
            end
            
            // 帧切换 (在 VS 下降沿)
            if (!wr_vs && wr_vcount > 0)
                wr_frame_toggle <= ~wr_frame_toggle;
        end
    end
    
    // 选择写入缓冲区
    assign wr_buffer_sel = wr_frame_toggle;
    
    // DDR3 写入数据打包 (24 位 RGB -> 16 位总线)
    // 使用两个时钟周期写入一个像素
    reg [1:0] wr_cycle;
    reg [23:0] wr_data_delay;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_cycle <= 2'd0;
            wr_data_delay <= 24'd0;
        end else begin
            wr_data_delay <= wr_data;
            
            if (wr_en && ddr3_wdf_rdy) begin
                if (wr_cycle == 2'd0) begin
                    // 第一周期：写入 R[7:0] + G[7:6]
                    ddr3_data_reg <= {wr_data[15:8], wr_data[23:16]};
                    wr_cycle <= 2'd1;
                end else if (wr_cycle == 2'd1) begin
                    // 第二周期：写入 G[5:0] + B[7:0]
                    ddr3_data_reg <= {wr_data_delay[7:0], wr_data_delay[15:14]};
                    wr_cycle <= 2'd2;
                end else if (wr_cycle == 2'd2) begin
                    // 第三周期：写入 B[5:0] + 填充
                    ddr3_data_reg <= {6'd0, wr_data_delay[13:6]};
                    wr_cycle <= 2'd0;
                end
            end
        end
    end
    
    assign ddr3_wr_data = ddr3_data_reg;
    assign ddr3_wr_addr = wr_addr + wr_cycle[0];
    assign ddr3_wr_en = wr_en && (wr_cycle == 2'd0 || wr_cycle == 2'd1);
    
    //========================================================================
    // 读取逻辑 (DDR3 -> 视频输出)
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_hcount <= 12'd0;
            rd_vcount <= 12'd0;
            rd_addr <= BUFFER_B_ADDR;
            rd_active <= 1'b0;
        end else begin
            if (rd_en) begin
                if (rd_hcount < H_ACTIVE - 12'd1) begin
                    rd_hcount <= rd_hcount + 12'd1;
                end else begin
                    rd_hcount <= 12'd0;
                    if (rd_vcount < V_ACTIVE - 12'd1)
                        rd_vcount <= rd_vcount + 12'd1;
                    else
                        rd_vcount <= 12'd0;
                end
                
                // 计算读取地址
                rd_addr <= BUFFER_B_ADDR + (rd_vcount * H_ACTIVE + rd_hcount) * 3'd2;
                
                rd_active <= 1'b1;
            end else begin
                rd_active <= 1'b0;
            end
            
            // 帧切换
            if (!rd_vs && rd_vcount > 0)
                rd_frame_toggle <= ~rd_frame_toggle;
        end
    end
    
    // 选择读取缓冲区
    assign rd_buffer_sel = rd_frame_toggle;
    
    // DDR3 读取数据解包
    reg [1:0] rd_cycle;
    reg [23:0] pixel_buf;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_cycle <= 2'd0;
            pixel_buf <= 24'd0;
            rd_data_reg <= 24'd0;
        end else begin
            if (rd_en && ddr3_rdy) begin
                if (rd_cycle == 2'd0) begin
                    // 第一周期：读取 R[7:0] + G[7:6]
                    pixel_buf[23:16] <= ddr3_rd_data[15:8];
                    pixel_buf[15:14] <= ddr3_rd_data[7:6];
                    rd_cycle <= 2'd1;
                end else if (rd_cycle == 2'd1) begin
                    // 第二周期：读取 G[5:0] + B[7:0]
                    pixel_buf[13:8] <= ddr3_rd_data[15:10];
                    pixel_buf[7:0] <= ddr3_rd_data[9:2];
                    rd_cycle <= 2'd2;
                end else if (rd_cycle == 2'd2) begin
                    // 第三周期：读取 B[5:0] + 填充
                    pixel_buf[5:0] <= ddr3_rd_data[15:10];
                    rd_data_reg <= pixel_buf;
                    rd_cycle <= 2'd0;
                end
            end
        end
    end
    
    assign rd_data = rd_data_reg;
    assign ddr3_rd_addr = rd_addr + rd_cycle[0];
    assign ddr3_rd_en = rd_en && (rd_cycle == 2'd0);
    
    //========================================================================
    // DDR3 命令输出
    //========================================================================
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ddr3_cmd_reg <= CMD_NOP;
            ddr3_addr_reg <= 29'd0;
        end else begin
            if (ddr3_wr_en && ddr3_wdf_rdy) begin
                ddr3_cmd_reg <= CMD_WRITE;
                ddr3_addr_reg <= ddr3_wr_addr;
            end else if (ddr3_rd_en && ddr3_rdy) begin
                ddr3_cmd_reg <= CMD_READ;
                ddr3_addr_reg <= ddr3_rd_addr;
            end else begin
                ddr3_cmd_reg <= CMD_NOP;
            end
        end
    end
    
    assign ddr3_cmd = ddr3_cmd_reg;
    assign ddr3_wr_addr = ddr3_addr_reg;
    assign ddr3_rd_addr = ddr3_addr_reg;
    
endmodule
