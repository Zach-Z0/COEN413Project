/*

Interface class for testbench, allowes for connection between Driver -> DUT, and DUT-> Monitor

Needs to be sensisitve to NEGATIVE EDGE of clock!!!!
Zachary Zazzara (40096894)

Created on: March 29th, 2024
*/

`include "tb_env/defs.sv"

interface tb_if(input clk);
//TODO
endinterface