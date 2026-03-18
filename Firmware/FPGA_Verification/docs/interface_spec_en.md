# Interface Timing Specification

## 1. DDR3 Memory Interface

### 1.1 Electrical Specifications

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Operating Voltage (VDD) | 1.425 | 1.5 | 1.575 | V |
| Reference Voltage (VREF) | 0.742 | 0.75 | 0.758 | V |
| Input High Voltage (VIH) | VREF+0.1 | - | VDD+0.3 | V |
| Input Low Voltage (VIL) | -0.3 | - | VREF-0.1 | V |

### 1.2 Timing Parameters (800MT/s)

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Clock Cycle | tCK | 2.5 | - | ns |
| DQS to DQ Setup Time | tDS | 170 | - | ps |
| DQS to DQ Hold Time | tDH | 170 | - | ps |
| DQ/DQS Output Setup | tDQSCK | -450 | 450 | ps |
| DQ/DQS Output Hold | tQH | 180 | - | ps |

### 1.3 Initialization Sequence

```
1. Power on wait for VDD stable (>200us)
2. Provide stable clock (>500us)
3. Execute ZQ calibration
4. Execute Write Leveling (WRLVL)
5. Execute Read Leveling
6. Execute 2D Training
7. Calibration complete, enter normal operation mode
```

## 2. HDMI/TMDS Interface

### 2.1 TMDS Electrical Specifications

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Differential Output Swing | 350 | 500 | 650 | mV |
| Common Mode Voltage | 2.9 | 3.3 | 3.7 | V |
| Differential Impedance | 90 | 100 | 110 | Ω |
| Data Rate | 10 | - | 600 | Mbps/ch |

### 2.2 TFP401A Timing

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Pixel Clock Frequency | fPCLK | 10 | 165 | MHz |
| Data Setup Time | tSU | 1.0 | - | ns |
| Data Hold Time | tH | 0.5 | - | ns |
| DE to PCLK Setup | tDESU | 1.0 | - | ns |
| DE to PCLK Hold | tDEH | 0.5 | - | ns |

### 2.3 TFP410 Timing

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Pixel Clock Frequency | fPCLK | 10 | 165 | MHz |
| Data Delay (relative to PCLK) | tPD | - | 3.5 | ns |
| DE/HS/VS Delay | tSYNC | - | 3.5 | ns |

## 3. SPI Flash Interface

### 3.1 Electrical Specifications (W25Q128JV)

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Operating Voltage | 2.7 | 3.3 | 3.6 | V |
| Input High Voltage | 0.7×VCC | - | VCC+0.3 | V |
| Input Low Voltage | -0.3 | - | 0.2×VCC | V |

### 3.2 SPI Timing (Standard Mode)

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Clock Frequency | fCLK | - | 50 | MHz |
| Clock High Time | tCH | 8 | - | ns |
| Clock Low Time | tCL | 8 | - | ns |
| Data Setup Time | tSU | 2 | - | ns |
| Data Hold Time | tH | 4 | - | ns |
| CS Setup Time | tCSH | 20 | - | ns |
| CS Hold Time | tCSL | 20 | - | ns |

### 3.3 Read Data Command Sequence

```
CS# Low:
  [8-bit command: 0x03/0x0B]
  [24-bit address: A23-A0]
  [N-bit data: D7-D0, ...]
CS# High
```

### 3.4 Write Data Command Sequence

```
1. Send Write Enable (0x06)
2. CS# High
3. CS# Low:
   [8-bit command: 0x02]
   [24-bit address: A23-A0]
   [N-bit data: D7-D0, ...]
4. CS# High (trigger internal write)
5. Wait for write complete (typical 5ms)
```

## 4. UART Interface

### 4.1 Electrical Specifications

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Logic High | 2.0 | 3.3 | 3.6 | V |
| Logic Low | 0 | 0 | 0.8 | V |

### 4.2 Baud Rate Configuration

System Clock: 50MHz

| Baud Rate | Divider | Error |
|--------|----------|------|
| 9600 | 5208 | <0.01% |
| 19200 | 2604 | <0.01% |
| 38400 | 1302 | <0.01% |
| 57600 | 868 | <0.01% |
| 115200 | 434 | <0.01% |

### 4.3 Data Format

```
Idle (High) | Start Bit (0) | D0 | D1 | D2 | D3 | D4 | D5 | D6 | D7 | Stop Bit (1) | Idle (High)
```

## 5. Video DAC Interface (ADV7125)

### 5.1 Electrical Specifications

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Operating Voltage | 2.7 | 3.3 | 3.6 | V |
| Output Current | 1.0 | 3.5 | 7.0 | mA |
| Settling Time | - | 1.0 | - | ns |

### 5.2 Timing Parameters

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Pixel Clock Frequency | fPCLK | - | 170 | MHz |
| Data Setup Time | tSU | 1.5 | - | ns |
| Data Hold Time | tH | 0.5 | - | ns |
| BLANK_N Setup | tBSU | 2.0 | - | ns |
| BLANK_N Hold | tBH | 1.0 | - | ns |

## 6. Video Encoder Interface (ADV7393)

### 6.1 Electrical Specifications

| Parameter | Min | Typical | Max | Unit |
|------|--------|--------|--------|------|
| Core Voltage | 1.71 | 1.8 | 1.89 | V |
| IO Voltage | 2.7 | 3.3 | 3.6 | V |

### 6.2 Timing Parameters

| Parameter | Symbol | Min | Max | Unit |
|------|------|--------|--------|------|
| Data Clock Frequency | fCLK | - | 54 | MHz |
| Data Setup Time | tSU | 2.0 | - | ns |
| Data Hold Time | tH | 0.5 | - | ns |
| LOAD Pulse Width | tLW | 10 | - | ns |

## 7. Constraint File Examples

### 7.1 UCF Constraint Snippet

```ucf
# DDR3 Constraints
NET "ddr3_dq[0]"      LOC = N3   | IOSTANDARD = MOBILE_DDR | TERM = NONE;
NET "ddr3_dqs_p[0]"   LOC = P5   | IOSTANDARD = MOBILE_DDR | TERM = NONE;
NET "ddr3_dqs_n[0]"   LOC = N5   | IOSTANDARD = MOBILE_DDR | TERM = NONE;

# TMDS Constraints
NET "tmds_rx_clk_p[0]" LOC = A5  | IOSTANDARD = LVDS_25;
NET "tmds_rx_clk_n[0]" LOC = A6  | IOSTANDARD = LVDS_25;

# SPI Flash Constraints
NET "flash_cs_n"      LOC = J14  | IOSTANDARD = LVCMOS33 | SLEW = FAST | DRIVE = 8;
NET "flash_clk"       LOC = K14  | IOSTANDARD = LVCMOS33 | SLEW = FAST | DRIVE = 8;

# UART Constraints
NET "uart_tx"         LOC = R14  | IOSTANDARD = LVCMOS33 | SLEW = FAST | DRIVE = 8;
NET "uart_rx"         LOC = T14  | IOSTANDARD = LVCMOS33 | PULLUP;
```

### 7.2 Timing Constraint Snippet

```ucf
# Clock Constraints
TIMESPEC "TS_SYS_CLK" = PERIOD "sys_clk" 10.000 ns HIGH 50%;
TIMESPEC "TS_PIXEL_CLK" = PERIOD "pixel_clk" 13.468 ns HIGH 50%;
TIMESPEC "TS_DDR3" = PERIOD "DDR3_CLK" 2.500 ns HIGH 50%;

# Input Delay
NET "tfp401_*" TNM_NET = "GRP_TFP401_IN";
TIMESPEC "TS_IN_TFP401" = FROM "GRP_TFP401_IN" TO FFS 2.0 ns;

# Output Delay
NET "tfp410_*" TNM_NET = "GRP_TFP410_OUT";
TIMESPEC "TS_OUT_TFP410" = FROM FFS TO "GRP_TFP410_OUT" 2.0 ns;
```

## 8. Version History

| Version | Date | Author | Change Description |
|------|------|------|----------|
| 1.0 | 2026-03-16 | FPGA Team | Initial version |
