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
        Reg#(Int#(32)) current_size[3] <- mkCReg(3, 0);
        Vector#(5, Array#(Reg#(Maybe#(Int#(32))))) regs <- replicateM(mkCReg(2, tagged Invalid));
        Reg#(Bool) flag[3] <- mkCReg(3, False);
        Wire#(Int#(32)) inputValue <- mkWire;

        rule resetFlag;
            flag[2] <= False;
        endrule 

        for(Integer i = 0; i < 5; i = i + 1) begin
            rule pushRule(flag[1] == True);
                current_size[2] <= current_size[1] + 1;
                regs[current_size[1] - 1][1] <= tagged Valid inputValue;
            endrule : pushRule
        end

        for(Integer i = 0; i < 5; i = i + 1) begin
            rule popValue(flag[0] == True);
                Int#(32) newValue = current_size[0] - 1;
                current_size[1] <= newValue;
                regs[current_size[0] - 1][0] <= tagged Invalid;
            endrule
        end

        method Int#(32) peek() if (current_size[0] != 0);
            return fromMaybe(0, regs[current_size[0] - 1][0]);
        endmethod : peek

        method Action push(Int#(32) value) if(current_size[1] != 5);
            flag[1] <= True;
            inputValue <= value;
        endmethod : push
        
        method ActionValue#(Int#(32)) pop() if (current_size[0] != 0);
            flag[0] <= True;
            return fromMaybe(0, regs[current_size[0] - 1][0]);
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