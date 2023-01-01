package RowBuffer;

import Vector::*;
import GetPut::*;
import ClientServer::*;
import FIFO::*;
import SpecialFIFOs::*;
import BRAMFIFO::*;

import MyTypes::*;
import Buffer::*;


interface RowBufferServer;
    interface Put#(Vector#(2, Maybe#(GrayScale))) request;
    interface Get#(Vector#(2, Maybe#(GrayScale))) response;
endinterface: RowBufferServer

module mkRowBuffer(RowBufferServer);
    // TODO: implement using mkBuffer (task 3.1f)
endmodule


endpackage
