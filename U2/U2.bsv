package U2;
  import FIFOF::*;
  import Vector::*;
    //-----------------------------------------------------------
    interface CalcUnit;
      method Action put(Int#(32) x);
      method ActionValue#(Int#(32)) result();
    endinterface
    //-----------------------------------------------------------
    interface CalcUnitChangeable;
      interface CalcUnit calc;
      method Action setParameter(Int#(32) param);
    endinterface
    //-----------------------------------------------------------
    interface Pipeline;
        interface CalcUnit calc;
        method Action setParam(UInt#(2) addr, Int#(32) val);
    endinterface
    //-----------------------------------------------------------
    module mkSimplePipeline(Pipeline);
      FIFOF#(int) in_fifo <- mkFIFOF;
      Reg#(Maybe#(int)) aReg <- mkReg(Invalid);
      Reg#(Maybe#(int)) bReg <- mkReg(Invalid);
      Reg#(Maybe#(int)) cReg <- mkReg(Invalid);
      Reg#(Maybe#(int)) reg4 <- mkReg(Invalid);
      FIFOF#(int) out_fifo  <- mkFIFOF;

      Vector#(3, Reg#(int)) parameters <- replicateM(mkRegU);
      

      //flag registers, to be decided
      Vector#(3, Reg#(Bool)) parameterSet <- replicateM(mkReg(False));

      rule propagate(parameterSet[0] && parameterSet[1] && parameterSet[2]);
        if(in_fifo.notEmpty) begin
          aReg <= tagged Valid(in_fifo.first() + parameters[0]);
          in_fifo.deq();
        end
        else aReg <= tagged Invalid;

        if(aReg matches tagged Valid .val)
          bReg <= tagged Valid(val*parameters[1]);
        else
          bReg <= tagged Invalid;

        if(bReg matches tagged Valid .val)
          cReg <= tagged Valid(val*parameters[2]);
        else
          cReg <= tagged Invalid;

        if(cReg matches tagged Valid .val)
          reg4 <= tagged Valid(val/4);
        else
          reg4 <= tagged Invalid;

        if(reg4 matches tagged Valid .val &&& out_fifo.notFull)
          out_fifo.enq(val + 128);
      endrule : propagate

      method Action setParam(UInt#(2) addr, Int#(32) val);
        parameters[addr] <= val;
        parameterSet[addr] <= True;
      endmethod : setParam

      interface calc =  interface CalcUnit;
                          method Action put(Int#(32) x);
                            in_fifo.enq(x);
                          endmethod
                          method ActionValue#(Int#(32)) result();
                            let out = out_fifo.first;
                            out_fifo.deq;
                            return out;
                          endmethod
                        endinterface;

    endmodule : mkSimplePipeline //statisch und starr
endpackage