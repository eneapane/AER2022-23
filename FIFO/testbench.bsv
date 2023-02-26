package testbench;
    import Vector::*;
    import StmtFSM::*;
    import impl::*;
    module mkTestbench(Empty);

        Reg#(Int#(32)) ctr <- mkReg(0);
        MyFIFO dut <- mkMyFIFO;

        Stmt s = seq
            
            dut.enq(0);
            dut.enq(4);
            dut.enq(8);

            while(ctr < 28)
            par
                dut.enq(unpack(pack(ctr + 2)));
                dut.deq();
            action
                printTimed("First Element");
                $display("%d", dut.first());
                ctr <= ctr + 5;
            endaction

            endpar
            $display("Finished testbench");
        endseq;

        mkAutoFSM(s);


    endmodule : mkTestbench


endpackage : testbench