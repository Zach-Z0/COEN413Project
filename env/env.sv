/*

Environment class which instanciates the following:
	-TB Generator
	-TB Agent
	-More items TBD


Zachary Zazzara (40096894)

Created on: March 28th, 2024

*/

//`ifndef TB_IF_DEFINE
//`define TB_IF_DEFINE

import transPKG::*;
import defs::*;
import agentPKG::*;
import genPKG::*;
import dvrPKG::*;
import moniPKG::*;
import scbPKG::*;
//`include "tb_env/tb_if.sv"
//`include "tb_env/tb_agt.sv"
//`include "tb_env/tb_dvr.sv"
//`include "tb_env/tb_moni.sv"
//`include "tb_env/tb_gen.sv"
//`include "env/scoreboard.sv"

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
	mailbox #(tb_trans) gen2agt, agt2dvr, agt2scb, scb2agt;
	mailbox #(tb_trans_out) mon2scb;

	//Interface declaration
	virtual tb_if interf;

	function new(virtual tb_if interf);
		$display("Got into the new function of env");
		this.interf = interf;

		//Mailboxs go here, 16 items max in each due to (4 input lines) * (4 outstanding commands per line)
		//This might be wrong? I don't know, it's my best guess right now.
		//Possible deadlock by doing this???? Probably not.
		gen2agt = new();
		agt2dvr = new();
		agt2scb = new();
		scb2agt = new(); //Key return
		mon2scb = new(); //I don't think this one needs a limit?


		tcfg = new(); //Instanciate test config

		//Copy pasted from lab 4, just seems good to have in case.
		if (!tcfg.randomize()) begin
				$display("test_cfg::randomize failed");
				$finish;
			end
		//call new() function for all modules of the test bench

		gen = new(gen2agt, tcfg.trans_cnt);
		agt = new(gen2agt, agt2dvr, agt2scb, scb2agt);
		dvr = new(this.interf, agt2dvr);
		mon = new(this.interf, mon2scb);
		scb = new(tcfg.trans_cnt, agt2scb, scb2agt, mon2scb);

	endfunction: new

	virtual task pre_test();
		//Sync scoreboard max_trans_cnt with generator max_trans_cnt
		$display("Got to pre_test pre-fork");
		fork
			//start scoreboard, driver, monitor, agent mains
			agt.main();
			dvr.main();
			mon.main();
			scb.main();
		join_none
		$display("Got to pre_test post-fork");
	endtask: pre_test

	virtual task test();
		begin
		$display("Got to test task");
		dvr.reset(); 
		#500;
		//Don't THINK I need to tell the monitor/scoreboard to ignore anything here b/c transactions aren't going anywhere yet
		$display("Got to tesk task pre-fork");
		end
		fork
			gen.main();
		join_none
		$display("Got to tesk task post-fork");
	endtask: test	

	//Clean up function post running tests, waiting for everything to finish
	virtual task post_test();
		$display($time, ": Reached before fork post test.");
		fork
			$display($time, ": Waiting for gen and scb to end trigger.");
			wait(gen.ended.triggered());
			wait(scb.ended.triggered());

			//may wanna shuffle the order of these around later
		join
		$display($time, ": Reached post_test post-join.");
		agt.wrap_up();
		dvr.wrap_up();
		mon.wrap_up();
	endtask: post_test

	task run();
		$display("Got to the main Env's run function");
		pre_test();
		test();
		post_test();
	endtask: run
endclass: env

//`endif