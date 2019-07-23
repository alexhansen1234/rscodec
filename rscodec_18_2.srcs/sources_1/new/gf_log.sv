`include "log2.sv"

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
    
endmodule: gf_log

module gf_log_tb;
    parameter n = 15;
    parameter g = 11;
    parameter width = Math::log2(n);
    
    reg [width:0] in0;
    reg [width:0] in1;
    wire [width:0] out;

    gf_log #(.n(n), .g(g)) logarithm(in0, out);
    
    initial begin
        for(integer i=0; i < n+1; i=i+1) begin
            in0 = i;
            #1;
            $write("%d\n", out);
        end
    $finish;
    end

endmodule: gf_log_tb

