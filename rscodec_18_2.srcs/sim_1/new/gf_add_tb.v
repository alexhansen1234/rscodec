`timescale 1ns / 1ns

module gf_add_tb;

    function integer log2;
        input integer x;
        
        begin
            log2 = 0;
            while( x > 0 ) begin
                x = x >> 1;
                log2 = log2 + 1;
            end
            log2 = log2 - 1;
        end
    endfunction

    
    parameter n = 255;
    parameter g = 285;
    parameter width = log2(n);
    
    reg [width:0] in0;
    reg [width:0] in1;
    wire [width:0] out;
    
    gf_add 
    #( 
        .n(n), 
        .g(g)
    )
    adder 
    ( 
        .in0(in0),
        .in1(in1),
        .out(out)
    );
    
    initial begin
        for(integer i=0; i < n+1; i=i+1) begin
            in0 = i;
            for(integer j=0; j < n+1; j=j+1) begin
                in1 = j;
                #10;
            end
        end
        $finish;
    end
    
    reg [7:0] lut [255:0];
    
endmodule      

