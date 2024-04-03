/*

Transaction object class that should then be used by the generator class.

Zachary Zazzara (40096894)
ze xi si (40175054)

Created on: March 27th, 2024

*/

/*
Not sure if I actually need the two lines below + 'endif'
Put them in for now, because I see it in lab 3 & 4 code. 
Seems to be related to the interface and prevents a compiler issue
related to "multiple declaration" errors. So if you ever see any
of those, uncomment lines marked with (&&) these lines, I guess.
*/
//&& `ifndef 
//&& `define 

`include "tb_env/defs.sv"

class tb_trans;
	rand req_cmd_t cmd;
	rand req_data_t op1; //Doubles as response holder when used by monitor!
	rand req_data_t op2; //two datas for + and - ops, maybe apply constraints later?
	rand req_port_t port; 
	
	req_tag_t tag; //transaction tag to be assigned by the agent
	
	static int count = 0; //Counts the total number of transaction objects generatated so far
	int id; //transaction ID of current transaction object/instance

	//Need contstrains for these randoms
	constraint c_cmd {cmd inside {ADD, SUB, LSH, RSH, NOP};}
	constraint c_port {port inside {1,2,3,4};}

	//Functions
	function new();
		this.id = count++;
	endfunction: new

	function void display();
	//TODO
	//Don't know if I actually need this, might be useful for debugging later?
	endfunction: display

	function tb_trans copy(); //Deep copy function just in case we need it?
		tb_trans deep_cp = new();
		count--; //Don't skew the IDs by making copies
		deep_cp.id = this.id;
		deep_cp.cmd = this.cmd;
		deep_cp.op1 = this.op1;
		deep_cp.op2 = this.op2;
		deep_cp.tag = this.tag;
		deep_cp.port = this.port;
		copy = deep_cp;
	endfunction: copy
endclass: tb_trans


//&& `endif