`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 07/22/2019 06:16:37 PM
// Design Name:
// Module Name: gf_div
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
`include "log2.sv"

module gf_div
(
    in0,
    in1,
    out
);
    parameter n=15;
    parameter g=19;
    parameter bounds = Math::log2(n);

    input [bounds:0] in0;
    input [bounds:0] in1;
    output [bounds:0] out;

    wire [bounds:0] log_out_0;
    wire [bounds:0] log_out_1;
    wire [bounds:0] exp_in_0;
    wire [bounds:0] exp_out_0;

    assign exp_in_0 = (log_out_0 > log_out_1) ? (log_out_0 - log_out_1) % n : (log_out_0 - log_out_1 - 1) % n;

    gf_log #(.n(n), .g(g)) log_table0(in0, log_out_0);
    gf_log #(.n(n), .g(g)) log_table1(in1, log_out_1);
    gf_exp #(.n(n), .g(g)) exp_table0( exp_in_0, exp_out_0);

    assign out = ( (in0 == 0) || (in1 == 0) ) ? 0 : exp_out_0;


endmodule: gf_div

module gf_div_tb;
    parameter n = 15;
    parameter g = 19;
    parameter width = Math::log2(n);

    reg [width:0] in0;
    reg [width:0] in1;
    wire [width:0] out;

    gf_div #(.n(n), .g(g)) diver(in0,in1,out);

    initial begin
        for(integer i=0; i < n+1; i=i+1) begin
            in0 = i;
            for(integer j=1; j < n+1; j=j+1) begin
                in1 = j;
                #1;
                $write("%d ", out);
            end
            $write("\n");
        end
    $finish;
    end

endmodule: gf_div_tb
