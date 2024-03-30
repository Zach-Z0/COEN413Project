/*

Top level file for the program, instantiates the interface, testbench and DUT.
This is pretty much taken exactly as it is from lab 3 & 4

Zachary Zazzara (40096894)
ze xi si (40175054)

I think this is done?

Created on: March 29th, 2024
*/

//maybe we need these, no harm putting here
`include "env/wrapper.sv"
`include "tb_env/tb_if.sv"

module top;
    parameter SIM_CYCLE = 100;

    bit clk;
    always #(SIM_CYCLE/2)
        clk = ~clk;

//==============EXECUTION PART===============

    tb_if interf(clk); //Create interface
    test tb1(interf); //Create testbench
    wrapper wrap(interf); //Create wrapper and pass interface to it, which then creates DUT in wrapper module
endmodule