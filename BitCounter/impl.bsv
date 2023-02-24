package Impl;

    interface BitCounter;
        method Action set(Int#(32) px);
        method Int#(32) getZeros();
        method Int#(32) getOnes();
    endinterface : BitCounter

    module mkMultipleCyclesCounter(BitCounter);
        Reg#(Int#(32)) zeros <- mkReg(0);
        Reg#(Int#(32)) ones <- mkReg(0);

        Reg#(Int#(32)) current <- mkRegU;
        Reg#(UInt#(32)) index <- mkRegU;
        Reg#(Bool) calculating <- mkReg(False);

        rule calculate(calculating && index < 32);
            let new_zeros = zeros;
            let new_ones = ones;
            if(pack(current)[index] == 0)
                new_zeros = new_zeros + 1;
            else
                new_ones = new_ones + 1;
            zeros <= new_zeros;
            ones <= new_ones;
            index <= index + 1;
        endrule

        rule fin(calculating && index == 32);
            calculating <= False;
        endrule

        method Action set(Int#(32) px) if(!calculating);
            current <= px;
            index <= 0;
            zeros <= 0;
            ones <= 0;
            calculating <= True;
        endmethod

        method Int#(32) getZeros() if(!calculating);
            return zeros;
        endmethod

        method Int#(32) getOnes() if(!calculating);
            return ones;
        endmethod
    endmodule

    module mkOneCycleCounter(BitCounter);
        Reg#(Int#(32)) zeros <- mkReg(0);
        Reg#(Int#(32)) ones <- mkReg(0);

        Reg#(Int#(32)) current <- mkRegU;
        Reg#(Bool) running <- mkReg(False);

        rule calculate (running);
            Bit#(32) sumZeros= 0;
            Bit#(32) sumOnes = 0;
            for(Integer i = 0; i < 32; i = i + 1) begin
                if(pack(current)[i] == 0)
                    sumZeros = sumZeros + 1;
                else
                    sumOnes = sumOnes + 1;
            end
            zeros <= unpack(sumZeros);
            ones <= unpack(sumOnes);
            running <= False;
        endrule : calculate

        method Action set(Int#(32) px) if (!running);
            current <= px;
            running <= True;
        endmethod

        method Int#(32) getZeros() if(!running);
            return zeros;
        endmethod : getZeros

        method Int#(32) getOnes() if(!running);
            return ones;
        endmethod : getOnes
    endmodule : mkOneCycleCounter

    module mkTrueOneCycleCounter(BitCounter);
        Wire#(Int#(32)) zeros <- mkWire;
        Wire#(Int#(32)) ones <- mkWire;
        Wire#(Int#(32)) current <- mkWire;

        rule calculate;
            Bit#(32) sumZeros= 0;
            Bit#(32) sumOnes = 0;
            for(Integer i = 0; i < 32; i = i + 1) begin
                if(pack(current)[i] == 0)
                    sumZeros = sumZeros + 1;
                else
                    sumOnes = sumOnes + 1;
            end
            zeros <= unpack(sumZeros);
            ones <= unpack(sumOnes);
        endrule : calculate

        method Action set(Int#(32) px);
            current <= px;
        endmethod

        method Int#(32) getZeros();
            return zeros;
        endmethod

        method Int#(32) getOnes();
            return ones;
        endmethod
    endmodule

endpackage