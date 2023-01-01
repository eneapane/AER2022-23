package ALU;
    typedef enum{Mul,Div,Add,Sub,And,Or, Pow} AluOps deriving (Eq, Bits);
    //---------------------------------------------------------------
    interface HelloALU;
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
        method ActionValue#(Int#(32)) getResult();
    endinterface : HelloALU
    //--------------------------------------------------------------
    module mkPower(HelloALU);
        Reg#(Int#(32)) regA <- mkRegU;
        Reg#(Int#(32)) regB <- mkRegU;
        Reg#(Int#(32)) result <- mkRegU;
        Reg#(Bool) resultValid <- mkReg(False);

        
        rule calc(regB > 0);
            regB <= regB - 1;
            result <= result * regA;
        endrule : calc

        rule calcDone (regB == 0 && !resultValid);
            resultValid <= True;
        endrule : calcDone

        method ActionValue#(Int#(32)) getResult() if (resultValid);
            resultValid <= False;
            return regA;
        endmethod : getResult
        
        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b);
            regA <= a;
            regB <= b;
            result <= 1;
            resultValid <= False;
        endmethod : setupCalculation
    endmodule : mkPower
    //--------------------------------------------------------------
    module mkSimpleALU(HelloALU);
        Reg#(Bool) operationReady <- mkReg(False);
        Reg#(Bool) newOperands <- mkReg(True);
        
        Reg#(Int#(32)) result <- mkRegU;
        Reg#(Int#(32)) regA <- mkRegU;
        Reg#(Int#(32)) regB <- mkRegU;
        Reg#(AluOps) regOp <- mkRegU;

        HelloALU pow <- mkPower;


        

        rule calculate(!operationReady && newOperands);
            let rTmp = 0;
            case(regOp)
                Mul : rTmp = regA * regB;
                Div : rTmp = regA / regB;
                Add : rTmp = regA + regB;
                Sub : rTmp = regA - regB;
                And : rTmp = regA & regB;
                Or : rTmp = regA | regB;
                Pow : rTmp <- pow.getResult();
                default : $display("Operation not defined");
            endcase
            operationReady <= True;
            newOperands <= False;
            result <= rTmp;
        endrule : calculate

        method ActionValue#(Int#(32)) getResult() if(operationReady);
            operationReady <= False;
            return result;
        endmethod : getResult

        method Action setupCalculation(AluOps op, Int#(32) a, Int#(32) b) if (!newOperands);
            regA <= a;
            regB <= b;
            regOp <= op;
            newOperands <= True;
            operationReady <= False;
            if(op == Pow) pow.setupCalculation(op, a, b);
        endmethod : setupCalculation
        
    endmodule : mkSimpleALU
    //-----------------------------------------------------------------------------------
    module mkALUTestbench(Empty);
        HelloALU uut <- mkSimpleALU;
        Reg#(UInt#(8)) testState <- mkReg(0);
    
        rule checkMul (testState == 0);
            uut.setupCalculation(Mul, 4,5);
            testState <= testState + 1;
        endrule
    
        rule checkDiv (testState == 2);
            uut.setupCalculation(Div, 12,4);
            testState <= testState + 1;
        endrule
    
        rule checkAdd (testState == 4);
            uut.setupCalculation(Add, 12,4);
            testState <= testState + 1;
        endrule
            
        rule checkSub (testState == 6);
            uut.setupCalculation(Sub, 12,4);
            testState <= testState + 1;
        endrule
    
        rule checkAnd (testState == 8);
            uut.setupCalculation(And, 32'hA,32'hA);
            testState <= testState + 1;
        endrule
    
        rule checkOr (testState == 10);
            uut.setupCalculation(Or, 32'hA,32'hA);
            testState <= testState + 1;
        endrule
    
        rule checkPow (testState == 12);
            uut.setupCalculation(Pow, 2, 12);
            testState <= testState + 1;
        endrule
    
        rule printResults (unpack(pack(testState)[0]));
            $display("Result: %d", uut.getResult());
            testState <= testState + 1;
        endrule
    
        rule endSim (testState == 14);
            $finish();
        endrule
    endmodule : mkALUTestbench
endpackage : ALU