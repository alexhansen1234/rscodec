`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Alex Hansen
//
// Create Date: 07/20/2019 08:07:07 PM
// Design Name:
// Module Name: gf_poly_div
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

module gf_poly_div
(
    clock,
    start,
    reset,
    done,
    dividend,
    divisor,
    quotient,
    remainder,
    dividend_buffer_out,
    divisor_buffer_out,
    quotient_buffer_out
);

    parameter n=15;
    parameter g=19;
    parameter dividend_width=3;
    parameter divisor_width=2;

    parameter width = Math::log2(n);

    integer i;

    input   clock;
    input   start;
    input   reset;

    input  [width:0]  dividend [0 : dividend_width - 1];
    input  [width:0]  divisor [0 : divisor_width - 1];
    output [width:0]  quotient [0 : $size(dividend)-$size(divisor)];
    output [width:0]  remainder [0 : $size(divisor)-2];
    output done;


    reg done_reg;
    reg [3:0] state;
    reg [width:0] dividend_buffer [0 : $size(dividend)-1];
    reg [width:0] divisor_buffer  [0 : $size(divisor)-1];
    reg [width:0] quotient_buffer [0 : $size(quotient)-1];
    
    output [width:0] dividend_buffer_out [0 : $size(dividend)-1];
    output [width:0] divisor_buffer_out  [0 : $size(divisor)-1];
    output [width:0] quotient_buffer_out [0 : $size(quotient)-1];
    
    assign dividend_buffer_out = dividend_buffer;
    assign divisor_buffer_out = mult_out;
    assign quotient_buffer_out = quotient_buffer;
    
    reg [width:0] leading_coeff;

    wire [width:0] add_out  [0 : $size(dividend_buffer)-1];
    wire [width:0] mult_out [0 : $size(divisor_buffer)-1];
    wire [width:0] quotient_out;

    reg [31:0] dividend_order;
    reg [31:0] divisor_order;
    wire [width:0] mult_pad[0 : $size(dividend_buffer)-$size(divisor_buffer)-1];
    
    assign mult_pad = '{$size(mult_pad){'0}};
    
    genvar j;
    for(j=0; j < $size(divisor_buffer); j=j+1) begin
        gf_mul #(.n(n), .g(g)) mul(divisor_buffer[j], quotient_buffer[0], mult_out[j]);
    end

    gf_div #(.n(n), .g(g)) div(dividend_buffer[0], divisor_buffer[0], quotient_out);

    gf_poly_add #(.n(n), .g(g), .terms($size(dividend_buffer))) poly_add( { mult_out, mult_pad } , dividend_buffer, add_out);

    assign done = done_reg;
    
    for(j=0; j < $size(quotient_buffer); j=j+1)
        assign quotient[j] = quotient_buffer[$size(quotient_buffer)-j-1];

    assign remainder = dividend_buffer[0:$size(remainder)-1];

    initial begin;
        state = 0;
        done_reg = 0;
        dividend_buffer <= '{$size(dividend_buffer){'0}};
        divisor_buffer <= '{$size(divisor_buffer){'0}};
        quotient_buffer <= '{$size(quotient_buffer){'0}};
    end

    always @(posedge clock) begin
        if( reset == 1 ) begin
            state = 0;
            done_reg = 0;
            dividend_buffer = '{$size(dividend_buffer){'0}};
            divisor_buffer = '{$size(divisor_buffer){'0}};
            quotient_buffer = '{$size(quotient_buffer){'0}};
        end

        else begin
            case (state)
                0:  begin
                        if( start == 1 ) begin
                            dividend_buffer <= dividend;
                            divisor_buffer <= divisor;
                            quotient_buffer <= '{$size(quotient_buffer){'0}};
                            dividend_order <= dividend_width;
                            divisor_order <= divisor_width;
                            state <= 1;
                            done_reg <= 0;
                        end
                    end

                1:  begin
                        if( dividend_buffer[0] == 0 ) begin
                            for(i=1; i < $size(dividend_buffer); i=i+1)
                                dividend_buffer[i-1] <= dividend_buffer[i];
                            dividend_buffer[$size(dividend_buffer)-1] <= 0;
                            dividend_order <= dividend_order - 1;
                        end

                        if( divisor_buffer[0] == 0 ) begin
                            for(i=1; i < $size(divisor_buffer); i=i+1)
                                divisor_buffer[i-1] <= divisor_buffer[i];
                            divisor_buffer[$size(divisor_buffer)-1] <= 0;
                            divisor_order <= divisor_order - 1;
                        end

                        if( dividend_buffer[0] != 0 && divisor_buffer[0] != 0 )
                            state <= 2;
                        else
                            state <= 1;
                    end
                    
                2:  begin
                        quotient_buffer[0] <= quotient_out;
                        state <= 3;
                    end
                    
                3:  begin
                        dividend_buffer <= add_out;
                        dividend_order <= dividend_order - 1;
                            state <= 4;
                    end
                    
                4:  begin
                        if( dividend_order < divisor_order ) begin
                            for(i=1; i < $size(dividend_buffer); i=i+1)
                                dividend_buffer[i-1] <= dividend_buffer[i];
                            dividend_buffer[$size(dividend_buffer)-1] <= 0;
                            state <= 0;
                            done_reg <= 1;
                        end
                        
                        else begin
                            for(i=1; i < $size(quotient_buffer); i=i+1)
                                quotient_buffer[i] <= quotient_buffer[i-1];
                            quotient_buffer[0] <= 0;
                            state <= 1;
                        end
                                 
                    end

            endcase
        end
    end

endmodule: gf_poly_div

module gf_poly_div_tb;
    parameter n = 15;
    parameter g = 19;
    parameter width = Math::log2(n);

    reg [width:0] in0[6:0] = { 4'd1, 4'd1, 4'd1, 4'd1, 4'd2, 4'd3, 4'd4 };
    reg [width:0] in1[2:0] = { 4'd2, 4'd3, 4'd4 };
    wire [width:0] out[0 : $size(in0) - $size(in1)];
    wire [width:0] rem[0 : $size(in1) - 2];

    reg clock;
    reg start;
    reg reset;
    wire done;


    gf_poly_div
    #(
        .n(n),
        .g(g),
        .dividend_width($size(in0)),
        .divisor_width($size(in1))
    )
    diver
    (
        .clock(clock),
        .start(start),
        .reset(reset),
        .done(done),
        .dividend(in0),
        .divisor(in1),
        .quotient(out),
        .remainder(rem)
    );

    initial begin
        clock = 1;
        start = 1;
        reset = 0;
    end

    always begin
        #10 clock = ~clock;
        if( done == 1 )
            $finish;
    end

endmodule: gf_poly_div_tb
