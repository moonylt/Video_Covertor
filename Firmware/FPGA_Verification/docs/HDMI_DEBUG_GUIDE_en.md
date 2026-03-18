# HDMI Hardware Debug Guide

## Debug Purpose
Quickly determine if the TFP410 HDMI output module is working correctly and locate the source of issues.

---

## I. Debug Steps

### Step 1: Check PLL Lock Status
**Observe LED[3]**
- ✅ **LED[3] ON** = PLL locked, clock normal
- ❌ **LED[3] OFF** = PLL not locked, check crystal and PLL configuration

### Step 2: Check HDMI Data Generation
**Observe LED[4]**
- ✅ **LED[4] ON/Blinking** = HDMI data is outputting
- ❌ **LED[4] OFF** = No data output, check test pattern generator

### Step 3: Switch Test Pattern
**Press BTN[0] button**, observe LED[0:2] and display changes:

| Mode | LED[2:0] | Test Pattern | Expected Display |
|------|----------|----------|------------|
| 0    | 000      | Full White     | White screen   |
| 1    | 001      | Full Red       | Red screen   |
| 2    | 010      | Full Green     | Green screen   |
| 3    | 011      | Full Blue      | Blue screen   |
| 4    | 100      | 8-Color Bar  | Color vertical stripes |
| 5    | 101      | Grid     | White grid   |

### Step 4: Measure Key Signals
Use oscilloscope/logic analyzer to measure:

| Test Point | Signal | Expected Value | Multimeter/Oscilloscope Measurement |
|--------|------|--------|------------------|
| TP0    | PLL_LOCK | High level (3.3V) | DC voltage |
| TP1    | PCLK | 74.25MHz square wave | Frequency counter/oscilloscope |
| TP2    | ACTIVE | Pulse signal | Oscilloscope |
| TP3    | DE | Pulse signal | Oscilloscope |

---

## II. Problem Diagnosis Flow

```
┌─────────────────────────────────────────┐
│  Start Diagnosis                        │
└─────────────────┬───────────────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │ Is LED[3] ON?       │
        │ (PLL lock indicator)│
        └─────────┬───────────┘
                  │
         ┌────────┴────────┐
         │ NO              │ YES
         ▼                 ▼
   ┌───────────┐     ┌─────────────────┐
   │ Check     │     │ Is LED[4] ON?   │
   │ Clock     │     │ (Data output    │
   │ Check     │     │  indicator)     │
   │ Reset     │     └────────┬────────┘
   └───────────┘              │
                       ┌──────┴──────┐
                       │ NO          │ YES
                       ▼             ▼
                 ┌───────────┐ ┌─────────────┐
                 │ Check     │ │ Press       │
                 │ Reset     │ │ BTN[0] to   │
                 │ Check Code│ │ switch      │
                 └───────────┘ │ pattern     │
                               └──────┬──────┘
                                      │
                                      ▼
                                ┌─────────────┐
                                │ Does display│
                                │ have image  │
                                │ change?     │
                                └──────┬──────┘
                                       │
                                ┌──────┴──────┐
                                │ NO          │ YES
                                ▼             ▼
                          ┌───────────┐ ┌─────────────┐
                          │ TFP410    │ │ System      │
                          │ Hardware  │ │ Normal      │
                          │ Issue     │ │ Working     │
                          │ Check:    │ │ Correctly   │
                          │ - Power   │ └─────────────┘
                          │ - Connect │
                          │ - Chip    │
                          └───────────┘
```

---

## III. TFP410 Hardware Checklist

### 1. Power Check (Multimeter)
| Pin | Voltage | Normal Range |
|------|------|----------|
| DVDD | 1.8V | 1.71-1.89V |
| DVDDIO | 3.3V | 3.0-3.6V |
| PVDD | 1.8V | 1.71-1.89V |

### 2. Reset Check
- TFP410 RESET pin should be high level (working state)

### 3. Clock Check
- PCLK input should have 74.25MHz signal (oscilloscope)

### 4. Data Activity Check
- DE/HS/VS should have activity signals (oscilloscope)
- D[0:23] should have data toggling (logic analyzer)

---

## IV. Common Issues and Solutions

### Issue 1: LED[3] OFF (PLL Not Locked)
**Possible Causes:**
- 50MHz crystal not working
- PLL configuration error
- Reset not released

**Solution:**
- Measure crystal output
- Check clk_wiz_50to100 configuration
- Check rst_n pin voltage level

### Issue 2: LED[4] OFF (No Data Output)
**Possible Causes:**
- Reset not released
- Test pattern generator not working
- Pixel clock not arriving

**Solution:**
- Check sys_rst_n signal
- Check pixel_clk_buf signal
- Re-synthesize code

### Issue 3: Display No Signal
**Possible Causes:**
- TFP410 power abnormal
- HDMI connector cold solder joint
- Voltage standard mismatch (should be LVCMOS25)
- Display does not support 720p@60Hz

**Solution:**
- Measure TFP410 power pins
- Check HDMI connector soldering
- Confirm IOSTANDARD = LVCMOS25 in UCF
- Try another display

### Issue 4: Display Has Signal But No Image
**Possible Causes:**
- Data polarity error
- Timing parameter mismatch
- RGB data bit width issue

**Solution:**
- Check data bus activity with oscilloscope
- Try full white/full red and other solid color tests
- Check TFP410 data timing

---

## V. Quick Test Commands

### 1. View LED Status
```
LED[7:0] = 8'b000LDPA0
              │││││└─ Reserved
              ││││└── Test Mode Bit0
              │││└─── Test Mode Bit1
              ││└──── Test Mode Bit2
              │└───── PLL Lock (1=Normal)
              └────── HDMI Output (1=Normal)
```

### 2. Oscilloscope Measurement Points
```
TP0 (AF10): PLL_LOCK  → DC high level
TP1 (AG10): PCLK      → 74.25MHz square wave
TP2 (AH10): ACTIVE    → Row pulse
TP3 (A11):  DE        → Data enable pulse
```

### 3. Button Operations
```
BTN[0]: Switch test pattern (cycle through modes 0-5)
BTN[1]: Not used
RST:    System reset
```

---

## VI. Signs of Normal Operation

✅ **All conditions met indicates system is normal:**
1. LED[3] constantly ON (PLL locked)
2. LED[4] constantly ON/blinking (data output)
3. LED[0:2] changes when pressing BTN[0]
4. Display shows corresponding test pattern
5. Oscilloscope measures 74.25MHz PCLK signal

❌ **If any condition is not met, troubleshooting is needed:**
- Check power
- Check clock
- Check reset
- Check constraint file
- Check TFP410 hardware connection

---

## VII. Contact Support

If issues cannot be resolved after completing the above diagnosis, please provide:
1. LED status photos
2. Oscilloscope measurement waveforms (PCLK/DE/HS/VS)
3. TFP410 power voltage measurements
4. Timing analysis results from synthesis report
