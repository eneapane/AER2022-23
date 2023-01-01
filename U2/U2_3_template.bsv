package U2;

    interface CalcUnit;
      method Action put(Int#(32) x);
      method ActionValue#(Int#(32)) result();
    endinterface

    interface CalcUnitChangeable;
      interface CalcUnit calc;
      method Action setParameter(Int#(32) param);
    endinterface

    interface Pipeline;
        interface CalcUnit calc;
        method Action setParam(UInt#(2) addr, Int#(32) val);
    endinterface


endpackage