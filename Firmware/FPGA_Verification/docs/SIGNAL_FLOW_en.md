# VIDEO_CONVERTER FPGA Project - Signal Flow Description

## Correct Signal Flow Understanding

### System Architecture

```
                    HDMI Input Interface
                         │
                         ▼
              ┌─────────────────────┐
              │   TMDS Differential │  ← Not connected to FPGA
              │ (3 data + 1 clock)  │
              └─────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   U2 - TFP401A      │  ← HDMI Receiver
              │   (TMDS Decoder)    │
              └─────────────────────┘
                         │
                         ▼ 24-bit RGB + DE/HS/VS/PCLK
              ┌─────────────────────┐
              │      FPGA (U8)      │  ← Process parallel digital video data
              │  XC6SLX45-3FGG484I  │     (Not TMDS signals!)
              └─────────────────────┘
                         │
                         ▼ 24-bit RGB + DE/HS/VS/PCLK
              ┌─────────────────────┐
              │    U3 - TFP410      │  ← HDMI Transmitter
              │   (TMDS Encoder)    │
              └─────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   TMDS Differential │  ← Not connected to FPGA
              │ (3 data + 1 clock)  │
              └─────────────────────┘
                         │
                         ▼
                    HDMI Output Interface
```

## FPGA Pin Assignment Summary

### Video Input (TFP401A → FPGA)

| Signal | Pin Count | FPGA Pins | Description |
|------|--------|-----------|------|
| tfp401_dvi_d[0:7] | 8 | C5,A5,D6,C6,A6,B6,C7,A7 | Blue Channel |
| tfp401_dvi_d[8:15] | 8 | D7,D8,A8,B8,C8,A9,C9,D9 | Green Channel |
| tfp401_dvi_d[16:23] | 8 | C14,B14,A14,D15,C15,A15,E16,C16 | Red Channel |
| tfp401_de | 1 | C17 | Data Enable |
| tfp401_hs | 1 | A18 | Horizontal Sync |
| tfp401_vs | 1 | B18 | Vertical Sync |
| tfp401_pclk | 1 | B10 | Pixel Clock |
| **Total** | **27** | | |

### Video Output (FPGA → TFP410)

| Signal | Pin Count | FPGA Pins | Description |
|------|--------|-----------|------|
| tfp410_dvi_d[0:7] | 8 | W10,T11,R11,T12,U12,Y12,V13,T14 | Blue Channel |
| tfp410_dvi_d[8:15] | 8 | W14,AB14,Y14,W15,AB15,T16,Y16,AB16 | Green Channel |
| tfp410_dvi_d[16:23] | 8 | AA16,Y17,AB17,V18,W18,AB18,AA18,AB19 | Red Channel |
| tfp410_de | 1 | Y11 | Data Enable |
| tfp410_hs | 1 | Y10 | Horizontal Sync |
| tfp410_vs | 1 | AA10 | Vertical Sync |
| tfp410_pclk | 1 | AB12 | Pixel Clock |
| **Total** | **27** | | |

### Other Interfaces

| Interface | Signal Count | Description |
|------|--------|------|
| Clock | 2 | 50MHz (AA12), 27MHz (AB13) |
| Reset | 1 | rst_n (T6) |
| SPI Flash | 6 | flash_cs/clk/mosi/miso/wp/hold |
| UART | 2 | uart_tx (V17), uart_rx (R15) |
| ADV7125 | 33 | RGB data + clock + control |
| ADV7393 | 20 | Video data + clock + control |
| Buttons | 3 | btn_n[0:2] |
| LED | 1 | led[0] |
| JTAG | 4 | TCK/TDI/TDO/TMS |
| I2C | 4 | DVI/HDMI I2C |

## Important Notes

### ❌ Wrong Understanding
- TMDS differential signals directly connect to FPGA
- FPGA processes TMDS encoding/decoding

### ✅ Correct Understanding
- **TMDS differential signals do not connect to FPGA**
- **TFP401A decodes TMDS to parallel RGB data**
- **TFP410 encodes parallel RGB data to TMDS**
- **FPGA only processes parallel digital video data (24-bit RGB + sync signals)**

## Video Data Format

### TFP401A Output to FPGA

```
tfp401_dvi_d[23:16] - Red Data (R7-R0)
tfp401_dvi_d[15:8]  - Green Data (G7-G0)
tfp401_dvi_d[7:0]   - Blue Data (B7-B0)
tfp401_de           - Data Enable (Active High)
tfp401_hs           - Horizontal Sync (Active High)
tfp401_vs           - Vertical Sync (Active High)
tfp401_pclk         - Pixel Clock (Rising Edge Sample)
```

### FPGA Output to TFP410

```
tfp410_dvi_d[23:16] - Red Data (R7-R0)
tfp410_dvi_d[15:8]  - Green Data (G7-G0)
tfp410_dvi_d[7:0]   - Blue Data (B7-B0)
tfp410_de           - Data Enable (Active High)
tfp410_hs           - Horizontal Sync (Active High)
tfp410_vs           - Vertical Sync (Active High)
tfp410_pclk         - Pixel Clock (Rising Edge Sample)
```

## Modified Files

1. `src/top/video_converter_top.v` - Removed TMDS differential ports
2. `constraints/video_converter.ucf` - Removed TMDS constraints

## Supported Video Formats

| Format | Resolution | Refresh Rate | Pixel Clock |
|------|--------|--------|----------|
| VGA | 640x480 | 60Hz | 25.175 MHz |
| SVGA | 800x600 | 60Hz | 40.000 MHz |
| XGA | 1024x768 | 60Hz | 65.000 MHz |
| 720p | 1280x720 | 60Hz | 74.250 MHz |
| 1080p | 1920x1080 | 60Hz | 148.500 MHz |

## References

- TFP401A Datasheet: https://www.ti.com/product/TFP401A
- TFP410 Datasheet: https://www.ti.com/product/TFP410
- Spartan-6 Datasheet: https://www.xilinx.com/products/silicon-devices/fpga/spartan-6.html
