// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module mac_16in (out, a, b);

parameter bw     = 8;
parameter bw_psum = 2*bw+6;
parameter pr     = 8;  // number of MAC inputs (parallel factor)

output [bw_psum-1:0] out;
input  [pr*bw-1:0]   a;
input  [pr*bw-1:0]   b;

wire [2*bw-1:0]   product [0:pr-1];
wire [bw_psum-1:0] psum   [0:pr];

genvar i;

generate
  for (i = 0; i < pr; i = i+1) begin : gen_products
    assign product[i] = {{(bw){a[bw*(i+1)-1]}}, a[bw*(i+1)-1:bw*i]}
                      * {{(bw){b[bw*(i+1)-1]}}, b[bw*(i+1)-1:bw*i]};
  end
endgenerate

assign psum[0] = {bw_psum{1'b0}};

generate
  for (i = 0; i < pr; i = i+1) begin : gen_psum
    assign psum[i+1] = psum[i]
                     + {{(bw_psum-2*bw){product[i][2*bw-1]}}, product[i]};
  end
endgenerate

assign out = psum[pr];

endmodule
