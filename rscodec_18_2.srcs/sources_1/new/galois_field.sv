`define TOP

`timescale 1ps / 1ps

`include "log2.sv"

module gf_tb;
    parameter n = 15;
    parameter g = 11;
    parameter width = Math::log2(n);
    
    reg [width:0] in0;
    reg [width:0] in1;
    wire [width:0] out;

    //gf_exp #(.n(n), .g(g)) exponential(in0, out);
    //gf_log #(.n(n), .g(g)) logarithm(in0, out);
    //gf_add #(.n(n), .g(g)) adder(in0,in1,out);
    gf_mul #(.n(n), .g(g)) muler(in0,in1,out);

    initial begin
        for(integer i=0; i < n+1; i=i+1) begin
            in0 = i;
            for(integer j=0; j < n+1; j=j+1) begin
                in1 = j;
                #1;
                $write("%d ", out);
            end
            $write("\n");
        end
    $finish;
    end

endmodule: gf_tb
