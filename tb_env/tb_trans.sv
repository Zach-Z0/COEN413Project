/*

Transaction object class that should then be used by the generator class

Zachary Zazzara (40096894)

Created on: March 27th, 2024
Last edited: March 28th, 2024

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
	rand req_data_t op1;
	rand req_data_t op2; //two datas for + and - ops, maybe replace this with something more elegant later?
	rand req_tag_t tag;
	
//Need contstrains for these randoms
	constraint c_cmd {cmd inside {ADD, SUB, LSH, RSH};}
	constraint c_tag {tag inside {2'b00, 2'b01, 2'b10, 2'b11};}
	
//Functions
function new();

endfunction:new

function void display();
//TODO
//Don't know if I actually need this, might be useful for debugging later?
endfunction :display

function tb_trans copy(); //Deep copy function just in case we need it?
	tb_trans cp = new();
	cp.cmd = this.cmd;
	cp.op1 = this.op1;
	cp.op2 = this.op2;
	cp.tag = this.tag;
	copy = cp;
	
endfunction:copy

endclass


//&& `endif