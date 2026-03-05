module dual_core (
    clk0, // core0 clock
    clk1, // core1 clcok
    reset,
    
    // core0 inputs
    acc0, div0, sfp_ext_rd0,
    mem_in0,
    inst0,
    
    // core1 inputs
    acc1, div1, sfp_ext_rd1,
    mem_in1,
    inst1,
    
    // outputs
    out0,
    out1
);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input clk0, clk1, reset;
input acc0, div0, sfp_ext_rd0;
input acc1, div1, sfp_ext_rd1;
input [pr*bw-1:0] mem_in0, mem_in1;
input [16:0] inst0, inst1;
output [bw_psum*col-1:0] out0, out1;

// wires for sum exchange between cores
wire [bw_psum+3:0] sum_out0, sum_out1;
wire [bw_psum+3:0] sum_in0,  sum_in1;

// TODO: async FIFOs?

// empty signals for FIFOs
wire empty_0to1, empty_1to0;

// sum_out0 (clk0 domain) --> sum_in1 (clk1 domain)
async_fifo #(.bw(bw_psum+4), .depth(16)) fifo_0to1 (
    .reset   (reset),
    .wr_clk  (clk0),
    .wr_en   (sfp_ext_rd0),
    .wr_data (sum_out0),
    .rd_clk  (clk1),
    .rd_en   (!empty_0to1),
    .rd_data (sum_in1),
    .full    (),
    .empty   (empty_0to1)
);

// sum_out1 (clk1 domain) --> sum_in0 (clk0 domain)
async_fifo #(.bw(bw_psum+4), .depth(16)) fifo_1to0 (
    .reset   (reset),
    .wr_clk  (clk1),
    .wr_en   (sfp_ext_rd1),
    .wr_data (sum_out1),
    .rd_clk  (clk0),
    .rd_en   (!empty_1to0),
    .rd_data (sum_in0),
    .full    (),
    .empty   (empty_1to0)
);

// core instantiations
core #(.col(col), .bw(bw), .pr(pr)) core0 (
    .clk(clk0),
    .reset(reset),
    .acc(acc0),
    .div(div0),
    .sfp_ext_rd(sfp_ext_rd0),
    .sum_in(sum_in0),
    .sum_out(sum_out0),
    .mem_in(mem_in0),
    .out(out0),
    .inst(inst0)
);

core #(.col(col), .bw(bw), .pr(pr)) core1 (
    .clk(clk1),
    .reset(reset),
    .acc(acc1),
    .div(div1),
    .sfp_ext_rd(sfp_ext_rd1),
    .sum_in(sum_in1),
    .sum_out(sum_out1),
    .mem_in(mem_in1),
    .out(out1),
    .inst(inst1)
);

endmodule