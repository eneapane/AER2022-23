package testbench;

    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Reg#(Int#(5)) t <- mkRegU;
        Reg#(Int#(5)) count <- mkReg(0);
        
        GrayCode dut <- mkGrayCode;
        Stmt s = seq
                    $display("Starting the testbench");
                    
                    dut.request.put(15);
                    noAction;
                    noAction;
                    for(count <= 0; count < 15; count <= count + 1) action
                        
                    // action
                    //     let t1 <- dut.response.get();
                    //     t <= t1;
                    // endaction
                    // while(isValid(t)) action
                        let t2 <- dut.response.get();
                        //if(t2 matches tagged Valid .val) begin
                            t <= val;
                            $display("%b", t);
                        //end
                    endaction
                    $display("Finishing testbench");
                endseq;

        mkAutoFSM(s);

    endmodule : mkTestbench


endpackage : testbench