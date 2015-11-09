module test4 (a1, a2, a3, b1, b2, b3, d, e, 
             f1, f2, f3, g1, g2, g3, h, j);
             
parameter P1 = 4;
parameter P2 = P1*2;

input  [3:0] a1, a2, a3;
input        b1, b2, b3;
input  [P2-1:0] d;
input        e;

output [P1-1:0] f1, f2, f3;
output       g1, g2, g3;
output [7:0] h;
output       j;

wire   [3:0] a2, a3;
wire   b2, e;

reg    [3:0] f2, f3;
reg    g2, j;


reg  [7:0]  x1, x2;
reg         y, z;

endmodule
