package impl;
    interface Counter;
        method Action setMaxValue(UInt#(32) px);
        method Action increment(Int#(32) px);
        method Action decrement(Int#(32) px);
        method Action resetCounter();
        method Int#(32) get();
    endinterface : Counter

    module mkSaturatedCounter(Counter);
        Reg#(Int#(32)) value <- mkReg(0);
        Wire#(Int#(32)) inc <- mkDWire(0);
        Wire#(Int#(32)) dec <- mkDWire(0);
        Wire#(Bool) resetFlag <- mkDWire(False);

        Reg#(Int#(32)) maxValue <- mkRegU;
        Reg#(Int#(32)) minValue <- mkRegU;
        Reg#(Bool) extremaSet <- mkReg(False);

        rule calculate(extremaSet);
            let t = value + inc - dec;
            if(t > maxValue) t = maxValue;
            else if(t < minValue) t = minValue;
            else if(resetFlag) t = 0;
            value <= t;
        endrule : calculate

        method Action setMaxValue(UInt#(32) px);
            Int#(32) t = unpack(pack(px));
            maxValue <= t;
            minValue <= (-1)*t;
            extremaSet <= True;
        endmethod : setMaxValue

        method Action increment(Int#(32) px) if (extremaSet);
            inc <= px;
        endmethod : increment

        method Action decrement(Int#(32) px) if (extremaSet);
            dec <= px;
        endmethod : decrement

        method Action resetCounter() if (extremaSet);
            resetFlag <= True;
        endmethod : resetCounter

        method Int#(32) get() if (extremaSet);
            let val = value;
            return val;
        endmethod : get
    endmodule : mkSaturatedCounter


    module mkOverflowCounter(Counter);
        Reg#(Int#(32)) value <- mkReg(0);
        Wire#(Int#(32)) inc <- mkDWire(0);
        Wire#(Int#(32)) dec <- mkDWire(0);
        Wire#(Bool) resetFlag <- mkDWire(False);

        Reg#(Int#(32)) maxValue <- mkRegU;
        Reg#(Int#(32)) minValue <- mkRegU;
        Reg#(Bool) extremaSet <- mkReg(False);

        rule calculate(extremaSet);
            Int#(32) t = value + inc - dec;
            if(t > maxValue) t = minValue + (t - maxValue);
            else if(t < minValue) t = maxValue;
            else if(resetFlag) t = 0;
            value <= t;
        endrule : calculate

        method Action setMaxValue(UInt#(32) px);
            Int#(32) t = unpack(pack(px));
            maxValue <= t;
            minValue <= (-1)*t;
            extremaSet <= True;
        endmethod : setMaxValue

        method Action increment(Int#(32) px) if (extremaSet);
            inc <= px;
        endmethod : increment

        method Action decrement(Int#(32) px) if (extremaSet);
            dec <= px;
        endmethod : decrement

        method Action resetCounter() if (extremaSet);
            resetFlag <= True;
        endmethod : resetCounter

        method Int#(32) get() if (extremaSet);
            let val = value;
            return val;
        endmethod : get
    endmodule : mkOverflowCounter

endpackage : impl