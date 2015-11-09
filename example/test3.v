module test3 #(
parameter P1 = 4,
parameter P2 = P1*2
)
(

input  [3:0] a1, a2, a3,
input        b1, b2, b3,
input  [P2-1:0] d,
input        e,

output reg [P1-1:0] f1, f2, f3,
output           g1, g2, g3,
output     [7:0] h,
output reg       j

);

reg [3:0] tmp;

endmodule
