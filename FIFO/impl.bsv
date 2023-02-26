package impl;

    import Vector::*;
    interface MyFIFO;
        method Action enq(Int#(32) px);
        method Action deq();
        method Int#(32) first(); 
    endinterface : MyFIFO

    function Action printTimed(String f);
      $display("[%03d] %s", $time, f);
    endfunction

    typedef 7 Capacity;
    typedef TAdd#(1, TLog#(TAdd#(Capacity,1))) Stackpointer_size ;

    module mkMyFIFO(MyFIFO);
        Reg#(Int#(Stackpointer_size)) size[2] <- mkCReg(2, 0); //0 as the FIFO is initially empty
        Vector#(Capacity, Array#(Reg#(Int#(32)))) stack <- replicateM(mkCReg(2, -1));
        
        method Action enq(Int#(32) value) if(size[0] < fromInteger(valueOf(Capacity)));
          size[0] <= size[0] + 1;
          stack[size[0]][0] <= value;
        endmethod
        
        method Action deq() if(size[1] > 0);
            size[1] <= size[1] - 1;
            for(Integer i = 1; i < valueOf(Capacity); i = i + 1) begin
                stack[i - 1][1] <= stack[i][1];
            end
        endmethod
        method (Int#(32)) first() if(size[1] > 0);
            return stack[0][1];
        endmethod
    endmodule : mkMyFIFO



endpackage : impl