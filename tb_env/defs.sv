/*

File containing various defined parameters and object types

Zachary Zazzara (40096894)

Created on: March 27th, 2024
Last edited: March 27th, 2024

*/

parameter REQ_CMD_WIDTH = 4;
typedef bit [REQ_CMD_WIDTH-1:0] req_cmd_t;

parameter REQ_DATA_WIDTH = 32;
typedef bit [REQ_DATA_WIDTH-1:0] req_data_t;

parameter REQ_TAG_WIDTH = 2;
typedef bit [REQ_TAG_WIDTH-1:0] req_tag_t;

parameter OUT_RESP_WIDTH = 2;
typedef bit [OUT_RESP_WIDTH-1:0] out_resp_1;

parameter ADD = 4'b0001,
		SUB = 4'b0010,
		LSH = 4'0101,
		RSH = 4'b0110; 