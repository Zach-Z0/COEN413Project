/*
Driver class which handles taking the transactions recieved from the agent class through the "agt2dvr" mailbox and translating
them into low level commands for the input lines of the DUT. 

Also handles reset commands and passing through the clock.
Needs to work closely with the interface.

Zachary Zazzara (40096894)
zexi si (40175054)

Created on: March 29th, 2024
*/

`include "tb_env/tb_trans.sv"
`include "tb_env/defs.sv"

class driver
    //Interface object declaration
    virtual tb_if.Master tb_master_if;

    //Mailbox
    mailbox #(tb_trans) agt2dvr;

    function new(virtual apb_if.Master tb_master_if, mailbox #(apb_trans) agt2dvr); 
    this.tb_master_if = tb_master_if;
    this.agt2dvr = agt2dvr;
    endfunction: new

    task main();
        //TODO
    endtask: main

    task reset();
        @(this.tb_master_if); //Waits for negative edge of the clock, this might not be necessary.

        //Hold reset HI for 3 clock cycles
        tb_master_if.ifRst <= 1; 
        //Hold all inputs LO for 3 clock cycles
        tb_master_if.ifReq1_cmd_in <= 0;
        tb_master_if.ifReq2_cmd_in <= 0;
        tb_master_if.ifReq3_cmd_in <= 0;
        tb_master_if.ifReq4_cmd_in <= 0;
        tb_master_if.ifReq1_data_in <= 0;
        tb_master_if.ifReq2_data_in <= 0;
        tb_master_if.ifReq3_data_in <= 0;
        tb_master_if.ifReq4_data_in <= 0;
        tb_master_if.ifReq1_tag_in <= 0;
        tb_master_if.ifReq2_tag_in <= 0;
        tb_master_if.ifReq3_tag_in <= 0;
        tb_master_if.ifReq4_tag_in <= 0;

        //Wait the 3 clock cycles, did 4 for good measure.
        repeat(4) @(this.tb_master_if);
    endtask: reset

    //Other tasks here as needed (?)
endclass: driver