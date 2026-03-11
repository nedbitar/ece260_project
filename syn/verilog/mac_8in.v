module mac_8in (out, a, b);

parameter bw      = 8;
parameter bw_psum = 2*bw+4;
parameter pr      = 8;

output signed [bw_psum-1:0] out;
input  signed [pr*bw-1:0]   a;
input  signed [pr*bw-1:0]   b;

wire signed [bw*2-1:0] product0;
wire signed [bw*2-1:0] product1;
wire signed [bw*2-1:0] product2;
wire signed [bw*2-1:0] product3;
wire signed [bw*2-1:0] product4;
wire signed [bw*2-1:0] product5;
wire signed [bw*2-1:0] product6;
wire signed [bw*2-1:0] product7;

assign product0 = $signed(a[bw*1-1:bw*0]) * $signed(b[bw*1-1:bw*0]);
assign product1 = $signed(a[bw*2-1:bw*1]) * $signed(b[bw*2-1:bw*1]);
assign product2 = $signed(a[bw*3-1:bw*2]) * $signed(b[bw*3-1:bw*2]);
assign product3 = $signed(a[bw*4-1:bw*3]) * $signed(b[bw*4-1:bw*3]);
assign product4 = $signed(a[bw*5-1:bw*4]) * $signed(b[bw*5-1:bw*4]);
assign product5 = $signed(a[bw*6-1:bw*5]) * $signed(b[bw*6-1:bw*5]);
assign product6 = $signed(a[bw*7-1:bw*6]) * $signed(b[bw*7-1:bw*6]);
assign product7 = $signed(a[bw*8-1:bw*7]) * $signed(b[bw*8-1:bw*7]);

assign out = $signed(product0)
           + $signed(product1)
           + $signed(product2)
           + $signed(product3)
           + $signed(product4)
           + $signed(product5)
           + $signed(product6)
           + $signed(product7);

endmodule