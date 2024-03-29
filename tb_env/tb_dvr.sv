/*
Driver class which handles taking the transactions recieved from the agent class through the "agt2dvr" mailbox and translating
them into low level commands for the input lines of the DUT. 

Also handles reset commands and passing through the clock.
Needs to work closely with the interface, which hasn't been defined yet as of writing this note (March 29th).

NOTE: Interface needs to be sensitive to the NEGATIVE EDGE of the clock NOT positive edge!!!

Zachary Zazzara (40096894)

Created on: March 29th, 2024
*/

`include "tb_env/tb_trans.sv"
`include "tb_env/defs.sv"

class driver

//Interface object declaration goes here

//Mailbox
mailbox #(tb_trans) agt2dvr;

function new(/*Interface goes here*/, mailbox #(apb_trans) agt2dvr); 
//TODO
//Interface declaration HERE
this.agt2dvr = agt2dvr;
endfunction: new

task main();
//TODO
endtask: main

task reset();
//TODO
endtask: reset

//Other tasks here as needed

endclass: driver