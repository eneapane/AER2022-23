package RowBuffer;

import Vector::*;
import GetPut::*;
import ClientServer::*;
import FIFO::*;
import SpecialFIFOs::*;
import BRAMFIFO::*;

import MyTypes::*;
import Buffer::*;

// TODO: extend in task 4.2
interface RowBufferServer;
    method Action clear();
    interface Put#(Vector#(2, Maybe#(GrayScale))) request;
    interface Get#(Vector#(2, Maybe#(GrayScale))) response;
endinterface: RowBufferServer

module mkRowBuffer(RowBufferServer);
    FIFO#(Vector#(2, Maybe#(GrayScale))) inputValue <- mkBypassFIFO;
    FIFO#(Vector#(2, Maybe#(GrayScale))) outputValue <- mkBypassFIFO;

    BufferServer buffer[2];
    for(Integer i = 0; i < 2; i = i + 1) //static unrolling
        buffer[i] <- mkBRAMBuffer;

    rule drainInput;
        let value = inputValue.first;
        inputValue.deq;

        for(Integer i = 0; i < 2; i = i + 1) //simulatanous transmission of values from both buffers
            buffer[i].request.put(value[i]);
    endrule

    rule fillOutput;
        Vector#(2, Maybe#(GrayScale)) vec;
        for(Integer i = 0; i < 2; i = i + 1) begin //simultanous transmission of values from both Buffers
            let t <- buffer[i].response.get;
            vec[i] = t;
        end

        outputValue.enq(vec);
    endrule

    method Action clear();
        inputValue.clear();
        outputValue.clear();
        for(Integer i = 0; i < 2; i = i + 1)
            buffer[i].clear();
    endmethod

    interface Put request = toPut(inputValue);
    interface Get response = toGet(outputValue);
endmodule


endpackage
