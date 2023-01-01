package GaussTb;
    import MyTypes::*;
    import GetPut::*;
    import ClientServer::*;
    import FIFO::*;
    import ImageFunctions::*;
    import Gauss::*;
    import StmtFSM::*;
    import Settings::*;
    import Vector::*;

    module mkGaussTb(Empty);
        Reg#(UInt#(32)) read_x <- mkReg(0);
        Reg#(UInt#(32)) read_y <- mkReg(0);
        Reg#(UInt#(32)) writeCounter <- mkReg(0);
        Reg#(UInt#(64)) addressRead <- mkRegU;
        Reg#(UInt#(64)) addressWrite <- mkRegU;

        Reg#(UInt#(32)) n_pixels <- mkRegU;

        // Unit under test (our filter)
        FilterServer uut <- mkGauss();
    
        Stmt convertImage = seq 
            action
                let t1 <- readImage_create("./picture.png");
                addressRead <= t1;
                $display("Reading image, is at: %d", t1);

                n_pixels <= fromInteger(width-2) * fromInteger(height-2);

                let t2 <- writeImage_create("./GaussTbOut", 0, fromInteger(width-2), fromInteger(height-2));

                addressWrite <= t2;
                $display("Writing image, is at: %d", t2);
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
                    endaction
                endseq
                for(writeCounter <= 0; writeCounter < n_pixels; writeCounter <= writeCounter + 1) action
                    let new_pixel <- uut.response.get;
                    writeImage_putPixel(addressWrite, new_pixel);
                endaction
            endpar
            readImage_delete(addressRead);
            writeImage_delete(addressWrite);
        endseq;

        mkAutoFSM(convertImage);
    endmodule
endpackage