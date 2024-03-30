/*
Driver class which handles taking the transactions recieved from the agent class through the "agt2dvr" mailbox and translating
them into low level commands for the input lines of the DUT. 

Also handles reset commands and passing through the clock.
Needs to work closely with the interface, which hasn't been defined yet as of writing this note (March 29th).

NOTE: Interface needs to be sensitive to the NEGATIVE EDGE of the clock NOT positive edge!!!

Zachary Zazzara (40096894)
zexi si (40175054)

Created on: March 29th, 2024
*/

`include "tb_env/tb_trans.sv"
`include "tb_env/defs.sv"

class driver
    //Interface object declaration
    //this going to DUT i hope...
    virtual tb_if.Master tb_master_if;

    //Mailbox
    mailbox #(tb_trans) agt2dvr;
    //so this only for transaction here mailbox

    function new(virtual apb_if.Master tb_master_if, mailbox #(apb_trans) agt2dvr); 
    this.tb_master_if = tb_master_if;
    this.agt2dvr = agt2dvr;
    endfunction: new

    task main();
    //so we get transaction from agent i guess very simple case

    agt2dvr.get(tr);

    case (transaction.port)
            1: begin
            //depending on port, will assign the required cmd data and tag to dut.
            //a quick case statement
                tb_master_if.ifReq1_cmd_in = transaction.cmd;
                tb_master_if.ifReq1_data_in = transaction.op1;
                tb_master_if.ifReq1_tag_in = transaction.tag;
            end
            2: begin
                tb_master_if.ifReq2_cmd_in = transaction.cmd;
                tb_master_if.ifReq2_data_in = transaction.op1;
                tb_master_if.ifReq2_tag_in = transaction.tag;
            end
            3: begin
                tb_master_if.ifReq3_cmd_in = transaction.cmd;
                tb_master_if.ifReq3_data_in = transaction.op1;
                tb_master_if.ifReq3_tag_in = transaction.tag;
            end
            4: begin
                tb_master_if.ifReq4_cmd_in = transaction.cmd;
                tb_master_if.ifReq4_data_in = transaction.op1;
                tb_master_if.ifReq4_tag_in = transaction.tag;
            end
            default: $display("Check the Enum/if again, something went wrong!");
         
        endcase

    endtask: main

    task reset();
    //TODO:DONE

    //this is how i approach reset typically

    tb_master_if.ifRst = 1'b1;
    #50;
    //if signal is reset in trans

    tb_master_if.ifRst = 1'b0;

    endtask: reset




    //Other tasks here as needed
    //others?

endclass: driver