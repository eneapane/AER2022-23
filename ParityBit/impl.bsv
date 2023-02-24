package impl;
    
    interface ParityCalculator;
        method Action set(Int#(32) px);
        method ActionValue#(Int#(1)) get();
    endinterface : ParityCalculator

    module mkParityCalculator(ParityCalculator);
        Wire#(Int#(32)) in <- mkDWire(0);
        Reg#(Int#(1)) parity <- mkReg(0);
        Wire#(Bool) calculating <- mkDWire(False);

        
        rule calculate(calculating);
            Bit#(32) sum = 0;
            for(Integer i = 0; i < 32; i = i + 1) begin
                sum = sum + extend(pack(in)[i]);
            end
            $display("Sum %d", sum);
            let flag = sum[0] == 0;
            parity <= flag ? unpack(0) : unpack(1);
        endrule : calculate

        method Action set(Int#(32) px);
            in <= px;
            calculating <= True;
        endmethod

        method ActionValue#(Int#(1)) get();
            let result = parity;
            return result;
        endmethod : get

    endmodule : mkParityCalculator
endpackage : impl