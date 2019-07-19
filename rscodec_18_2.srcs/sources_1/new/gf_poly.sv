`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Self-employed 
// Engineer: Alex Hansen
// 
// Create Date: 07/17/2019 09:16:55 PM
// Design Name: 
// Module Name: polynomial
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Treats arrays of integers as polynomial coefficients, and performs
//  operations on the arrays.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "log2.sv"

module gf_poly_add
(
    in0,
    in1,
    out
);
    
    parameter n=15;
    parameter g=19;
    parameter bounds = Math::log2(n);
    
    input  [bounds:0] in0 [n:0];
    input  [bounds:0] in1 [n:0];
    output [bounds:0] out [n:0];

    gf_add add[n:0](in0, in1, out);

endmodule: gf_poly_add

module gf_poly_mul
(
    in0,
    in1,
    out
);

    parameter n=15;
    parameter g=19;
    parameter in0_width=n;
    parameter in1_width=n;

    input  [Math::log2(n):0]  in0 [in0_width-1:0];
    input  [Math::log2(n):0]  in1 [in1_width-1:0];
    output [Math::log2(n):0]  out [in0_width + in1_width - 1:0];

    initial begin;
        for(integer i=0; i < in0_width; i=i+1) begin
            for(integer j=0; j < in1_width; j=j+1) begin
                //$display("something");
            end 
        end
    end

endmodule: gf_poly_mul

module gf_poly_add_tb;

    parameter n=15;
    parameter g=19;

    reg  [3:0] in0 [n:0];
    reg  [3:0] in1 [n:0];
    wire [3:0] out [n:0];

    gf_poly_add #(.n(n), .g(g)) poly_adder( in0, in1, out );
    
    initial begin;
        in0[4:0] = {1, 0, 0, 0, 0};
        in1[4:0] = {1, 2, 3, 4, 5};
    end
    

endmodule: gf_poly_add_tb