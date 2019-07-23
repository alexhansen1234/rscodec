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
    
endmodule: gf_exp

module gf_exp_tb;
    parameter n = 15;
    parameter g = 11;
    parameter width = Math::log2(n);
    
    reg [width:0] in0;
    wire [width:0] out;

    gf_exp #(.n(n), .g(g)) exponential(in0, out);
    
    initial begin
        for(integer i=0; i < n+1; i=i+1) begin
            in0 = i;
            #1;
            $write("%d\n", out);
        end
    $finish;
    end

endmodule: gf_exp_tb

