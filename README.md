# web

source :

    https://github.com/balanx/vit

binary :

    http://pan.baidu.com/s/1gdJd4wN#path=%252Farts%252Fvit%2520-%2520Verilog%2520Instantiation%2520Tool

# usage
vit [options] file

Options :
-q              quiet

# examples
file : test.v

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

$> vit test.v

        //========================================
        //
        // Instantiation: test3
        //
        //========================================
        wire  [3:0] a1;
        wire  [3:0] a2;
        wire  [3:0] a3;
        wire        b1;
        wire        b2;
        wire        b3;
        wire [P2-1:0] d;
        wire        e;
        wire [P1-1:0] f1;
        wire [P1-1:0] f2;
        wire [P1-1:0] f3;
        wire        g1;
        wire        g2;
        wire        g3;
        wire  [7:0] h;
        wire        j;

        test3  #(
            .P1 ( 4 ),
            .P2 ( P1*2 )
        ) test3_inst (
            .a1 ( a1 ), // I [3:0]
            .a2 ( a2 ), // I [3:0]
            .a3 ( a3 ), // I [3:0]
            .b1 ( b1 ), // I
            .b2 ( b2 ), // I
            .b3 ( b3 ), // I
            .d  ( d  ), // I [P2-1:0]
            .e  ( e  ), // I
            .f1 ( f1 ), // O [P1-1:0]
            .f2 ( f2 ), // O [P1-1:0]
            .f3 ( f3 ), // O [P1-1:0]
            .g1 ( g1 ), // O
            .g2 ( g2 ), // O
            .g3 ( g3 ), // O
            .h  ( h  ), // O [7:0]
            .j  ( j  )  // O
        ); // instantiation of test3

------------
Real Moments
