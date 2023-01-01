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
        // TODO: implement me (task 3.1b)
    endmodule : mkGauss
endpackage : Gauss