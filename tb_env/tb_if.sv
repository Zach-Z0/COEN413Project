/*

Interface class for testbench, allowes for connection between Driver -> DUT, and DUT-> Monitor
And probably other places/things. 
Will need a wrapper class to neatly connect the interface to the DUT.

Needs to be sensisitve to NEGATIVE EDGE of clock as defined in the design specification
Zachary Zazzara (40096894)
zexi si (40175054)

Created on: March 29th, 2024
*/

//`ifndef TB_IF_DEFINE
//`define TB_IF_DEFINE

import defs::*;

interface tb_if(input ifClk); //clock will come frop TB top module, which doesn't exist yet

    //clock passed from top, doesn't get declared here
    //Reset, goes into DUT
    logic ifRst;

    //Input side of DUT
    logic [REQ_CMD_WIDTH-1:0] ifReq1_cmd_in, ifReq2_cmd_in, ifReq3_cmd_in, ifReq4_cmd_in;
    logic [REQ_DATA_WIDTH-1:0] ifReq1_data_in, ifReq2_data_in, ifReq3_data_in, ifReq4_data_in;
    logic [REQ_TAG_WIDTH-1:0] ifReq1_tag_in, ifReq2_tag_in, ifReq3_tag_in, ifReq4_tag_in;

    //Output side of DUT
    logic [OUT_RESP_WIDTH-1:0] ifResp1_out, ifResp2_out, ifResp3_out, ifResp4_out;
    logic [REQ_DATA_WIDTH-1:0] ifData1_out, ifData2_out, ifData3_out, ifData4_out;
    logic [REQ_TAG_WIDTH-1:0] ifTag1_out, ifTag2_out, ifTag3_out, ifTag4_out;

    clocking driver_cb @(negedge ifClk); 
        //Do I need to change default timings??? I'm not sure yet. I don't THINK so...
        //Make changes here after more work is done on the driver functions/tasks (?)
        //I THINK only need outputs here for the transactions going Driver -> DUT and nothing else... but we'll see I guess.
        output ifRst;
        output ifReq1_cmd_in;
        output ifReq2_cmd_in;
        output ifReq3_cmd_in;
        output ifReq4_cmd_in;
        output ifReq1_data_in;
        output ifReq2_data_in;
        output ifReq3_data_in;
        output ifReq4_data_in;
        output ifReq1_tag_in;
        output ifReq2_tag_in;
        output ifReq3_tag_in;
        output ifReq4_tag_in;
    endclocking

    clocking monitor_cb @(negedge ifClk); 
        //Timing question applies here too.
        //Make changes here after more work is done on the monitor functions (?)
        
        //Only need outputs here for the transactions going DUT -> Monitor and nothing else... but we'll see I guess.
        input ifResp1_out;
        input ifResp2_out;
        input ifResp3_out;
        input ifResp4_out;
        input ifData1_out;
        input ifData2_out;
        input ifData3_out;
        input ifData4_out;
        input ifTag1_out;
        input ifTag2_out;
        input ifTag3_out;
        input ifTag4_out;
    endclocking

    //Modports go here
    modport Master(clocking driver_cb); //Modport for the driver to assert signals into the interface
    modport Monitor(clocking monitor_cb); //Modport for the monitor to assert signals into the interface (?)

    //Modport for the DUT to read signals from the interface
    //I think this is right, if ugly, but right. Leaving it as a TODO anyways just in case.
    //Slave(DUT) modport does not take a clocking block for... some reason. This is just how it is in Lab 2, 3, and 4
    modport Slave(
        input ifRst,
        input ifClk,
        input ifReq1_cmd_in,
        input ifReq2_cmd_in,
        input ifReq3_cmd_in,
        input ifReq4_cmd_in,
        input ifReq1_data_in,
        input ifReq2_data_in,
        input ifReq3_data_in,
        input ifReq4_data_in,
        input ifReq1_tag_in,
        input ifReq2_tag_in,
        input ifReq3_tag_in,
        input ifReq4_tag_in,
        output ifResp1_out,
        output ifResp2_out,
        output ifResp3_out,
        output ifResp4_out,
        output ifData1_out,
        output ifData2_out,
        output ifData3_out,
        output ifData4_out,
        output ifTag1_out,
        output ifTag2_out,
        output ifTag3_out,
        output ifTag4_out
    );
endinterface

//`endif