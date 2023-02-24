package testbench;

    import StmtFSM::*;
    import impl::*;
    import ClientServer::*;
    import GetPut::*;

    module mkTestbench(Empty);
        Reg#(Int#(32)) count <- mkReg(0);
        BitCounter dut <- mkOneCycleCounter;
        // Stmt s = seq
        //             $display("Starting the testbench");
        //             for(count <= 0; count < 20; count <= count + 1) seq
        //                 action
        //                     dut.set(count);
        //                     endaction
        //                     action
        //                     $display("%b has %d zeros and %d ones", count, dut.getZeros(), dut.getOnes());
        //                     endaction
        //             endseq                   
        //             $display("Finishing testbench");
        //         endseq;

        Stmt s2 = seq
                    $display("Starting the second testbench");
                    for(count <= 0; count < 20; count <= count + 1) seq
                        action
                            $display("In loop iteration");
                            dut.set(count);
                            endaction
                            action
                            $display("%b has %d zeros and %d ones", count, dut.getZeros(), dut.getOnes());
                            $display("Out of loop iteration");
                            endaction
                    endseq 
                    $display("Finishing testbench");
                endseq;


        // mkAutoFSM(s);
        mkAutoFSM(s2);

    endmodule : mkTestbench


endpackage : testbench