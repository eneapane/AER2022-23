package impl;

    import Vector::*;

    interface Stack;
        method Action push(Int#(32) value);
        method ActionValue#(Int#(32)) pop();
        method Int#(32) peek();
        method Int#(32) size();
        method Action show();
    endinterface

    module mkStack(Stack);
        Reg#(Int#(32)) current_size[2] <- mkCReg(2, 0);
        //Vector(5, Reg#(Int#(32))) regs <- replicateM(mkRegU);
        Vector#(5, Array#(Reg#(Maybe#(Int#(32))))) regs <- replicateM(mkCReg(2, tagged Invalid));

        method Int#(32) peek() if (current_size[0] != 0);
            return -1; // fromMaybe(0, regs[current_size[0] - 1][1]);
        endmethod : peek

        method Action push(Int#(32) value);
            if(current_size[0] != 5) begin
                regs[current_size[0]][0] <= tagged Valid value;
                current_size[0] <= current_size[0] + 1;
            end
        endmethod : push
        
        method ActionValue#(Int#(32)) pop();
            if(current_size[1] != 0) begin
                current_size[1] <= current_size[1] - 1;
                regs[current_size[1] - 1][1] <= tagged Invalid;
                return fromMaybe(0, regs[current_size[1] - 1][1]);
            end
            else
                return -1;
        endmethod : pop

        method Int#(32) size();
            return current_size[1];
        endmethod : size

        method Action show();
            for(int i = 0; i < current_size[1]; i = i + 1) begin
                $display("%d", regs[i][1]);
            end
        endmethod : show
    endmodule : mkStack


endpackage : impl