package testbench;
 
import StmtFSM::*;
 
import impl::*;
 
module mkTestbench();
 
    let door <- mkDoor;
 
    Reg#(DoorSensor) sensor_dummy <- mkRegU;
    Reg#(LightBarrier) lightbarrier_dummy <- mkRegU;
    Reg#(Event) button_dummy <- mkRegU;
 
    //"connect" dummy sensors and button to door and satisfy "always_enabled" attribute
    rule send_dummy_sensor_data;
        door.lightbarrier(lightbarrier_dummy);
        door.sensor(sensor_dummy);
        door.send_event(button_dummy);
    endrule
 
    Stmt s = seq
        sensor_dummy <= FullyOpened;
        lightbarrier_dummy <= Clear;
        button_dummy <= NoEvent;
        printTimed("Started");
        action
            await(door.door_state == Closing); //wait until door leaves startup
            printTimed("Door now closing");
        endaction
        action
            printTimed("Obstructing door while closing");
            lightbarrier_dummy <= Obstructed; //obstruct door
            sensor_dummy <= HalfOpen;
        endaction
        delay(10); //after obstructing the closing door, it will open again and wait until its fully opened
        //clear obstruction after arbitrary delay
        action
            lightbarrier_dummy <= Clear;
            printTimed("Cleared obstruction");
        endaction
        //after obstruction is cleared, door should open again
        action
            await(door.door_state == Opening);
            printTimed("Door opening after obstruction was cleard");
        endaction
        delay(2); //arbitrary delay until door is considered open again
        sensor_dummy <= FullyOpened;
        action
            await(door.door_state == Opened); //door should be open after
            printTimed("Door opened"); //door will stay open for 10 cycles
        endaction
        action
            await(door.door_state == Closing);
            printTimed("Door closing again due to timeout");
        endaction
        delay(2); //door considered closed after arbitrary delay 
        sensor_dummy <= FullyClosed;
        action
            await(door.door_state == Closed); //wait for door to close
            printTimed("Door now closed");
        endaction
        button_dummy <= Open; //button to open door is pressed
        action
            await(door.door_state == Opening); //after button was pressed, door should open
            printTimed("Door opening after button press");
            button_dummy <= NoEvent;
        endaction
        delay(2); //arbitrary delay until door is considered open again
        sensor_dummy <= FullyOpened;
        action
            await(door.door_state == Opened); //door should be open after
            printTimed("Door opened"); //door will stay open for 10 cycles
        endaction
    endseq;
 
    mkAutoFSM(s);
 
endmodule
 
endpackage