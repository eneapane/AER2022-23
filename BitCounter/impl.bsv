package impl;

    import FIFO::*;

    interface BitCounter;
        method Action set(Int#(32) px);
        method ActionValue#(Int#(32)) getZeros();
        method ActionValue#(Int#(32)) getOnes();
    endinterface : BitCounter

    module mkMultipleCyclesCounter(BitCounter);
        Reg#(Int#(32)) zeros <- mkReg(0);
        Reg#(Int#(32)) ones <- mkReg(0);

        Wire#(Int#(32)) in <- mkDWire(0);
        Wire#(Bool) calculating <- mkDWire(False);

        
        rule calculate(calculating);
            Bit#(32) sumZeros= 0;
            Bit#(32) sumOnes = 0;
            for(Integer i = 0; i < 32; i = i + 1) begin
                if(pack(in)[i] == 0)
                    sumZeros = sumZeros + 1;
                else
                    sumOnes = sumOnes + 1;
            end
            zeros <= unpack(sumZeros);
            ones <= unpack(sumOnes);
        endrule : calculate

        method Action set(Int#(32) px);
            in <= px;
            calculating <= True;
        endmethod

        method ActionValue#(Int#(32)) getZeros();
            noAction;
            let result = zeros;
            return result;
        endmethod : getZeros

        method ActionValue#(Int#(32)) getOnes();
            noAction;
            let result = ones;
            return result;
        endmethod : getOnes
    endmodule : mkMultipleCyclesCounter

    
    module mkOneCycleCounter(BitCounter);
        FIFO#(Int#(32)) in <- mkFIFO;
        FIFO#(Int#(32)) outZeros <- mkFIFO;
        FIFO#(Int#(32)) outOnes <- mkFIFO;
        function Int#(32) calc(Bit#(1) b, Bit#(32) d);
            Int#(32) sum = 0;
            for(int i = 0; i < 32; i = i + 1) begin
                if(b == d[i]) sum = sum + 1;
            end
            return sum;
        endfunction

        rule calculate;
            let t = pack(in.first);
            in.deq();
            let t1 = calc(0, t);
            outZeros.enq(t1);
            let t2 = calc(1, t);
            outOnes.enq(t2);
        endrule : calculate

        method Action set(Int#(32) px);
            in.enq(px);
        endmethod

        method ActionValue#(Int#(32)) getZeros();
            outZeros.deq();
            let t = outZeros.first;
            return t;
        endmethod : getZeros

        method ActionValue#(Int#(32)) getOnes();
            let t = outOnes.first;
            outOnes.deq;
            return t;
        endmethod : getOnes
    endmodule : mkOneCycleCounter

endpackage : impl