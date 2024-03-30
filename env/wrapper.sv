/*

Wrapper class



Takes the DUT inputs/outputs delcared in "calc2_top" and equates them to interface signals

Zachary Zazzara (40096894)
ze xi si (40175054)

Created on: March 29th, 2024
*/
`include "hdl/cal2_top.sv"
`include "env/env.sv"
`include "tests/test.sv"
module wrapper (tb_if interf);


//i think we need to connecct em


 calc2_top DUT (

        //THESE ARE JUST PORT CONNECTION TO AND FROM DUT
        .ifClk(interf.ifClk),

        .ifRst(interf.ifRst),

        //=======================================
        .ifReq1_cmd_in(interf.ifReq1_cmd_in),
        .ifReq2_cmd_in(interf.ifReq2_cmd_in), 
        .ifReq3_cmd_in(interf.ifReq3_cmd_in), 
        .ifReq4_cmd_in(interf.ifReq4_cmd_in), 
        //======================================

        .ifReq1_data_in(interf.ifReq1_data_in),
        .ifReq2_data_in(interf.ifReq2_data_in),
        .ifReq3_data_in(interf.ifReq3_data_in), 
        .ifReq4_data_in(interf.ifReq4_data_in),
        //========================================
        .ifReq1_tag_in(interf.ifReq1_tag_in),
        .ifReq2_tag_in(interf.ifReq2_tag_in),
        .ifReq3_tag_in(interf.ifReq3_tag_in),
        .ifReq4_tag_in(interf.ifReq4_tag_in), 
        
        //=======================================
        .ifResp1_out(interf.ifResp1_out),
        .ifResp2_out(interf.ifResp2_out),
        .ifResp3_out(interf.ifResp3_out),
        .ifResp4_out(interf.ifResp4_out),

        .ifData1_out(interf.ifData1_out),
        .ifData2_out(interf.ifData2_out), 
        .ifData3_out(interf.ifData3_out), 
        .ifData4_out(interf.ifData4_out),

        //======================================
        .ifTag1_out(interf.ifTag1_out),
        .ifTag2_out(interf.ifTag2_out),
        .ifTag3_out(interf.ifTag3_out),
        .ifTag4_out(interf.ifTag4_out)
        //======================================= 
    //i think i finished it

    //"INTERFACE NAME" -> "DUT INTERNAL NAME" yes that should work i think
    //The declaration from calc2_top.v is not clear. Some of the signals expected aren't in the documentation.
    //Done here  
 );


 //BEGIN==========================

        //==========VAR============= 
        //we have test i realized 
        //env globalenv;  

        test globaltest;

        initial begin
        //thats it we let the local env run and so on everything in it
        globaltest = new(interf);

        end


endmodule