`include "log2.sv"

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
    
endmodule: gf_add

module gf_add_tb;
    parameter n = 15;
    parameter g = 11;
    parameter width = Math::log2(n);
    
    reg [width:0] in0;
    reg [width:0] in1;
    wire [width:0] out;

    gf_add #(.n(n), .g(g)) adder(in0,in1,out);
    
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

endmodule: gf_add_tb