/*

Environment class which instanciates the following:
	-TB Generator
	-TB Agent
	-More items TBD


Zachary Zazzara (40096894)
ze xi si (40175054)

Created on: March 28th, 2024

*/

`include "tb_env/tb_trans.sv"
`include "tb_env/tb_gen.sv"
`include "tb_env/tb_agt.sv"
`include "tb_env/tb_dvr.sv"
`include "tb_env/tb_moni.sv"
`include "tb_env/tb_if.sv"
`include "env/scoreboard.sv"

//TODO
//Will need more includes here as we write more classes

class test_cfg; //Configuration class
	//THIS SETS max_trans_cnt for other modules
	rand int trans_cnt;

	//For now arbitrarily chosen constraint based off labs 3 & 4.
	constraint c_trans_cnt {
		(trans_cnt > 0) && (trans_cnt < 100); 
	}
endclass: test_cfg

class env;

//Instanciate test config
test_cfg tcfg;

//Instanciate transactors
tb_gen gen;
tb_agt agt;
tb_moni mon;
tb_dvr dvr;
tb_scb scb;

//Instanciate mailboxes here
//Mailboxes: Generator -> Agent, Agent -> Driver, Monitor -> Scoreboard/Checker (and back)
mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt, mon2scb ;

//Interface declaration
virtual tb_if interf;

function new(virtual tb_if interf);

	this.interf = interf;

	//Mailboxs go here, 16 items max in each due to (4 input lines) * (4 outstanding commands per line)
	//This might be wrong? I don't know, it's my best guess right now.
	//Possible deadlock by doing this???? Probably not.
	gen2agt = new(16);
	agt2dvr = new(16);
	agt2scb = new(16);
	scb2agt = new(16);
	mon2scb = new(); //I don't think this one needs a limit?


	tcfg = new(); //Instanciate test config

	//Copy pasted from lab 4, just seems good to have in case.
	if (!tcfg.randomize()) 
		begin
			$display("test_cfg::randomize failed");
			$finish;
		end
	//call new() function for all modules of the test bench

	gen = new(gen2agt, tcfg.trans_cnt);
	agt = new(gen2agt, agt2dvr, agt2scb, scb2agt);
	dvr = new(this.interf, agt2dvr);
	mon = new(this.interf, mon2scb);

	//TODO
	//Scoreboard/checker
endfunction: new

virtual task pre_test();
	//TODO, refer to lab 4 env file
	//Sync scoreboard max_trans_cnt with generator max_trans_cnt
	fork
		//TODO
		//start scoreboard, driver, monitor, agent mains
		//Wait untill classes are implemented to put anything else here
		//Missing: scoreboard
		agt.main();
		dvr.main();
		mon.main();
	join_none
endtask: pre_test

virtual task test();
	dvr.reset(); 
	//Don't THINK I need to tell the monitor/scoreboard to ignore anything here b/c transactions aren't going anywhere
	fork
		gen.main();
		//TODO (?)
	join_none
endtask: test	

//Clean up function post running tests, waiting for everything to finish
virtual task post_test();
	//TODO
	fork
    	wait(gen.ended.triggered);
		//Scoreboard ended trigger here, see wait statement above
		agt.wrap_up();
		dvr.wrap_up();
		moni.wrap_up();
		//put other wrap up tasks here as needed
		//scoreboard/checker
		//may wanna shuffle the order of these around later
	join
endtask: post_test

task run();
	pre_test();
    test();
    post_test();
endtask: run

endclass: env