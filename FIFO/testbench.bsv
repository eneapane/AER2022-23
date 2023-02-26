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

            while(ctr < 25)
            par
                dut.enq(unpack(pack(ctr)));
                dut.deq();
            action
                let t <- dut.first();
                if(isValid(t)) action
                    printTimed("First Element");
                    $display("%d", t);
                endaction
                else $display("It is invalid");
                ctr <= ctr + 5;
            endaction

            endpar
        endseq;

        mkAutoFSM(s);


    endmodule : mkTestbench


endpackage : testbench