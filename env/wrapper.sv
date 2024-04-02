/*

Wrapper class

Takes the DUT inputs/outputs delcared in "calc2_top" and equates them to interface signals.

This is done, I think?

Zachary Zazzara (40096894)
ze xi si (40175054)

Created on: March 29th, 2024
*/

`include "hdl/cal2_top.sv"

module wrapper (tb_if.Slave interf);
       //"INTERFACE NAME" -> "DUT INTERNAL NAME"
       //Legend: .DUT_wire_name(interface.interface_wire_name)

       calc2_top DUT (
              .c_clk(interf.ifClk),
              .reset(interf.ifRst),
              //======================================= IN
              .req1_cmd_in(interf.ifReq1_cmd_in),
              .req2_cmd_in(interf.ifReq2_cmd_in), 
              .req3_cmd_in(interf.ifReq3_cmd_in), 
              .req4_cmd_in(interf.ifReq4_cmd_in), 
              //======================================
              .req1_data_in(interf.ifReq1_data_in),
              .req2_data_in(interf.ifReq2_data_in),
              .req3_data_in(interf.ifReq3_data_in), 
              .req4_data_in(interf.ifReq4_data_in),
              //========================================
              .req1_tag_in(interf.ifReq1_tag_in),
              .req2_tag_in(interf.ifReq2_tag_in),
              .req3_tag_in(interf.ifReq3_tag_in),
              .req4_tag_in(interf.ifReq4_tag_in), 
              //======================================= OUT
              .out_resp1(interf.ifResp1_out),
              .out_resp2(interf.ifResp2_out),
              .out_resp3(interf.ifResp3_out),
              .out_resp4(interf.ifResp4_out),
              //=======================================
              .out_data1(interf.ifData1_out),
              .out_data2(interf.ifData2_out), 
              .out_data3(interf.ifData3_out), 
              .out_data4(interf.ifData4_out),
              //======================================
              .out_tag1(interf.ifTag1_out),
              .out_tag2(interf.ifTag2_out),
              .out_tag3(interf.ifTag3_out),
              .out_tag4(interf.ifTag4_out),
              //======================================= MISC
              .scan_in(/*Dummy signal*/),
              .scan_out(/*Dummy signal*/),
              .a_clk(/*Dummy signal*/),
              .b_clk(/*Dummy signal*/)
       );
       //The "Misc" section is signals that aren't mentioned anywhere in the design specification but are present in calc2_top.sv
       //No idea what to do with these wire connections, the TA said connections can be made to these signals but to 
       //Concentrate on the signals specified in the design specification when generating inputs.
       //Note: because of the slave modport speficiation, the MISC signals might not be visible right now to the wrapper
       //Possibly will need to edit the modport specifications in tb_if.sv later.

endmodule