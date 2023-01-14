package Gauss;
    import ClientServer::*;
    import GetPut::*;
    import FIFO::*;
    import Vector::*;
    import MyTypes::*;

    typedef Server#(Vector#(9, GrayScale), GrayScale) FilterServer;

    /* 3x3 Gaussian kernel filter
            -------------
            | 1 | 2 | 1 |
            -------------
    1/16 *  | 2 | 4 | 2 |
            -------------
            | 1 | 2 | 1 |
            -------------
    */

    module mkGauss(FilterServer);
        FIFO#(Vector#(9, GrayScale)) in <- mkFIFO();
        FIFO#(GrayScale) out <- mkFIFO();

        Vector#(9, Integer) weights; // Hard-wired kernel weights
        weights[0] = 1;
        weights[1] = 2;
        weights[2] = 1;
        weights[3] = 2;
        weights[4] = 4;
        weights[5] = 2;
        weights[6] = 1;
        weights[7] = 2;
        weights[8] = 1;


        rule convolve;
            let pixels = in.first();
            in.deq();
            Bit#(12) mulres = 0;
            for(Integer i = 0; i < 9; i = i + 1) begin
                Bit#(12) px_ex = extend(pixels[i]);
                mulres = mulres + (px_ex << log2(weights[i]));
            end
            out.enq(truncate(mulres >> 4));
        endrule

        interface Put request = toPut(in);
        interface Get response = toGet(out);
    endmodule : mkGauss
endpackage : Gauss