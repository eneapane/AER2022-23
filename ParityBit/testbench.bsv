package testbench;

    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Reg#(Int#(32)) count <- mkReg(0);
        ParityCalculator dut <- mkParityCalculator;
        Reg#(Int#(32)) t <- mkRegU;
        Stmt s = seq
                    $display("Starting the testbench");
                    dut.set(1);
                    for(count <= 0; count < 100; count <= count + 1) seq
                        action
                            dut.set(count);
                            endaction
                            action
                            $display("Count %d, Result %b", count, dut.get());
                            endaction
                    endseq
                    
                    $display("Result %b", dut.get());
                    
                    

                    $display("Finishing testbench");
                endseq;


        mkAutoFSM(s);

    endmodule : mkTestbench


endpackage : testbench