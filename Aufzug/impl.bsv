package impl;
 
import StmtFSM :: *;
import FIFO :: *;
import FIFOF :: *;
 
function Action printTimed(String f);
    $display("[%03d] %s", $time, f);
endfunction
 
typedef enum { FullyClosed, HalfOpen, FullyOpened } DoorSensor deriving(Eq, Bits);
typedef enum { Clear, Obstructed } LightBarrier deriving(Eq, Bits);
typedef enum { Open, NoEvent } Event deriving(Eq, Bits);
typedef enum { Start, Wait, Closing, Closed, Opening, Opened } State deriving(Eq, Bits);
 
interface Door_ifc;
    (* always_enabled *) 
    method Action send_event(Event ev);
    (* always_enabled *) 
    method Action lightbarrier(LightBarrier sens);
    (* always_enabled *) 
    method Action sensor(DoorSensor sens);
    method State door_state(); //only for debugging from outside
endinterface
 
module mkDoor(Door_ifc);
 
    Integer initial_timer = 5;
 
    Reg#(State) state <- mkRegU;
    Reg#(UInt#(8)) timer <- mkRegU;
 
    Wire#(LightBarrier) light_barrier <- mkBypassWire;
    Wire#(DoorSensor) door_sensor <- mkBypassWire;
    Wire#(Event) input_event <- mkBypassWire;
 
    Stmt s = seq
        state <= Start;
        //T1
        timer <= fromInteger(initial_timer);
        state <= Wait;
        //Wait
        while(timer > 0) action
            timer <= timer - 1;
        endaction
        //T3 timer is now implicit ==0

        while(True) seq //since there's a cycle in the FSM graph
            //Closing
            await(light_barrier == Obstructed || door_sensor == FullyClosed);

            if(light_barrier == Obstructed) 
                state <= Opening;
            else seq
                state <= Closed;
                await(input_event == Open);
                state <= Opening;
            endseq
            //the state is now, independent from the graph path taken before, Opening
            timer <= unpack(10);
            await(door_sensor == FullyOpened); //T10

            while(timer > 0) 
                timer <= timer - 1;
            
            state <= Closing;
        endseq

    endseq;
 
    mkAutoFSM(s);
 
    //...
    method Action send_event(Event ev); input_event <= ev; endmethod
    method Action lightbarrier(LightBarrier sens); light_barrier <= sens; endmethod
    method Action sensor(DoorSensor sens); door_sensor <= sens; endmethod
    method State door_state(); return state; endmethod
 
endmodule




endpackage
