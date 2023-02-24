package testbench;

    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Reg#(Int#(32)) t <- mkRegU;
        Reg#(Int#(32)) count <- mkReg(0);
        
        Counter dut <- mkOverflowCounter;
        Stmt s = seq
                    $display("Starting the testbench");
                    dut.setMaxValue(15);
                    $display("Decrementing until saturated");
                    for(count <= 0; count < 20; count <= count + 1) action
                        dut.increment(2);
                        dut.decrement(3);
                        $display("Cycle: %d, value %d", count, dut.get());
                    endaction
                    $display("Incrementing until saturated");
                    for(count <= 0; count < 20; count <= count + 1) action
                        dut.increment(2);
                        $display("Cycle: %d, value %d", count + 20, dut.get());
                    endaction
                    $display("Reset and display value");
                    dut.resetCounter();
                    $display("Cycle: 40, value %d", dut.get());
                    $display("Finishing testbench");
                endseq;

        mkAutoFSM(s);

    endmodule : mkTestbench


endpackage : testbench