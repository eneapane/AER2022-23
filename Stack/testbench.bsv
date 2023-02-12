package testbench;
    import Vector::*;
    import StmtFSM::*;
    import impl::*;
    module mkTestbench(Empty);

        Reg#(UInt#(32)) idx_put <- mkReg(0);
        Reg#(UInt#(32)) idx_get <- mkReg(0);
        Stack dut <- mkStack;

        Stmt s = seq
            $display("Trying to remove values from an empty stack");
            for(idx_get <= 0; idx_get < 5; idx_get <= idx_get + 1) action
                let t <- dut.pop();
                $display("%d", t);
                endaction

            $display("Popping and pushing in the same cycle on an empty stack");
            for(idx_get <= 0; idx_get < 5; idx_get <= idx_get + 1) action
                dut.push(unpack(pack(idx_put)));
                let t <- dut.pop();
                $display("%d", t);
            endaction

            $display("Pushing values from zero to 4 and showing them");
            for(idx_put <= 0; idx_put < 5; idx_put <= idx_put + 1) action
                    dut.push(unpack(pack(idx_put))); // unpack(pack()) to cast from uint to int
                endaction
            $display("Size currently: %d", dut.size);
            for(idx_get <= 0; idx_get < 5; idx_get <= idx_get + 1) action
                    let t <- dut.pop();
                    $display("%d", t);
                endaction
            $display("Size currently: %d", dut.size);
            
            $display("Trying to push more numbers when the stack is full");
            //first fill the stack up
            for(idx_put <= 0; idx_put < 5; idx_put <= idx_put + 1) action
                    dut.push(unpack(pack(idx_put))); // unpack(pack()) to cast from uint to int
                endaction
            //try to surpass capacity
            for(idx_put <= 6; idx_put < 10; idx_put <= idx_put + 1) action
                    dut.push(unpack(pack(idx_put))); // unpack(pack()) to cast from uint to int
                endaction
            $display("Size currently: %d", dut.size);
               
                
        endseq;

        mkAutoFSM(s);


    endmodule : mkTestbench


endpackage : testbench