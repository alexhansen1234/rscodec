`ifndef MATH
`define MATH
class Math #(type T = integer);
  
    static function T log2(T x);
        static T retval;
        begin
          retval = 0;
          while( x > 0 ) begin
              x = x >> 1;
              retval = retval + 1;
          end
          retval = retval - 1;
        end
        return retval;
    endfunction: log2 

    static function T mod(T x, T y);
        static T retval;
        retval = x % y;
    endfunction: mod
    
endclass: Math
`endif

`ifndef TOP
`define TOP

module test(integer in);
    Math m;
    
    initial begin;
        for(integer i=0; i < 256; ++i) begin
            $display("val is %d", m.log2(i));
        end
        $finish; 
    end
    
    
endmodule: test

`endif