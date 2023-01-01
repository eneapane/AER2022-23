package Top;
    import FIFO::*;
    import GetPut::*;
    import ClientServer::*;
    import Vector::*;
    import Buffer::*;
    import Settings::*;
    import MyTypes::*;
    import RowBuffer::*;
    import Gauss::*;
    import DReg::*;

    typedef Server#(GrayScale, GrayScale) AcceleratorServer;

    interface Accelerator;
        interface AcceleratorServer server;
        method Action setRes(UInt#(32) n_pixels);
        (* always_ready *)
        method Bool irq();
        method Action ack();
    endinterface

    module mkGaussAccelerator(Accelerator);
        // TODO: Task 4.1 implementation

        // TODO: Task 4.1 setRes implementation

        method Bool irq();
            return False; // TODO: 4.3
        endmethod

        method Action ack();
            noAction; // TODO: 4.3
        endmethod

        // TODO: Task 4.1 subinterface definition

    endmodule

endpackage