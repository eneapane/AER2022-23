package Buffer;

import GetPut::*;
import ClientServer::*;
import FIFO::*;
import SpecialFIFOs::*;
import BRAMFIFO::*;
import Settings::*;

import MyTypes::*;

interface BufferServer;
    interface Put#(Maybe#(GrayScale)) request;
    interface Get#(Maybe#(GrayScale)) response;
endinterface: BufferServer

// This buffer operates with BRAM fifos.
module mkBuffer(BufferServer);
    // TODO: implement this module (Task 3.1d)
    
endmodule


endpackage



