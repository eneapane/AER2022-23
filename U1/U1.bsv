package U1;

    interface Blinky;
        method Bool blink();

        method Action start();

        method ActionValue#(int) stop();
    endinterface : Blinky
    //-------------------------------------------------------------
    (* synthesize *)
    module mkBlinky(Blinky);
        //ein Register, das angibt, ob das Modul eingeschaltet ist
        Reg#(Bool) ctrl_on <- mkReg(False);
        //ein Register, das den Status der LED angibt
        Reg#(Bool) led_on <- mkReg(False);
        //ein weiteres Register, das zählt, wie oft die LED eingeschaltet wurde
        Reg#(int) blink_ctr <- mkRegU;
    

        rule count(ctrl_on);
            Bool led_new = !led_on;
            if(led_new) begin
                blink_ctr <= blink_ctr + 1;
            end
                led_on <= led_new;
        endrule : count
        
        method Bool blink();
            return led_on;
        endmethod : blink

        method Action start() if (!ctrl_on);
            blink_ctr <= 0;
            ctrl_on <= True;
        endmethod : start

        method ActionValue#(int) stop() if (ctrl_on);
            led_on <= False;
            ctrl_on <= False;
            return blink_ctr;
        endmethod : stop
    endmodule : mkBlinky

endpackage : U1