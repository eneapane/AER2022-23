package AcceleratorTb;
    import MyTypes::*;
    import GetPut::*;
    import ClientServer::*;
    import FIFO::*;
    import ImageFunctions::*;
    import Gauss::*;
    import StmtFSM::*;
    import Settings::*;
    import Vector::*;
    import Top::*;
    import Watchdog::*;

    module mkAcceleratorTb(Empty);
        Reg#(UInt#(32)) readCounter <- mkReg(0);
        Reg#(UInt#(32)) writeCounter <- mkReg(0);
        Reg#(UInt#(64)) addressRead <- mkRegU;
        Reg#(UInt#(64)) addressWrite <- mkRegU;

        Reg#(UInt#(32)) n_pixels_in <- mkRegU;
        Reg#(UInt#(32)) n_pixels_out <- mkRegU;

        // Unit under test (our filter)
        Accelerator uut <- mkGaussAccelerator();

        // Change the literal if you think the timeout happens too fast
        mkWatchdog(32'h_00FFFFFF);
    
        Stmt convertImage = seq 
            action
                let t1 <- readImage_create("./picture.png");
                addressRead <= t1;
                $display("Reading image, is at: %d", t1);

                n_pixels_in <= fromInteger(width) * fromInteger(height);
                n_pixels_out <= fromInteger(width-2) * fromInteger(height-2);
                let t2 <- writeImage_create("./AcceleratorTbOut", 0, fromInteger(width-2), fromInteger(height-2));

                addressWrite <= t2;
                $display("Writing image, is at: %d", t2);
            endaction
            action
                uut.setRes(n_pixels_in);
            endaction
            par
                for(readCounter <= 0; readCounter < n_pixels_in; readCounter <= readCounter + 1) action
                    let pixel <- readImage_getPixel(addressRead);
                    uut.server.request.put(pixel);
                endaction
                for(writeCounter <= 0; writeCounter < n_pixels_out; writeCounter <= writeCounter + 1) action
                    let new_pixel <- uut.server.response.get;
                    writeImage_putPixel(addressWrite, new_pixel);
                endaction
            endpar
            readImage_delete(addressRead);
            writeImage_delete(addressWrite);
            $display("Finished test");
        endseq;

        mkAutoFSM(convertImage);
    endmodule
endpackage