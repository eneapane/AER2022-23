package impl;
    import ClientServer::*;
    import GetPut::*;
    import FIFO::*;
    

    typedef Server#(Int#(5), Maybe#(Int#(5))) GrayCode;

    module mkGrayCode(GrayCode);
        Reg#(Int#(5)) size <- mkReg(0);
        Reg#(Int#(5)) currentSize <- mkReg(0);
        FIFO#(Maybe#(Int#(5))) out <- mkFIFO;
        
        rule queue;    
            if(currentSize < size) begin
                //$display("Queue Rule is executed, size = %d, currentSize = %d", size, currentSize);
                let t = pack(currentSize) ^ (pack(currentSize) >> 1);
                out.enq(tagged Valid unpack(t));
                currentSize <= currentSize + 1;
            end
            else begin 
                size <= 0;
                currentSize <= 0; 
                out.enq(tagged Invalid);
            end
        endrule : queue
        
        interface Put request;
             method Action put(Int#(5) px);
                size <= px;
                currentSize <= 0; 
             endmethod : put
        endinterface : request
        interface response = toGet(out);
    endmodule : mkGrayCode


endpackage : impl