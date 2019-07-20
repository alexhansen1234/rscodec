`timescale 1ns / 100ps
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
    parameter terms=n;
    parameter bounds = Math::log2(n);
    
    input  [bounds:0] in0 [0 : terms-1];
    input  [bounds:0] in1 [0 : terms-1];
    output [bounds:0] out [0 : terms-1];

    genvar i;
    for(i=0; i < terms; i=i+1) begin
        gf_add #(.n(n), .g(g), .n_inputs(2)) add( {in0[i], in1[i]}, out[i]);
    end
endmodule: gf_poly_add

module gf_poly_mul
(
    clock,
    start,
    reset,
    done,
    in0,
    in1,
    out
);

    parameter n=15;
    parameter g=19;
    parameter in0_terms=3;
    parameter in1_terms=3;

    parameter width = Math::log2(n);

    integer i;
    
    input   clock;
    input   start;
    input   reset;
    
    input  [width:0]  in0 [0 : in0_terms - 1];
    input  [width:0]  in1 [0 : in1_terms - 1];
    output [width:0]  out [0 : in0_terms + in1_terms - 2];
    output done;

    reg done_reg;
    reg [3:0] state;
    reg [width:0] arg0_buffer [0 : in0_terms - 1];
    reg [width:0] arg1_buffer [0 : in1_terms - 1];
    reg [width:0] mult_buffer [0 : in0_terms - 1];
    reg [width:0] out_buffer  [0 : in0_terms + in1_terms - 2];
    
    wire [width:0] mult_out [0 : in0_terms - 1];
    wire [width:0] sum_out;
    reg  [width:0] mult_cmp    [0 : $size(mult_buffer)-1];
    
    genvar j;
    
    for(j=0; j < $size(mult_buffer); j=j+1) begin
        gf_mul #(.n(n), .g(g)) mul(arg0_buffer[j], mult_buffer[j], mult_out[j]);
    end
    
    gf_add #(.n(n), .g(g), .n_inputs($size(mult_out))) reduce_gf_add( mult_out, sum_out );
    
    assign done = done_reg; 
    assign out = out_buffer;
    assign mult_cmp = '{$size(mult_cmp){'0}}; 
    
    initial begin;
        state = 0;
        out_buffer = '{$size(out_buffer){'0}};
        done_reg = 0;
    end
    
    always @(posedge clock) begin
        if( reset == 1 ) begin
            state = 0;
            out_buffer = '{$size(out_buffer){'0}};     
            arg1_buffer = '{$size(arg1_buffer){'0}};       
                
        end
        
        else begin 
            case (state)
                0:  begin
                        if( start == 1 ) begin
                            arg0_buffer <= in0;
                            arg1_buffer <= in1;
                            mult_buffer <= '{$size(mult_buffer){'0}};
                            out_buffer  <= '{$size(out_buffer){'0}};
                            done_reg <= 0;
                            state <= 1;    
                        end
                    end
                    
                1:  begin
                        if( arg0_buffer[0] == 0 ) begin
                            arg0_buffer <= {arg0_buffer[1 : $size(arg0_buffer)-1], 0};
                        end

                        if( arg1_buffer[0] == 0 ) begin
                            arg1_buffer <= {arg1_buffer[1 : $size(arg1_buffer)-1], 0};
                        end

                        if( arg0_buffer[0] != 0 && arg1_buffer[0] != 0 )
                            state <= 2;
                    end
                    
                2:  begin
                        mult_buffer <= {arg1_buffer[0], mult_buffer[0:$size(mult_buffer)-2]};
                        
                        // For some reason, this won't produce the same left-shift as above
                        // arg1_buffer <= {arg1_buffer[1 : $size(arg1_buffer)-1], 0};
                        
                        arg1_buffer[0:$size(arg1_buffer)-2] <= {arg1_buffer[1 : $size(arg1_buffer)-1]};
                        arg1_buffer[$size(arg1_buffer)-1] <= 0;
                        
                        state <= 3;
                    end

                3:  begin
                        if( mult_buffer == mult_cmp )
                            state <= 5;
                        else
                            state <= 4;
                    end
                    
                4:  begin
                        $display("arg1_buffer=");
                        
                        for(int i=0; i < $size(arg1_buffer); i=i+1)
                            $display("%d ", arg1_buffer[i]);
                                        
                        $display("mult_buffer=");
                        for(i=0; i < $size(mult_buffer); i=i+1)
                            $display("%d ", mult_buffer[i]);
                        
                        $display("arg0[0] = %d", arg0_buffer[0]);
                        $display("mult[0] = %d", mult_buffer[0]);
                        $display("mult)out = %d", mult_out[0]);
                                                    
                        out_buffer = {out_buffer[1:$size(out_buffer)-1], sum_out};
                        state <= 2;
                    end
     
                5:  begin
                        done_reg = 1;
                        state <= 0;
                    end
                    
            endcase
        end
    end

endmodule: gf_poly_mul

module gf_poly_add_tb;

    parameter n=15;
    parameter g=19;
    parameter terms = 5;
    parameter width = Math::log2(n);

    reg  [width:0] in0 [0 : terms-1];
    reg  [width:0] in1 [0 : terms-1];
    wire [width:0] out [0 : terms-1];

    gf_poly_add #(.n(n), .g(g), .terms(terms)) poly_adder( in0, in1, out );
    
    initial begin;
        in0[0:terms-1] = {1, 0, 0, 0, 0};
        in1[0:terms-1] = {1, 2, 3, 4, 5};
    end
    

endmodule: gf_poly_add_tb

module gf_poly_mul_tb;
    parameter n = 255;
    parameter g = 285;
    parameter width = Math::log2(n);
    
    reg [width:0] in0 [0:9] = { 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10 };
    reg [width:0] in1 [0:9] = { 8'd4, 8'd6, 8'd10, 8'd11, 8'd123, 8'd2, 8'd2, 8'd2, 8'd2, 8'd69 };
    wire [width:0] out [0: $size(in0) + $size(in1) - 2];
    
    reg clock;
    reg start;
    reg reset;
    wire done;
    
    gf_poly_mul 
    #(
        .n(n), 
        .g(g), 
        .in0_terms( $size(in0) ), 
        .in1_terms( $size(in1) )
    ) 
    mul( clock, start, reset, done, in0, in1, out );
    
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

endmodule