package U3;
    import U2::*;
    import Wire::*;


    module mkAddA(CalcUnitChangeable)
        Reg#(int) paramReg <- mkRegU;
        Reg#(Bool) initialized <- mkReg(False); 
        Wire#(int) result <- mkWire;
        method Action setParameter(Int#(32) param);
            paramReg <= param;
            initialized <= True;
        endmethod : setParam
        interface calc =    interface CalcUnit;
                                method Action put(Int#(32) x) if (initialized);
                                    result <= x + param;
                                endmethod
                                method ActionValue#(Int#(32)) result();
                                    noAction;
                                    return result;
                                endmethod
                            endinterface;
    endmodule : mkAddA
    //----------------------------------
    module mkMul(CalcUnitChangeable)
        Reg#(int) paramReg <- mkRegU;
        Reg#(Bool) initialized <- mkReg(False); 
        Wire#(int) result <- mkWire;
        method Action setParameter(Int#(32) param);
            paramReg <= param;
            initialized <= True;
        endmethod : setParam
        interface calc =    interface CalcUnit;
                                method Action put(Int#(32) x) if (initialized);
                                    result <= x * param;
                                endmethod
                                method ActionValue#(Int#(32)) result();
                                    noAction;
                                    return result;
                                endmethod
                            endinterface;
    endmodule : mkMul                            
    //------------------------
    module mkDiv4(CalcUnit);
        Wire#(int) result <- mkWire;
        method Action put(Int#(32) x);
            result <= x / 4;
        endmethod : put
        method ActionValue#(Int#(32)) result();
            noAction;
            return result;
        endmethod
    endmodule : mkDiv4
    //------------------------
    module mkAdd128(CalcUnit);
        Wire#(int) result <- mkWire;
        method Action put(Int#(32) x);
            result <= x + 128;
        endmethod : put
        method ActionValue#(Int#(32)) result();
            noAction;
            return result;
        endmethod
    endmodule : mkAdd128
    //---------------------------------------------
    // Alternative multiply implementation which requires a variable amount of cycles
module mkMulVariable(CalcUnitChangeable);
    Reg#(Int#(32)) p <- mkRegU;
    Reg#(Int#(32)) a <- mkRegU;
    Reg#(Int#(32)) b <- mkRegU;
    Reg#(Int#(32)) w <- mkRegU;
    Reg#(Bool) got_in <- mkReg(False);

    rule compute (b != 0 && got_in);
        if (lsb(b) == 1) w <= w + a;
        a <= a << 1;
        b <= b >> 1;
    endrule

    method Action setParameter(Int#(32) param);
        p <= param;
    endmethod

    interface CalcUnit calc;
        method Action put(Int#(32) x) if (!got_in);
            a <= x;
            b <= p;
            w <= 0;
            got_in <= True;
        endmethod
      
        method ActionValue#(Int#(32)) result() if (b == 0 && got_in);
            got_in <= False;
            return w;
        endmethod
    endinterface
endmodule
    //----------------------
    module mkPipeline(Pipeline);
        FIFOF#(int) in_fifo <- in_fifo;
        FIFOF#(int) out_fifo <- out_fifo; 

        Vector(3, CalcUnitChangeable) parametrizedModules <- newVector;
        parametrizedModules[0] <- mkAddA;
        parametrizedModules[1] <- mkMul;
        parametrizedModules[2] <- mkMul;

        Calcunit module4 <- mkDiv4;
        Calcunit module128 <- mkAdd128;

        Vector(5, CalcUnit) stages <- newVector;
        stages[0] = parametrizedModules[0].calc;
        stages[1] = parametrizedModules[1].calc;
        stages[2] = parametrizedModules[2].calc;
        stages[3] = parametrizedModules[3].calc;
        stages[4] = parametrizedModules[4].calc;

        Vector#(4, Array#(Reg#(Maybe#(Int#(32))))) regs <- replicateM(mkCReg(2, tagged Invalid));

        function Bool setParamAllowed();
            Bool allDone = !in_fifo.notEmpty();
            for(Integer i = 0; i < 2; i = i + 1) allDone = allDone &&& regs[i][0] matches tagged Invalid ? True : False;
            return allDone;
        endfunction

        for(Integer i = 0; i < 5; i = i + 1) begin
            rule push;
                if (i == 0)
                    stages[i].put(in_fifo.first);
                else if (regs[i-1][0] matches tagged Valid .x)
                    stages[i].put(x);
            endrule
        end

        rule pull_0 if(regs[0][1] matches tagged Invalid);
            in_fifo.deq();
            let t <- stages[0].result();
            regs[0][1] <= tagged Valid t;
        endrule

        for(Integer i = 1; i < 4; i = i + 1) begin
            rule pull if (regs[i][1] matches tagged Invalid &&& isValid(regs[i-1][0]));
                regs[i-1][0] <= tagged Invalid;
                let t <- stages[i].result();
                regs[i][1] <= tagged Valid t;
            endrule
        end
        
        rule pull_4 if(isValid(regs[3][0]));
            regs[3][0] <= tagged Invalid;
            let t <- stages[4].result();
            out_fifo.enq(t);
        endrule
    
        method Action setParam(UInt#(2) addr, Int#(32) val) if(setParamAllowed);
            changeables[addr].setParameter(val);
        endmethod
        


        interface calc =interface Calcunit;
                            method Action put(Int#(32) x);
                                in_fifo.enq(x);
                            endmethod
                            method ActionValue#(Int#(32)) result();
                                let x <- out_fifo.first();1
                                out_fifo.deq();
                                return x;
                            endmethod
                        endinterface;
    endmodule : Pipeline
    //----------------------------------
        



endpackage : U3