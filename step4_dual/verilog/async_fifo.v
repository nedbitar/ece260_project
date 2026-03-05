module async_fifo #(
    parameter bw    = 24,
    parameter depth = 4
)(
    input               reset,

    input               wr_clk,
    input               wr_en,
    input  [bw-1:0]     wr_data,

    input               rd_clk,
    input               rd_en,
    output reg [bw-1:0] rd_data,

    output              full,
    output              empty
);

localparam ptr_bw = $clog2(depth) + 1;

// FIFO memory
reg [bw-1:0] mem [0:depth-1];

// binary pointers
reg [ptr_bw-1:0] wr_ptr_bin = 0;
reg [ptr_bw-1:0] rd_ptr_bin = 0;

// gray pointers
reg  [ptr_bw-1:0] wr_ptr_gray = 0;
reg  [ptr_bw-1:0] rd_ptr_gray = 0;

// synced gray pointers
wire [ptr_bw-1:0] wr_ptr_gray_sync;
wire [ptr_bw-1:0] rd_ptr_gray_sync;

// write logic (wr_clk domain)
always @(posedge wr_clk) begin
    if (reset) begin
        wr_ptr_bin  <= 0;
        wr_ptr_gray <= 0;
    end else if (wr_en && !full) begin
        mem[ wr_ptr_bin[ptr_bw-2:0] ] <= wr_data;
        wr_ptr_bin  <= wr_ptr_bin + 1;
        wr_ptr_gray <= (wr_ptr_bin + 1) ^ ((wr_ptr_bin + 1) >> 1);
    end
end

// read logic (rd_clk domain)
always @(posedge rd_clk) begin
    if (reset) begin
        rd_ptr_bin  <= 0;
        rd_ptr_gray <= 0;
        rd_data     <= 0;
    end else if (rd_en && !empty) begin
        rd_data     <= mem[ rd_ptr_bin[ptr_bw - 2:0] ];
        rd_ptr_bin  <= rd_ptr_bin + 1;
        rd_ptr_gray <= (rd_ptr_bin + 1) ^ ( (rd_ptr_bin + 1) >> 1 );
    end
end

// sync rd_ptr into wr_clk domain
genvar i;
generate
    for (i = 0; i < ptr_bw; i = i+1) begin : sync_ptrs
        sync sync_rd2wr (.clk(wr_clk), .in(rd_ptr_gray[i]), .out(rd_ptr_gray_sync[i]));
        sync sync_wr2rd (.clk(rd_clk), .in(wr_ptr_gray[i]), .out(wr_ptr_gray_sync[i]));
    end
endgenerate

assign full  = ( wr_ptr_gray == { ~rd_ptr_gray_sync[ptr_bw-1:ptr_bw-2],
                                        rd_ptr_gray_sync[ptr_bw-3:0] } );
assign empty = (rd_ptr_gray == wr_ptr_gray_sync);

endmodule