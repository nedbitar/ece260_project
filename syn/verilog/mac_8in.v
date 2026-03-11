module mac_8in (out, a, b);

parameter bw      = 8;
parameter bw_psum = 2*bw+4;
parameter pr      = 8;

output signed [bw_psum-1:0] out;
input  signed [pr*bw-1:0]   a;
input  signed [pr*bw-1:0]   b;

// Products computed at 2*bw width, then sign-extended to bw_psum before
// accumulation so that all bw_psum output bits are driven by real adder logic.
wire signed [2*bw-1:0] product0;
wire signed [2*bw-1:0] product1;
wire signed [2*bw-1:0] product2;
wire signed [2*bw-1:0] product3;
wire signed [2*bw-1:0] product4;
wire signed [2*bw-1:0] product5;
wire signed [2*bw-1:0] product6;
wire signed [2*bw-1:0] product7;

assign product0 = $signed(a[bw*1-1:bw*0]) * $signed(b[bw*1-1:bw*0]);
assign product1 = $signed(a[bw*2-1:bw*1]) * $signed(b[bw*2-1:bw*1]);
assign product2 = $signed(a[bw*3-1:bw*2]) * $signed(b[bw*3-1:bw*2]);
assign product3 = $signed(a[bw*4-1:bw*3]) * $signed(b[bw*4-1:bw*3]);
assign product4 = $signed(a[bw*5-1:bw*4]) * $signed(b[bw*5-1:bw*4]);
assign product5 = $signed(a[bw*6-1:bw*5]) * $signed(b[bw*6-1:bw*5]);
assign product6 = $signed(a[bw*7-1:bw*6]) * $signed(b[bw*7-1:bw*6]);
assign product7 = $signed(a[bw*8-1:bw*7]) * $signed(b[bw*8-1:bw*7]);

// Sign-extend each product to bw_psum bits before adding so the adder
// operates at full output width and drives all bw_psum bits of out.
wire signed [bw_psum-1:0] ext0, ext1, ext2, ext3, ext4, ext5, ext6, ext7;
assign ext0 = $signed(product0);
assign ext1 = $signed(product1);
assign ext2 = $signed(product2);
assign ext3 = $signed(product3);
assign ext4 = $signed(product4);
assign ext5 = $signed(product5);
assign ext6 = $signed(product6);
assign ext7 = $signed(product7);

assign out = ext0 + ext1 + ext2 + ext3 + ext4 + ext5 + ext6 + ext7;

endmodule