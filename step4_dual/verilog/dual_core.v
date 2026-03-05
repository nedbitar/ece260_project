module dual_core (
    clk0, clk1,
    reset,
    mem_in0, inst0,
    mem_in1, inst1,
    acc0, div0, sfp_ext_rd0,
    acc1, div1, sfp_ext_rd1,
    out0, out1,
    sfp_out0, sfp_out1
);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;

input clk0, clk1, reset;
input [pr*bw-1:0]        mem_in0, mem_in1;
input [16:0]             inst0, inst1;
input                    acc0, div0, sfp_ext_rd0;
input                    acc1, div1, sfp_ext_rd1;
output [bw_psum*col-1:0] out0, out1;
output [bw_psum*col-1:0] sfp_out0, sfp_out1;

// raw MAC outputs from each core
wire [bw_psum*col-1:0] core_out0, core_out1;

// sum wires
wire [bw_psum+3:0] sum_out0, sum_out1;  // partial sums from each sfp_row
wire [bw_psum+3:0] sum_in0,  sum_in1;   // other core's sum after CDC

// async FIFO empty signals
wire empty_0to1, empty_1to0;

// core instnaces
core #(.col(col), .bw(bw), .pr(pr)) core0 (
    .clk(clk0),
    .reset(reset),
    .mem_in(mem_in0),
    .out(core_out0),
    .inst(inst0),
    .sum_out()
);

core #(.col(col), .bw(bw), .pr(pr)) core1 (
    .clk(clk1),
    .reset(reset),
    .mem_in(mem_in1),
    .out(core_out1),
    .inst(inst1),
    .sum_out()
);

// sfp_row instances 
sfp_row #(.col(col), .bw(bw), .bw_psum(bw_psum)) sfp0 (
    .reset(reset),
    .clk(clk0),
    .acc(acc0),
    .div(div0),
    .fifo_ext_rd(sfp_ext_rd0),
    .sum_in(sum_in0),    // comes from core1 via async FIFO
    .sum_out(sum_out0),  // goes to core1 via async FIFO
    .sfp_in(core_out0),  // raw data from core0
    .sfp_out(sfp_out0)
);

sfp_row #(.col(col), .bw(bw), .bw_psum(bw_psum)) sfp1 (
    .reset(reset),
    .clk(clk1),
    .acc(acc1),
    .div(div1),
    .fifo_ext_rd(sfp_ext_rd1),
    .sum_in(sum_in1),    // comes from core0 via async FIFO
    .sum_out(sum_out1),  // goes to core0 via async FIFO
    .sfp_in(core_out1),  // raw data from core1
    .sfp_out(sfp_out1)
);

// sum_out0 (clk0 domain) -> sum_in1 (clk1 domain)
async_fifo #(.bw(bw_psum+4), .depth(16)) fifo_0to1 (
    .reset(reset),
    .wr_clk(clk0),
    .wr_en(sfp_ext_rd0),
    .wr_data(sum_out0),
    .rd_clk(clk1),
    .rd_en(!empty_0to1),
    .rd_data(sum_in1),
    .full(),
    .empty(empty_0to1)
);

// sum_out1 (clk1 domain) -> sum_in0 (clk0 domain)
async_fifo #(.bw(bw_psum+4), .depth(16)) fifo_1to0 (
    .reset(reset),
    .wr_clk(clk1),
    .wr_en(sfp_ext_rd1),
    .wr_data(sum_out1),
    .rd_clk(clk0),
    .rd_en(!empty_1to0),
    .rd_data(sum_in0),
    .full(),
    .empty(empty_1to0)
);

assign out0 = core_out0;
assign out1 = core_out1;

endmodule