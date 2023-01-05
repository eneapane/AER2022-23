package U4;
    typedef union tagged {
        UInt#(32) Unsigned;
        Int#(32) Signed;
    } SignedOrUnsigned deriving(Eq, Bits);
    //--------------------------------
    interface TU_Pipeline
        interface CalcUnit calc;
        method Action setParam(UInt#(2) addr, Int#(32) val);
    endinterface : TU_Pipeline
    //--------------------------------
    interface CalcUnit;
        method Action put(SignedOrUnsigned x);
        method ActionValue#(SignedOrUnsigned) result;

    endinterface : CalcUnit
    //--------------------------------
    interface CalcUnitChangeable;
        interface CalcUnit calc;
        method Action setParameter(SignedOrUnsigned param);
    endinterface : CalcUnitChangeable
    //--------------------------------
    module mkAddA(CalcUnitChangeable);
        Reg#(SignedOrUnsigned) paramReg <- mkRegU;
        Wire#(SignedOrUnsigned) m_x <- mkWire; 
        Wire#(SignedOrUnsigned) result <- mkWire;

        rule calculateSigned(paramReg matches tagged Signed .p &&&
                            m_x matches tagged Signed .x);
            result <= tagged Signed (p + x);
        endrule : calculateSigned

        rule calculateUnsigend(paramReg matches tagged Unsigned .p &&&
                                m_x matches Unsigned .x);
            result <= tagged Unsigned (p + x);
        endrule : calculateUnsigend

        rule error(pack(paramReg)[31] != pack(m_x)[31]);
            $display("Are you stupid? The types are incompatible");
        endrule

        method Action setParameter(Int#(32) param);
            paramReg <= param;
            initialized <= True;
        endmethod : setParam
        interface calc =    interface CalcUnit;
                                method Action put(Int#(32) x) if (initialized);
                                    m_x <= x;
                                endmethod
                                method ActionValue#(Int#(32)) result();
                                    noAction;
                                    return result;
                                endmethod
                            endinterface;
    endmodule : mkAddA
    //------------------------------------------------------------------
    module mkMul(CalcUnitChangeable);
        Reg#(SignedOrUnsigned) paramReg <- mkRegU;
        Wire#(SignedOrUnsigned) m_x <- mkWire; 
        Wire#(SignedOrUnsigned) result <- mkWire;

        rule calculateSigned(paramReg matches tagged Signed .p &&&
                            m_x matches tagged Signed .x);
            result <= tagged Signed (p * x);
        endrule : calculateSigned

        rule calculateUnsigend(paramReg matches tagged Unsigned .p &&&
                                m_x matches Unsigned .x);
            result <= tagged Unsigned (p * x);
        endrule : calculateUnsigend

        rule error(pack(paramReg)[31] != pack(m_x)[31]);
            $display("Are you stupid? The types are incompatible");
        endrule

        method Action setParameter(Int#(32) param);
            paramReg <= param;
            initialized <= True;
        endmethod : setParam
        interface calc =    interface CalcUnit;
                                method Action put(Int#(32) x) if (initialized);
                                    m_x <= x;
                                endmethod
                                method ActionValue#(Int#(32)) result();
                                    noAction;
                                    return result;
                                endmethod
                            endinterface;          
    endmodule : mkMul
    //-------------------------------------------------------------------------
    module mkDiv4(CalcUnit);
        Wire#(SignedOrUnsigned) in <- mkWire;
        Wire#(SignedOrUnsigned) out <- mkWire;
        //disadvantage: hardware economy
        Reg#(SignedOrUnsigned) signed4 <- mkReg(tagged Signed(4)); 
        Reg#(SignedOrUnsigned) unsigned4 <- mkReg(tagged Unsigned(4)); 
        rule calculateSigned(in matches tagged Signed .sin);
            out <= tagged Signed(sin / signed4);
        endrule : calculateSigned
    
        rule calculateUnsigned(in matches tagged Unsigned .usin);
            out <= tagged Signed(usin / unsigned4);
        endrule : calculateSigned

        method Action put(SignedOrUnsigned x);
            in <= x;
        endmethod : put
            
        method ActionValue#(SignedOrUnsigned) result;
            noAction;
            return out;
        endmethod : result
    endmodule : mkDiv4

    module mkAdd128(CalcUnit);
        Wire#(SignedOrUnsigned) in <- mkWire;
        Wire#(SignedOrUnsigned) out <- mkWire;
        
    
        rule calculate;
            out <= tagged Signed(in + 128);
        endrule : calculateSigned
        
        method Action put(SignedOrUnsigned x);
            in <= x;
        endmethod : put
            
        method ActionValue#(SignedOrUnsigned) result;
            noAction;
            return out;
        endmethod : result
    endmodule : mkDiv4
    //---------------------------------------------------------------------
    module mkTU_Pipeline(TU_Pipeline);
        CalcUnitChangeable stage0 <- mkAddA;
        CalcUnitChangeable stage1 <- mkMul;
        CalcUnitChangeable stage2 <- mkMul;
        CalcUnit stage3 <- mkDiv4;
        CalcUnit stage4 <- mkAdd128;

        Vector#(3, CalcUnitChangeable) changeables;
        changeables[0] = stage0;
        changeables[1] = stage1;
        changeables[2] = stage2;

        Vector#(5, CalcUnit) stages;
        stages[0] = stage0.calc;
        stages[1] = stage1.calc;
        stages[2] = stage2.calc;
        stages[3] = stage3;
        stages[4] = stage4

        Vector#(6, FIFO#(SignedOrUnsigned)) fifos <- replicateM(mkCReg(2, tagged Invalid));

        for(Integer i = 0; i < 5; i = i + 1) begin
            rule push;
                
                    stages[i].put(fifos[i].first);
                    fifos[i].deq();
            endrule : push
        end

        for(Integer i = 1; i < 6; i = i + 1) begin
            rule pull;
                let t <- stages[i-1].result();
                fifos[i].enq(t);
            endrule
        end

        method Action setParam(UInt#(2) addr, SignedOrUnsigned val);
            changeables[addr].setParameter(val);
        endmethod

        interface CalcUnit calc;
            method Action put(SignedOrUnsigned x);
                fifos[0].enq(x);
            endmethod
    
            method ActionValue#(SignedOrUnsigned result());
                fifos[5].deq();
                return fifos[5].first;
            endmethod
        endinterface
    endmodule : mkTU_Pipeline

endpackage : U4