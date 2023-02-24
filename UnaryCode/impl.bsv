package impl;
    import FIFO::*;
    import ClientServer::*;
    import GetPut::*;
    


    typedef Server#(Int#(32), Int#(32)) Unary;


    module mkUnary(Unary);
        FIFO#(Int#(32)) in <- mkFIFO;
        FIFO#(Int#(32)) out <- mkFIFO;

        // function Bit#(32) get_unary_code(Int#(6) value);
        //     Bit#(32) unary_code = pack(0);
        //     for(Int#(6) i = 1; i < value; i = i + 1) begin
        //         unary_code[i] = 1;
        //     end
        //     return unary_code;
        // endfunction : get_unary_code

        // rule calculate;
        //     let t = in.first;
        //     in.deq;
        //     out.enq(get_unary_code(t));
        // endrule : calculate
        rule display;
            $display("First element of the fifo is %d", in.first);
        endrule 

        interface Put request = toPut(in);
        interface Get response = toGet(out);
    endmodule : mkUnary

endpackage : impl