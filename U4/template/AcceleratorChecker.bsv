package AcceleratorChecker;
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

    module mkAcceleratorChecker(Empty);
        Reg#(UInt#(32)) readCounter <- mkReg(0);
        Reg#(UInt#(32)) writeCounter <- mkReg(0);
        Reg#(UInt#(64)) addressRead <- mkRegU;
        Reg#(UInt#(64)) oracle_ptr <- mkRegU;

        Reg#(UInt#(32)) n_pixels_in <- mkRegU;
        Reg#(UInt#(32)) n_pixels_out <- mkRegU;

        Accelerator uut <- mkGaussAccelerator();

        Stmt test = seq 
            action
                let t1 <- readImage_create("./picture.png");
                addressRead <= t1;
                $display("Reading image, is at: %d", t1);

                n_pixels_in <= fromInteger(width) * fromInteger(height);
                n_pixels_out <= fromInteger(width-2) * fromInteger(height-2);
                let t2 <- oracle_create(t1, fromInteger(width), fromInteger(height));
                oracle_ptr <= t2;
                $display("Oracle is at: 0x%h", t2);
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
                    let pixel_exp <- oracle_get_next_pixel(oracle_ptr);
                    if(new_pixel != pixel_exp) begin
                        match {.x, .y} = row_major_to_xy(writeCounter);
                        $display("Error at pixel (%d,%d). Expected %d, got %d", x, y, pixel_exp, new_pixel);
                        $finish();
                    end
                endaction
            endpar
            readImage_delete(addressRead);
            oracle_delete(oracle_ptr);
            $display("Test passed");
        endseq;

        mkAutoFSM(test);
    endmodule
endpackage : AcceleratorChecker