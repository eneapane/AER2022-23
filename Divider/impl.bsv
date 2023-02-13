package impl;
    import Vector::*;
    import FIFO::*;
    import ClientServer::*;

    // interface Divider;
    //         interface Put#(Tuple2#(Int#(32), Int#(32))) request;
    //         interface Get#(Maybe#(Int#(32))) response;
    // endinterface : Divider
    //typedef Server#(Tuple2#(Int#(32), Int#(32)), Maybe#(Int#(32))) Divider;
    ////////////////////////////
    module mkDivider(Server#(Tuple2#(Int#(32), Int#(32)), Maybe#(Int#(32))));
        Reg#(Bool) calcReady <- mkReg(False);
        Reg#(Bool) calcBegin <- mkReg(False);

        FIFO#(Tuple2#(Int#(32), Int#(32))) in <- mkFIFO;
        FIFO#(Maybe#(Int#(32))) out <- mkFIFO;

        Reg#(Int#(32)) a <- mkRegU;
        Reg#(Int#(32)) b <- mkRegU;
        Reg#(Int#(32)) res <- mkReg(0);

        rule pushToOutput;
            if(calcReady == True && calcBegin == True) begin
                calcReady <= False;
                calcBegin <= False;
                out.enq(tagged Valid res);
            end
            else
                out.enq(tagged Invalid);
        endrule : pushToOutput

        rule calculate(calcReady == False && calcBegin == True);
            let t = a - b;
            res <= res + 1;
            if( t < b )
                calcReady <= True;
            else begin
                a <= t;
            end
        endrule : calculate

        rule getFromInput(calcBegin == False);
            calcBegin <= True;
            let t = in.first;
            in.deq;
            a <= tpl_1(t);
            b <= tpl_2(t);
        endrule

        interface request = toPut (in);
        interface response = toGet (out);
    endmodule : mkDivider


endpackage : impl