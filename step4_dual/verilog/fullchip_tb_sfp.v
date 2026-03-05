// Testbench for fullchip with SFP normalization verification
`timescale 1ns/1ps

module fullchip_tb_sfp;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 8;            // how many products added in each dot product
parameter col = 8;           // how many dot product units are equipped

integer qk_file;
integer qk_scan_file;

integer  captured_data;
`define NULL 0

integer  K[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
integer  abs_result[total_cycle-1:0][col-1:0];
integer  row_sum[total_cycle-1:0];
integer  norm_sum;

integer i,j,k,t,p,q,s,u,m;
integer row_idx;

reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in;
reg ofifo_rd = 0;
wire [16:0] inst;
reg qmem_rd = 0;
reg qmem_wr = 0;
reg kmem_rd = 0;
reg kmem_wr = 0;
reg pmem_rd = 0;
reg pmem_wr = 0;
reg execute = 0;
reg load = 0;
reg [3:0] qkmem_add = 0;
reg [3:0] pmem_add = 0;

// SFP control signals
reg acc = 0;
reg div = 0;
reg sfp_ext_rd = 0;
reg [bw_psum+3:0] sum_in = 0;
wire [bw_psum+3:0] sum_out;

assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;

reg [bw_psum-1:0] temp5b;
reg [bw_psum*col-1:0] temp16b;
wire [bw_psum*col-1:0] out;

fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk(clk),
      .mem_in(mem_in),
      .acc(acc),
      .div(div),
      .sfp_ext_rd(sfp_ext_rd),
      .sum_in(sum_in),
      .sum_out(sum_out),
      .out(out),
      .inst(inst)
);


initial begin

  $dumpfile("fullchip_tb_sfp.vcd");
  $dumpvars(0, fullchip_tb_sfp);



  ///// Q data txt reading /////
  $display("##### Q data txt reading #####");

  qk_file = $fopen("../qdata.txt", "r");
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
      qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
      Q[q][j] = captured_data;
    end
  end


  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// K data txt reading /////
  $display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end
  reset = 0;

  qk_file = $fopen("../kdata.txt", "r");
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);

  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
      qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
      K[q][j] = captured_data;
    end
  end


  ///// Compute expected results /////
  $display("##### Estimated multiplication result #####");

  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
      result[t][q] = 0;
    end
  end

  for (t=0; t<total_cycle; t=t+1) begin
    for (q=0; q<col; q=q+1) begin
      for (k=0; k<pr; k=k+1) begin
        result[t][q] = result[t][q] + Q[t][k] * K[q][k];
      end
      temp5b = result[t][q];
      temp16b = {temp16b[bw_psum*col-bw_psum-1:0], temp5b};
    end
    $display("prd @cycle%2d: %40h", t, temp16b);
  end


  ///// Qmem writing /////
  $display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1;
    mem_in[1*bw-1:0*bw] = Q[q][0];
    mem_in[2*bw-1:1*bw] = Q[q][1];
    mem_in[3*bw-1:2*bw] = Q[q][2];
    mem_in[4*bw-1:3*bw] = Q[q][3];
    mem_in[5*bw-1:4*bw] = Q[q][4];
    mem_in[6*bw-1:5*bw] = Q[q][5];
    mem_in[7*bw-1:6*bw] = Q[q][6];
    mem_in[8*bw-1:7*bw] = Q[q][7];
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  qmem_wr = 0;
  qkmem_add = 0;
  #0.5 clk = 1'b1;


  ///// Kmem writing /////
  $display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin
    #0.5 clk = 1'b0;
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1;
    mem_in[1*bw-1:0*bw] = K[q][0];
    mem_in[2*bw-1:1*bw] = K[q][1];
    mem_in[3*bw-1:2*bw] = K[q][2];
    mem_in[4*bw-1:3*bw] = K[q][3];
    mem_in[5*bw-1:4*bw] = K[q][4];
    mem_in[6*bw-1:5*bw] = K[q][5];
    mem_in[7*bw-1:6*bw] = K[q][6];
    mem_in[8*bw-1:7*bw] = K[q][7];
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  kmem_wr = 0;
  qkmem_add = 0;
  #0.5 clk = 1'b1;

  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// K data loading to MAC array /////
  $display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;
    load = 1;
    if (q==1) kmem_rd = 1;
    if (q>1) qkmem_add = qkmem_add + 1;
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  kmem_rd = 0; qkmem_add = 0;
  #0.5 clk = 1'b1;

  #0.5 clk = 1'b0;
  load = 0;
  #0.5 clk = 1'b1;

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// Execute Q*K dot products /////
  $display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;
    execute = 1;
    qmem_rd = 1;
    if (q>0) qkmem_add = qkmem_add + 1;
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  qmem_rd = 0; qkmem_add = 0; execute = 0;
  #0.5 clk = 1'b1;

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// Move ofifo results to pmem /////
  $display("##### move ofifo to pmem #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;
    ofifo_rd = 1;
    pmem_wr = 1;
    if (q>0) pmem_add = pmem_add + 1;
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0;
  pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
  #0.5 clk = 1'b1;

  for (q=0; q<5; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// SFP Accumulation Phase /////
  // Read each PMEM row and accumulate the L1 norm.
  // SRAM Q is registered: pmem_out valid 1 cycle after pmem_rd+address.
  // So prime the pipeline one cycle before asserting acc.
  $display("##### SFP accumulation phase #####");

  pmem_add = 0;
  // Prime: read addr 0, acc=0
  #0.5 clk = 1'b0; pmem_rd = 1; pmem_add = 0; acc = 0; #0.5 clk = 1'b1;

  // Accumulate rows 0..total_cycle-1
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;
    acc = 1;
    if (q < total_cycle-1) begin
      pmem_add = pmem_add + 1;
      pmem_rd = 1;
    end else begin
      pmem_rd = 0; // done reading, last acc uses previously latched pmem_out
    end
    #0.5 clk = 1'b1;
  end

  #0.5 clk = 1'b0; acc = 0; pmem_rd = 0; pmem_add = 0; #0.5 clk = 1'b1;

  // Allow FIFO writes to propagate (2 extra cycles for fifo_wr pipeline)
  for (q=0; q<4; q=q+1) begin
    #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
  end


  ///// SFP Division (Normalization) Phase /////
  // Read each PMEM row again and divide by the accumulated L1 norm.
  // $strobe fires after NBA updates so it sees the freshly computed sfp_out.
  $display("##### SFP division/normalization phase #####");
  $display("##### Simulated SFP normalized output #####");

  pmem_add = 0;
  // Prime: read addr 0, div=0
  #0.5 clk = 1'b0; pmem_rd = 1; pmem_add = 0; div = 0; sfp_ext_rd = 0; #0.5 clk = 1'b1;

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;
    row_idx = q; // capture before clock edge: $strobe fires after q increments
    div = 1;
    sfp_ext_rd = 1; // drain external FIFO in sync
    if (q < total_cycle-1) begin
      pmem_add = pmem_add + 1;
      pmem_rd = 1;
    end else begin
      pmem_rd = 0;
    end
    #0.5 clk = 1'b1;
    $strobe("sfp_out @row%0d: %h", row_idx, out);
  end

  #0.5 clk = 1'b0; div = 0; sfp_ext_rd = 0; pmem_rd = 0; pmem_add = 0; #0.5 clk = 1'b1;


  ///// Compute expected SFP normalization /////
  $display("##### Expected SFP normalized result #####");

  for (t=0; t<total_cycle; t=t+1) begin
    row_sum[t] = 0;
    for (q=0; q<col; q=q+1) begin
      abs_result[t][q] = (result[t][q] < 0) ? -result[t][q] : result[t][q];
      row_sum[t] = row_sum[t] + abs_result[t][q];
    end
    // Hardware uses sum_this_core[bw_psum+3:7], i.e. sum >> 7
    norm_sum = row_sum[t] >> 7;
    if (norm_sum == 0) norm_sum = 1; // avoid divide-by-zero
    $display("row %0d: abs_sum=%0d  norm_divisor=%0d", t, row_sum[t], norm_sum);
    for (q=0; q<col; q=q+1) begin
      $display("  col %0d: result=%0d  expected_sfp_out=%0d", q, result[t][q],
               $signed(result[t][q]) / $signed(norm_sum));
    end
  end

  #10 $finish;

end

endmodule
