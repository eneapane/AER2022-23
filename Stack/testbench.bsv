package testbench;
    import Vector::*;
    import StmtFSM::*;
    import impl::*;
    module mkTestbench(Empty);

        Reg#(Int#(32)) ctr <- mkReg(0);
        Stack dut <- mkStack;

        Stmt s = seq
            
            dut.push(0);
            dut.push(4);
            dut.push(8);

            while(ctr < 30)
            par
                dut.push(unpack(pack(ctr)));
            action
                printTimed("Popped:");
                $display(dut.pop());
                ctr <= ctr + 5;
            endaction
            endpar
        endseq;

        mkAutoFSM(s);


    endmodule : mkTestbench


endpackage : testbench