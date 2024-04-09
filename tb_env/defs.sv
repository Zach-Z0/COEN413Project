/*

File containing various defined parameters and object types

Zachary Zazzara (40096894)

Created on: March 27th, 2024

*/

package defs;
//width of data for commands
//data for type output or input i see...
	parameter REQ_CMD_WIDTH = 4;
	typedef bit [REQ_CMD_WIDTH-1:0] req_cmd_t;

	//data width as usual
	parameter REQ_DATA_WIDTH = 32;
	typedef bit signed [REQ_DATA_WIDTH-1:0] req_data_t;

	//tag width
	parameter REQ_TAG_WIDTH = 2;
	typedef bit [REQ_TAG_WIDTH-1:0] req_tag_t;

	//response width
	parameter OUT_RESP_WIDTH = 2;
	typedef bit [OUT_RESP_WIDTH-1:0] out_resp_t;

	//port width
	parameter REQ_PORT_WIDTH = 2;
	typedef bit [REQ_PORT_WIDTH-1:0] req_port_t;

	//4-bit commands for feeding into the calculator
	//request of commands
	parameter 
			ADD = 4'b0001,
			SUB = 4'b0010,
			LSH = 4'b0101,
			RSH = 4'b0110,
			NOP = 4'b0000;

	//tag going in and out
	parameter 
			TAG0 = 2'b00,
			TAG1 = 2'b01,
			TAG2 = 2'b10,
			TAG3 = 2'b11;

	//response output 
	parameter 
			GOOD =2'b01,
			INVL = 2'b10,
			ERR = 2'b11,
			NORE = 2'b00;
endpackage