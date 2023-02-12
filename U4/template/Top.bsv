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
        FIFO#(GrayScale) in <- mkFIFO();
        FIFO#(GrayScale) out <- mkFIFO();
        Reg#(UInt#(32)) npix <- mkReg(0);
        Reg#(Bool) started <- mkReg(False);

        FilterServer filter <- mkGauss();
        RowBufferServer rowbuffer <- mkRowBuffer();
        Vector#(3, Vector#(3, Reg#(Maybe#(GrayScale)))) workingField <- replicateM(replicateM(mkReg(tagged Invalid)));

        Reg#(UInt#(2)) timeout <- mkReg(0); // Used to avoid edge pixels
        Reg#(UInt#(14)) col_cnt <- mkReg(fromInteger(width-2));

        Wire#(GrayScale) new_px <- mkWire();
        Wire#(Bool) rotate <- mkDWire(False);
        Reg#(Bool) tofilter <- mkDReg(False);

        rule read_in (npix > 0);
            let p0 = in.first;
            in.deq;
            new_px <= p0;
            npix <= npix - 1;
            rotate <= True;
            tofilter <= True;
        endrule

        rule populate;
            workingField[0][0] <= tagged Valid new_px;
            // Move forward in register field
            for(Integer x = 1; x <= 2; x = x + 1) begin
                for(Integer y = 0; y <= 2; y = y + 1) begin
                    workingField[y][x] <= workingField[y][x-1];
                end
            end
            // Populate and drain row buffers
            Vector#(2, Maybe#(GrayScale)) nextin;
            for(Integer y = 0; y < 2; y = y + 1) begin
                nextin[y] = workingField[y][2];
            end
            rowbuffer.request.put(nextin);
        endrule

        // Only put buffered values on working field if we have a new value so everything moves together
        rule drain(rotate);
            let nextout <- rowbuffer.response.get();
            for(Integer y = 0; y < 2; y = y + 1) begin
                workingField[y+1][0] <= nextout[y];
            end
        endrule

        rule constructKernel (isValid(workingField[2][2]) && tofilter && timeout == 0);
            Vector#(9, GrayScale) toGauss = replicate(0);
            for(Integer y = 0; y < 3; y = y + 1) begin
                for(Integer x = 0; x < 3; x = x + 1) begin
                    toGauss[3*y+x] = fromMaybe(0, workingField[y][x]);
                end
            end
            filter.request.put(toGauss);
            let t = col_cnt - 1;
            
            if(t == 0) begin
                timeout <= 3; // always wait 3 cycles so edge pixels don't cause computation
                col_cnt <= fromInteger(width-2);
            end
            else begin
                col_cnt <= t; //decrement col_cnt by one
            end
        endrule

        rule wait_timeout(timeout > 0 && rotate); // only reduce timeout if data arrived
            timeout <= timeout - 1;
        endrule

        rule forwardResult;
            let t <- filter.response.get(); //extract from mkGauss and put it into the output fifo
            out.enq(t);
        endrule

        method Action setRes(UInt#(32) n_pixels) if(!started);
            npix <= n_pixels;
            started <= True;
        endmethod

        method Bool irq();
            return started && npix == 0;
        endmethod

        method Action ack() if(started && npix == 0); //reset accelerator
            started <= False;
            rowbuffer.clear();
            for(Integer i = 0; i < 3; i = i + 1) begin
                for(Integer j = 0; j < 3; j = j + 1) begin
                    workingField[i][j] <= tagged Invalid;
                end
            end
        endmethod

        interface AcceleratorServer server;
            interface Put request = toPut(in);
            interface Get response = toGet(out);
        endinterface
    endmodule

endpackage