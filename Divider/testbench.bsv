package testbench;

    import StmtFSM::*;
    import impl::*;

    module mkTestbench(Empty);
        Server#(Tuple2#(Int#(32), Int#(32)), Maybe#(Int#(32))) dut <- mkDivider;
        Reg#(Int#(32)) t <- mkReg;
        Stmt s = seq
                    $display("Starting the testbench");
                    dut.request.put(tuple2(24, 5));
                    t <= fromMaybe(-1 , dut.response.get());
                    while(t == -1)
                        t <= fromMaybe(-1 , dut.response.get());
                    $display("Result %d", t);
                    $display("Finishing testbench");
                endseq;

        mkAutoFSM(s);

    endmodule : mkTestbench


endpackage : testbench