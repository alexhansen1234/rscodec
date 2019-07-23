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
        return ((x % y) + y) % y;
    endfunction: mod
    
endclass: Math

`endif
