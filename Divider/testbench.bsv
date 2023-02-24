package testbench;

    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Divider dut <- mkDivider;
        Reg#(Int#(32)) t <- mkRegU;
        Stmt s = seq
                    $display("Starting the testbench");
                    dut.request.put(tuple2(34, 5));
                    /*action
                        let result <- dut.response.get();
                        t <= result;
                    endaction
                    $display("Result %d", t);
                    $display("Finishing testbench");*/
                    action
                        let result <- dut.response.get();
                        t <= fromMaybe(-1 , result); 
                    endaction
                    while(t == -1) action
                        let result <- dut.response.get();
                        t <= fromMaybe(-1 , result); 
                    endaction
                    $display("Result %d", t);
                    $display("Finishing testbench");
                endseq;


        mkAutoFSM(s);

    endmodule : mkTestbench


endpackage : testbench