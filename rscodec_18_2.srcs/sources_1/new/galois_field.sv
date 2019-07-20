`define TOP

`timescale 1ps / 1ps

`include "log2.sv"

//module gf_add
//(
//    in0,
//    in1,
//    out
//);
//    parameter n=15;
//    parameter g=19;
//    parameter bounds = Math::log2(n);
    
//    input [bounds:0] in0;
//    input [bounds:0] in1;
//    output [bounds:0] out;
    
//    assign out = in0 ^ in1;
    
//endmodule: gf_add

module gf_add
(
    ins,
    out
);
    parameter n=15;
    parameter g=19;
    parameter bounds = Math::log2(n);
    parameter n_inputs = 2;
    
    input [bounds:0] ins [0:n_inputs-1];
    output [bounds:0] out;
    
    wire [bounds:0] outwire;
        
    if( n_inputs == 1 )
        assign out = ins[0];
    else begin
        assign out = ins[0] ^ outwire;
        gf_add #(.n(n), .g(g), .n_inputs(n_inputs-1)) reduce_add(ins[1:$size(ins)-1], outwire);
    end 
    
endmodule


module gf_mul
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
    
    assign exp_in_0 = (log_out_0 + log_out_1) % n;
    
    gf_log #(.n(n), .g(g)) log_table0(in0, log_out_0);
    gf_log #(.n(n), .g(g)) log_table1(in1, log_out_1);
    gf_exp #(.n(n), .g(g)) exp_table0( exp_in_0, exp_out_0);
   
    assign out = ( (in0 == 0) || (in1 == 0) ) ? 0 : exp_out_0;    
    
   
endmodule: gf_mul

module gf_exp
(
    in,
    out
);
    parameter n=15;
    parameter g=19;
    parameter bounds = Math::log2(n);
    
    input  [bounds:0]  in;
    output [bounds:0]  out;
  
    logic [bounds:0] lut[0:n];
    
    initial begin;
        lut[0] = 1;
    
        for(int i=1; i < n+1; i=i+1) begin
            lut[i] = lut[i-1] << 1;
            if( i == n )
                lut[i] = 1;
            else if( lut[i] < lut[i-1] )
                lut[i] = lut[i] ^ (n & g);
        end
    end

    assign out = lut[in];
    
endmodule

module gf_log
(
    in,
    out
);
    parameter n=15;
    parameter g=19;    
    parameter bounds = Math::log2(n);
    
    input  [bounds:0]  in;
    output [bounds:0]  out;
  
    logic [bounds:0] lut[0:n];
    logic [bounds:0] log[0:n];
    
    initial begin;
        lut[0] = 1;
    
        for(int i=1; i < n+1; i=i+1) begin
            lut[i] = lut[i-1] << 1;
            if( lut[i] < lut[i-1] )
                lut[i] = lut[i] ^ (n & g);
        end
        
        for(int i=0; i < n; i=i+1) begin
            log[lut[i]] = i;
        end
        
        log[0] = -1;
    end
    
    assign out = log[in];
    
endmodule

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
