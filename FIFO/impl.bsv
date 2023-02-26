package impl;

    import Vector::*;
    interface MyFIFO;
        method Action enq(Int#(32) px);
        method Action deq();
        method ActionValue#(Maybe#(Int#(32))) first(); 
    endinterface : MyFIFO

    function Action printTimed(String f);
      $display("[%03d] %s", $time, f);
    endfunction

    typedef 5 Capacity;
    typedef TAdd#(1, TLog#(TAdd#(Capacity,1))) Stackpointer_size ;

    module mkMyFIFO(MyFIFO);
        //Reg#(UInt#(Stackpointer_size)) stackpointer[2] <- mkCReg(2, 0);
        Reg#(Int#(Stackpointer_size)) size[3] <- mkCReg(3, 0); //0 as the FIFO is initially empty
        Vector#(5, Array#(Reg#(Maybe#(Int#(32))))) stack <- replicateM(mkCReg(3, tagged Invalid));
        
        method Action enq(Int#(32) value) if(size[0] < fromInteger(valueOf(Capacity)));
          $display("In enqueue");
          size[0] <= size[0] + 1;
          stack[size[0]][0] <= tagged Valid value;
          $display("ENQUEUE -> Value: %d and size : %d", value, size[0]);
        endmethod
        
        method Action deq(); //if(stackpointer[1] > 0);
            $display("In dequeue");
            $display("DEQUEUE -> STACK: %d", stack[0][2]);
            size[2] <= size[2] - 1;
            stack[0][2] <= tagged Invalid; 
        endmethod
        method ActionValue#(Maybe#(Int#(32))) first(); // if(size[1] >= 0);
            //$display("size: %d, stack: %d, %d, %d, %d, %d", size[2], stack[0][2], stack[1][2], stack[2][2], stack[3][2], stack[4][2]);
            noAction;
            return stack[0][1];
        endmethod
    endmodule : mkMyFIFO



endpackage : impl