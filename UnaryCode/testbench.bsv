package testbench;
    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Unary dut <- mkUnary;
        Stmt s = seq
                    $display("Starting the testbench");
                    action
                    dut.request.put(5);
                    $display("%b", dut.response.get());
    endaction
                    $display("Finishing the testbench");
                endseq;

        mkAutoFSM(s);

    endmodule : mkTestbench
endpackage : testbench