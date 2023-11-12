# CompEng 361 - Fall 2023 (Northwestern University)
## Lab 3 - Pipelined CPU

In this project, you will work in groups of two to design a five stage pipelined RISC-V CPU which
implements the majority of the RV32I Base Instruction Set. Specifically, you must implement the
same instructions required by the previous lab. The easiest way to do this is to extend your
design from Lab 2 to create the pipelined design.

The pipelined processor will be implemented in Verilog (your choice of behavioral or structural)
and must have the following interface and port list:

```
module PipelinedCPU(halt, clk, rst);
    output halt;
    input clk, rst;
```

You should use the same register file and memory modules from the previous lab. Try to
balance the pipeline stages so that your design would have the maximum possible clock rate. A
few additional notes:

- Please do NOT change the interface to the module. It must not deviate from what is
posted above.
- Your solution should be able to compile and run correctly with unmodified testbench and
library files.
- Your solution MUST be entirely in Verilog (no Chisel or System Verilog)
- Your solution should be self-contained in a single Verilog source file without use of any
external source files beyond the ones supplied.
- You should feel free to use either structural or behavioral code to implement your design,
but we strongly recommend the former.

You must devise your own testing programs. Make sure the module is thoroughly tested. Try to
think of corner cases and make sure they are appropriately handled.

You should turn in a single Verilog file with the following format:

```
<group-name>_lab3.v
```

Do not include testbenches, library files, test programs, or other supporting files.

Note that this is a group assignment. Turn in one submission per group.
