package GaussChecker;
    import MyTypes::*;
    import GetPut::*;
    import ClientServer::*;
    import FIFO::*;
    import ImageFunctions::*;
    import Gauss::*;
    import StmtFSM::*;
    import Settings::*;
    import Vector::*;

    module mkGaussChecker(Empty);
        Reg#(UInt#(32)) read_x <- mkReg(0);
        Reg#(UInt#(32)) read_y <- mkReg(0);
        Reg#(UInt#(32)) checkCounter <- mkReg(0);
        Reg#(UInt#(64)) addressRead <- mkRegU;

        Reg#(Bool) failed <- mkReg(False);
        Reg#(UInt#(32)) n_pixels <- mkRegU;

        // Unit under test (our filter)
        FilterServer uut <- mkGauss();
        FIFO#(GrayScale) reference_values <- mkFIFO();
    
        Stmt checkFilter = seq 
            action
                let t1 <- readImage_create("./picture.png");
                addressRead <= t1;
                $display("Reading image, is at: %d", t1);

                n_pixels <= fromInteger(width-2) * fromInteger(height-2);
            endaction
            par
                for(read_y <= 1; read_y < fromInteger(height-1); read_y <= read_y + 1) seq
                    for(read_x <= 1; read_x < fromInteger(width-1); read_x <= read_x + 1) action
                        Vector#(9, GrayScale) field = replicate(0);
                        for(Int#(32) ky = -1; ky <= 1; ky = ky + 1) begin
                            for(Int#(32) kx = -1; kx <= 1; kx = kx + 1) begin
                                field[3*(ky+1)+kx+1] = get_padded_pixel(addressRead, unpack(pack(read_x))+kx, unpack(pack(read_y))+ky);
                            end
                        end
                        uut.request.put(field);
                        reference_values.enq(getGaussResult(field));
                    endaction
                endseq
                for(checkCounter <= 0; checkCounter < n_pixels; checkCounter <= checkCounter + 1) action
                    let new_pixel <- uut.response.get();
                    let ref_pixel = reference_values.first();
                    reference_values.deq();
                    if(new_pixel != ref_pixel) begin
                        match {.x, .y} = row_major_to_xy(checkCounter);
                        $display("Error at pixel (%d,%d). Expected %d, got %d", x, y, ref_pixel, new_pixel);
                        failed <= True;
                    end
                endaction
            endpar
            readImage_delete(addressRead);
            action
                if(failed)
                    $display("Test failed");
                else
                    $display("Test successful");
            endaction
        endseq;

        mkAutoFSM(checkFilter);
    endmodule : mkGaussChecker
endpackage : GaussChecker