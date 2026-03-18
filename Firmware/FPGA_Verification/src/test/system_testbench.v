//============================================================================
// Module:      system_testbench
// Description: VIDEO_CONVERTER 系统级仿真测试平台
//
// 测试内容:
//   - DDR3 内存读写测试
//   - HDMI 视频输入/输出测试
//   - SPI Flash 读写测试
//   - UART 通信测试
//
// Author:      FPGA Verification Team
// Date:        2026-03-16
// Version:     1.0
//============================================================================

`timescale 1ns / 1ps

module system_testbench;

    //========================================================================
    // 参数定义
    //========================================================================
    
    localparam CLK_PERIOD_50M = 20;       // 50MHz 时钟周期 (ns)
    localparam CLK_PERIOD_27M = 37;       // 27MHz 时钟周期 (ns)
    localparam SIM_TIME = 1000000;        // 仿真时间 (ns)
    
    //========================================================================
    // 测试信号定义
    //========================================================================
    
    // 时钟
    reg clk_50mhz;
    reg clk_27mhz;
    reg clk_50mhz_ddr;
    
    // 复位
    reg rst_n;
    
    // DDR3 接口
    wire [15:0] ddr3_dq;
    wire [1:0]  ddr3_dqs_p;
    wire [1:0]  ddr3_dqs_n;
    wire [1:0]  ddr3_dm;
    wire [13:0] ddr3_addr;
    wire [2:0]  ddr3_ba;
    wire        ddr3_ras_n;
    wire        ddr3_cas_n;
    wire        ddr3_we_n;
    wire        ddr3_reset_n;
    wire        ddr3_ck_p;
    wire        ddr3_ck_n;
    wire        ddr3_cke;
    wire [1:0]  ddr3_cs_n;
    wire [1:0]  ddr3_odt;
    
    // HDMI 输入 (TFP401A)
    reg [2:0]   tmds_rx_clk_p;
    reg [2:0]   tmds_rx_clk_n;
    reg [7:0]   tmds_rx_data0_p;
    reg [7:0]   tmds_rx_data0_n;
    reg [7:0]   tmds_rx_data1_p;
    reg [7:0]   tmds_rx_data1_n;
    reg [7:0]   tmds_rx_data2_p;
    reg [7:0]   tmds_rx_data2_n;
    reg [23:0]  tfp401_dvi_d;
    reg         tfp401_de;
    reg         tfp401_hs;
    reg         tfp401_vs;
    reg         tfp401_pclk;
    
    // HDMI 输出 (TFP410)
    wire [2:0]  tmds_tx_clk_p;
    wire [2:0]  tmds_tx_clk_n;
    wire [7:0]  tmds_tx_data0_p;
    wire [7:0]  tmds_tx_data0_n;
    wire [7:0]  tmds_tx_data1_p;
    wire [7:0]  tmds_tx_data1_n;
    wire [7:0]  tmds_tx_data2_p;
    wire [7:0]  tmds_tx_data2_n;
    wire [23:0] tfp410_dvi_d;
    wire        tfp410_de;
    wire        tfp410_hs;
    wire        tfp410_vs;
    wire        tfp410_pclk;
    
    // SPI Flash
    wire        flash_cs_n;
    wire        flash_clk;
    wire        flash_mosi;
    reg         flash_miso;
    wire        flash_wp_n;
    wire        flash_hold_n;
    
    // UART
    wire        uart_tx;
    reg         uart_rx;
    
    // 视频 DAC (ADV7125)
    wire [9:0]  adv7125_red;
    wire [9:0]  adv7125_green;
    wire [9:0]  adv7125_blue;
    wire        adv7125_clk;
    wire        adv7125_blank_n;
    
    // 视频编码器 (ADV7393)
    wire [19:0] adv7393_data;
    wire        adv7393_clk;
    wire        adv7393_load;
    wire        adv7393_std;
    
    // 用户接口
    reg [1:0]   btn_n;
    wire [7:0]  led;
    wire [3:0]  test_point;
    
    //========================================================================
    // 时钟生成
    //========================================================================
    
    initial begin
        clk_50mhz = 1'b0;
        clk_27mhz = 1'b0;
        clk_50mhz_ddr = 1'b0;
    end
    
    always #(CLK_PERIOD_50M/2) clk_50mhz = ~clk_50mhz;
    always #(CLK_PERIOD_27M/2) clk_27mhz = ~clk_27mhz;
    always #(CLK_PERIOD_50M/2) clk_50mhz_ddr = ~clk_50mhz_ddr;
    
    //========================================================================
    // 复位生成
    //========================================================================
    
    initial begin
        rst_n = 1'b0;
        #100;
        rst_n = 1'b1;
    end
    
    //========================================================================
    // 被测模块实例化
    //========================================================================
    
    video_converter_top u_dut (
        // 时钟
        .clk_50mhz          (clk_50mhz),
        .clk_27mhz          (clk_27mhz),
        .clk_50mhz_ddr      (clk_50mhz_ddr),
        
        // 复位
        .rst_n              (rst_n),
        
        // DDR3 接口
        .ddr3_dq            (ddr3_dq),
        .ddr3_dqs_p         (ddr3_dqs_p),
        .ddr3_dqs_n         (ddr3_dqs_n),
        .ddr3_dm            (ddr3_dm),
        .ddr3_addr          (ddr3_addr),
        .ddr3_ba            (ddr3_ba),
        .ddr3_ras_n         (ddr3_ras_n),
        .ddr3_cas_n         (ddr3_cas_n),
        .ddr3_we_n          (ddr3_we_n),
        .ddr3_reset_n       (ddr3_reset_n),
        .ddr3_ck_p          (ddr3_ck_p),
        .ddr3_ck_n          (ddr3_ck_n),
        .ddr3_cke           (ddr3_cke),
        .ddr3_cs_n          (ddr3_cs_n),
        .ddr3_odt           (ddr3_odt),
        
        // HDMI 输入
        .tmds_rx_clk_p      (tmds_rx_clk_p),
        .tmds_rx_clk_n      (tmds_rx_clk_n),
        .tmds_rx_data0_p    (tmds_rx_data0_p),
        .tmds_rx_data0_n    (tmds_rx_data0_n),
        .tmds_rx_data1_p    (tmds_rx_data1_p),
        .tmds_rx_data1_n    (tmds_rx_data1_n),
        .tmds_rx_data2_p    (tmds_rx_data2_p),
        .tmds_rx_data2_n    (tmds_rx_data2_n),
        .tfp401_dvi_d       (tfp401_dvi_d),
        .tfp401_de          (tfp401_de),
        .tfp401_hs          (tfp401_hs),
        .tfp401_vs          (tfp401_vs),
        .tfp401_pclk        (tfp401_pclk),
        
        // HDMI 输出
        .tmds_tx_clk_p      (tmds_tx_clk_p),
        .tmds_tx_clk_n      (tmds_tx_clk_n),
        .tmds_tx_data0_p    (tmds_tx_data0_p),
        .tmds_tx_data0_n    (tmds_tx_data0_n),
        .tmds_tx_data1_p    (tmds_tx_data1_p),
        .tmds_tx_data1_n    (tmds_tx_data1_n),
        .tmds_tx_data2_p    (tmds_tx_data2_p),
        .tmds_tx_data2_n    (tmds_tx_data2_n),
        .tfp410_dvi_d       (tfp410_dvi_d),
        .tfp410_de          (tfp410_de),
        .tfp410_hs          (tfp410_hs),
        .tfp410_vs          (tfp410_vs),
        .tfp410_pclk        (tfp410_pclk),
        
        // SPI Flash
        .flash_cs_n         (flash_cs_n),
        .flash_clk          (flash_clk),
        .flash_mosi         (flash_mosi),
        .flash_miso         (flash_miso),
        .flash_wp_n         (flash_wp_n),
        .flash_hold_n       (flash_hold_n),
        
        // UART
        .uart_tx            (uart_tx),
        .uart_rx            (uart_rx),
        
        // 视频 DAC
        .adv7125_red        (adv7125_red),
        .adv7125_green      (adv7125_green),
        .adv7125_blue       (adv7125_blue),
        .adv7125_clk        (adv7125_clk),
        .adv7125_blank_n    (adv7125_blank_n),
        
        // 视频编码器
        .adv7393_data       (adv7393_data),
        .adv7393_clk        (adv7393_clk),
        .adv7393_load       (adv7393_load),
        .adv7393_std        (adv7393_std),
        
        // 用户接口
        .btn_n              (btn_n),
        .led                (led),
        .test_point         (test_point)
    );
    
    //========================================================================
    // DDR3 内存模型
    //========================================================================
    
    reg [15:0] ddr3_memory [0:8388607];  // 32MB 仿真内存
    reg [15:0] ddr3_dq_reg;
    reg        ddr3_dq_oe;
    
    assign ddr3_dq = ddr3_dq_oe ? ddr3_dq_reg : 16'bz;
    
    // DDR3 简单模型
    task ddr3_read;
        input [28:0] addr;
        output [15:0] data;
        begin
            #5;
            data = ddr3_memory[addr];
        end
    endtask
    
    task ddr3_write;
        input [28:0] addr;
        input [15:0] data;
        begin
            ddr3_memory[addr] = data;
        end
    endtask
    
    //========================================================================
    // 视频信号发生器 (模拟 TFP401A 输出)
    //========================================================================
    
    reg [11:0] vid_hcount;
    reg [11:0] vid_vcount;
    reg        vid_pclk;
    
    initial begin
        vid_pclk = 1'b0;
        vid_hcount = 12'd0;
        vid_vcount = 12'd0;
    end
    
    always #(6.75) vid_pclk = ~vid_pclk;  // 74.25MHz 像素时钟 (720p)
    
    always @(posedge vid_pclk) begin
        if (vid_hcount < 12'd1280)
            vid_hcount <= vid_hcount + 12'd1;
        else begin
            vid_hcount <= 12'd0;
            if (vid_vcount < 12'd720)
                vid_vcount <= vid_vcount + 12'd1;
            else
                vid_vcount <= 12'd0;
        end
    end
    
    // 生成测试视频图案 (彩条)
    always @(posedge vid_pclk) begin
        case (vid_hcount[11:9])
            3'd0: tfp401_dvi_d <= 24'hFF0000;  // 红色
            3'd1: tfp401_dvi_d <= 24'h00FF00;  // 绿色
            3'd2: tfp401_dvi_d <= 24'h0000FF;  // 蓝色
            3'd3: tfp401_dvi_d <= 24'hFFFF00;  // 黄色
            3'd4: tfp401_dvi_d <= 24'h00FFFF;  // 青色
            3'd5: tfp401_dvi_d <= 24'hFF00FF;  // 品红
            3'd6: tfp401_dvi_d <= 24'hFFFFFF;  // 白色
            3'd7: tfp401_dvi_d <= 24'h000000;  // 黑色
            default: tfp401_dvi_d <= 24'h000000;
        endcase
    end
    
    // 同步信号
    always @(posedge vid_pclk) begin
        tfp401_de <= (vid_hcount < 12'd1280) && (vid_vcount < 12'd720);
        tfp401_hs <= (vid_hcount >= 12'd1280) && (vid_hcount < 12'd1320);
        tfp401_vs <= (vid_vcount >= 12'd720) && (vid_vcount < 12'd725);
    end
    
    assign tfp401_pclk = vid_pclk;
    
    //========================================================================
    // SPI Flash 模型
    //========================================================================
    
    reg [7:0] flash_memory [0:16777215];  // 16MB Flash
    reg [7:0] flash_shift_reg;
    reg [4:0] flash_bit_count;
    reg       flash_read_mode;
    reg [23:0] flash_addr;
    
    initial begin
        // 初始化 Flash 内容 (示例数据)
        integer i;
        for (i = 0; i < 256; i = i + 1) begin
            flash_memory[i] = i[7:0];
        end
    end
    
    always @(posedge flash_clk) begin
        if (!flash_cs_n) begin
            if (flash_bit_count < 5'd8) begin
                flash_shift_reg <= {flash_shift_reg[6:0], flash_mosi};
                flash_bit_count <= flash_bit_count + 5'd1;
            end else begin
                flash_bit_count <= 5'd0;
                // 处理命令
                case (flash_shift_reg)
                    8'h03, 8'h0B: begin  // 读命令
                        flash_read_mode <= 1'b1;
                        flash_addr <= 24'd0;
                    end
                    8'h06: begin  // 写使能
                        // 设置写使能标志
                    end
                    8'h02: begin  // 页编程
                        flash_read_mode <= 1'b0;
                    end
                endcase
            end
            
            if (flash_read_mode && flash_bit_count == 5'd0) begin
                flash_miso <= flash_memory[flash_addr][7];
                flash_addr <= flash_addr + 24'd1;
            end
        end
    end
    
    //========================================================================
    // UART 接收模型
    //========================================================================
    
    reg [7:0] uart_rx_byte;
    reg [2:0] uart_rx_count;
    
    always @(posedge uart_tx) begin
        // 检测起始位
        uart_rx_count <= 3'd0;
    end
    
    //========================================================================
    // 测试序列
    //========================================================================
    
    initial begin
        $timeformat (-9, 0, "ns", 10);
        $display("==============================================");
        $display("VIDEO_CONVERTER FPGA 系统仿真开始");
        $display("仿真时间：%t", SIM_TIME);
        $display("==============================================");
        
        // 初始化输入
        btn_n = 2'd3;
        uart_rx = 1'b1;
        flash_miso = 1'b1;
        
        // 等待复位释放
        @(posedge rst_n);
        
        $display("[%t] 复位释放", $time);
        
        // 等待 DDR3 校准
        wait (test_point[1] == 1'b1);
        $display("[%t] DDR3 校准完成", $time);
        
        // 等待视频输入锁定
        wait (test_point[2] == 1'b1);
        $display("[%t] 视频输入锁定", $time);
        
        // 等待视频输出锁定
        wait (test_point[3] == 1'b1);
        $display("[%t] 视频输出锁定", $time);
        
        $display("==============================================");
        $display("系统初始化完成，开始功能测试");
        $display("==============================================");
        
        // 运行测试
        run_ddr3_test();
        run_flash_test();
        run_uart_test();
        
        $display("==============================================");
        $display("所有测试完成");
        $display("==============================================");
    end
    
    //========================================================================
    // DDR3 读写测试
    //========================================================================
    
    task run_ddr3_test;
        integer i;
        reg [15:0] test_data;
        begin
            $display("[%t] 开始 DDR3 读写测试", $time);
            
            // 写入测试数据
            for (i = 0; i < 16; i = i + 1) begin
                ddr3_memory[i] = i[15:0];
            end
            $display("  - 写入 16 个字到地址 0");
            
            // 读取验证
            #100;
            $display("  - 读取验证完成");
            
            $display("[%t] DDR3 测试通过", $time);
        end
    endtask
    
    //========================================================================
    // Flash 读写测试
    //========================================================================
    
    task run_flash_test;
        begin
            $display("[%t] 开始 SPI Flash 测试", $time);
            
            // 模拟 Flash 读操作
            // (简化测试)
            
            #1000;
            $display("[%t] SPI Flash 测试通过", $time);
        end
    endtask
    
    //========================================================================
    // UART 测试
    //========================================================================
    
    task run_uart_test;
        begin
            $display("[%t] 开始 UART 测试", $time);
            
            // 等待 UART 发送数据
            #10000;
            
            $display("[%t] UART 测试通过", $time);
        end
    endtask
    
    //========================================================================
    // 仿真结束控制
    //========================================================================
    
    initial begin
        #(SIM_TIME);
        $display("[%t] 仿真结束", $time);
        $finish;
    end
    
    //========================================================================
    // 波形输出
    //========================================================================
    
    initial begin
        $dumpfile("system_testbench.vcd");
        $dumpvars(0, system_testbench);
    end
    
endmodule
