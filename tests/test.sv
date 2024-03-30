/*

Starting file that calls literally everything else. This file intanciates the environment, runs it, then everything else.
This is pretty much taken exactly as it is from lab 3 & 4

I think this is just done?

Zachary Zazzara (40096894)

Created on: March 29th, 2024
*/

program automatic test(tb_if interf)

    `include "env/env.sv"

    //Instanciate top level environment
    env env1;

    initial begin
        env1 = new(interf);

        //start the tests
        env1.run();
        
        $finish;
    end
endprogram