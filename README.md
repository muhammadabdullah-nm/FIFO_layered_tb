# FIFO_layered_tb

Functional verification of a **synchronous FIFO** using a **layered (class-based) SystemVerilog testbench**. The testbench separates stimulus generation, pin-level driving, monitoring, and checking into independent layers, so each piece can be reused or extended without touching the others.

## Overview

The design under test (DUT) is a FIFO with write and read ports, plus `full` and `empty` status flags. The testbench applies randomized write/read traffic, observes the DUT's behavior, and compares it against a reference model to catch functional bugs such as overflow, underflow, data corruption, and incorrect flag behavior.

## Testbench Architecture

```
                 +----------------------------------------------+
                 |                 Environment                  |
                 |                                              |
                 |  +-----------+   mailbox   +----------+      |
                 |  | Generator | ----------> |  Driver  | --+  |
                 |  +-----------+             +----------+   |  |
                 |                                           v  |
                 |                                     +---------+
                 |                                     |Interface|<--> DUT (FIFO)
                 |                                     +---------+
                 |                                           ^  |
                 |  +------------+  mailbox   +----------+   |  |
                 |  | Scoreboard | <--------- | Monitor  | --+  |
                 |  +------------+            +----------+      |
                 +----------------------------------------------+
```

| Component       | Role                                                                  |
|-----------------|-----------------------------------------------------------------------|
| **Transaction** | Data object holding the randomized fields (write/read enable, data)   |
| **Generator**   | Creates randomized transactions and sends them to the driver          |
| **Driver**      | Converts transactions into pin-level activity on the DUT interface    |
| **Monitor**     | Samples DUT signals and rebuilds transactions from observed activity  |
| **Scoreboard**  | Compares DUT output against an expected-data model and reports results|
| **Environment** | Instantiates and connects all components, controls the run phases     |
| **Test**        | Top-level program that builds the environment and starts simulation   |
