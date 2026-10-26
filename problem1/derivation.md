# Problem 1: Traffic Light Controller from K-map equations

State encoding (S1 S0): RED = 00, GREEN = 01, YELLOW = 10, 11 unused (don't care).

## 1. State transition truth table

| Current S1 S0 | State  | Next D1 D0 | Next state |
|---------------|--------|------------|------------|
| 0 0           | RED    | 0 1        | GREEN      |
| 0 1           | GREEN  | 1 0        | YELLOW     |
| 1 0           | YELLOW | 0 0        | RED        |
| 1 1           | unused | X X        | don't care |

## 2. K-maps

Rows are S1, columns are S0.

D1:

| S1 \ S0 | 0 | 1 |
|---------|---|---|
| 0       | 0 | 1 |
| 1       | 0 | X |

Group the 1 at m1 with the X at m3 (S0 = 1 column, pair of 2).

**D1 = S0**

D0:

| S1 \ S0 | 0 | 1 |
|---------|---|---|
| 0       | 1 | 0 |
| 1       | 0 | X |

The only 1 is m0. Its neighbours are m1 (0) and m2 (0), and the X at m3 is not adjacent to m0, so no group grows beyond a single cell. The X is set to 0.

**D0 = S1' . S0'**

Unused state check: with the X cells used as above, 11 gives D1 D0 = 1 0, so the machine goes 11 -> YELLOW -> RED and recovers by itself.

## 3. Moore output equations

- red    = S1' . S0'
- green  = S1' . S0
- yellow = S1  . S0'

Each is one minterm, so exactly one output is high in every valid state.

## 4. Implementation

`traffic_light.v` uses only these equations (`d1`, `d0`, `red`, `green`, `yellow`) in front of a plain 2-bit register with synchronous reset. There is no case statement.

## Run

    iverilog -o sim traffic_light.v traffic_light_tb.v && vvp sim
