package impl;

    import Vector::*;

    interface Stack;
        method Action push(Int#(32) value);
        method ActionValue#(Int#(32)) pop();
        method Int#(32) peek();
        method Int#(32) size();
    endinterface

    function Action printTimed(String f);
      $display("[%03d] %s", $time, f);
    endfunction


    typedef 5 Capacity;
    typedef TLog#(TAdd#(Capacity,1)) Stackpointer_size ;

    module mkStack(Stack);
        Reg#(UInt#(Stackpointer_size)) stackpointer[2] <- mkCReg(2, 0);
        Vector#(Capacity, Array#(Reg#(Int#(32)))) stack <- replicateM(mkCReg(2, 0));
        method Action push(Int#(32) value) if(stackpointer[0] < fromInteger(valueOf(Capacity)));
          stackpointer[0] <= stackpointer[0] + 1;
          stack[stackpointer[0]][0] <= value;
        endmethod
        method ActionValue#(Int#(32)) pop(); //if(stackpointer[1] > 0);
          stackpointer[1] <= stackpointer[1] - 1;  
          let t = stack[stackpointer[1]-1][1];
          return t;
        endmethod
        method Int#(32) peek() if(stackpointer[1] > 0);
          return stack[stackpointer[1]-1][1];
        endmethod

      method Int#(32) size();
        return unpack(pack(extend(stackpointer[1])));
      endmethod
    endmodule


endpackage : impl