package Testbench;

    import StmtFSM::*;
    import Impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Reg#(Int#(32)) count <- mkReg(0);
        BitCounter dut <- mkMultipleCyclesCounter;
        BitCounter dut1 <- mkTrueOneCycleCounter;
        Stmt s = seq
            $display("Starting the testbench");
            for(count <= 0; count < 20; count <= count + 1) seq
                action
                    dut.set(count);
                endaction
                action
                    $display("%b has %d zeros and %d ones", count, dut.getZeros(), dut.getOnes());
                endaction
            endseq                   
            $display("Finishing testbench");
        endseq;

        Stmt s2 = seq
            $display("Starting the second testbench");
            for(count <= 0; count < 20; count <= count + 1) par
                action
                    dut1.set(count);
                endaction
                $display("%b has %d zeros and %d ones", count, dut1.getZeros(), dut1.getOnes());
            endpar                   
            $display("Finishing testbench");
        endseq;

        let fsm1 <- mkFSM(s);
        let fsm2 <- mkFSM(s2);

        mkAutoFSM(seq
            fsm1.start();
            fsm1.waitTillDone();
            fsm2.start();
            fsm2.waitTillDone();
        endseq);

    endmodule : mkTestbench


endpackage