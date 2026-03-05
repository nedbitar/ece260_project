`timescale 1ns/1ps

module dual_core_tb;

parameter total_cycle = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 16;
parameter col = 8;

integer qk_file;
integer qk_scan_file;
integer captured_data;

integer K0[col-1:0][pr-1:0];
integer K1[col-1:0][pr-1:0];
integer Q[total_cycle-1:0][pr-1:0];
integer result0[total_cycle-1:0][col-1:0];
integer result1[total_cycle-1:0][col-1:0];
integer sum0[total_cycle-1:0];
integer sum1[total_cycle-1:0];

integer i, j, k, q, t;

reg clk0 = 0;
reg clk1 = 0;
reg reset = 1;

always #0.5 clk0 = ~clk0;
always #0.5 clk1 = ~clk1;

// ---- core0 signals ----
reg [pr*bw-1:0] mem_in0;
reg ofifo_rd0 = 0;
reg qmem_rd0 = 0, qmem_wr0 = 0;
reg kmem_rd0 = 0, kmem_wr0 = 0;
reg pmem_rd0 = 0, pmem_wr0 = 0;
reg execute0 = 0, load0 = 0;
reg [3:0] qkmem_add0 = 0;
reg [3:0] pmem_add0 = 0;
reg acc0 = 0, div0 = 0, sfp_ext_rd0 = 0;
wire [16:0] inst0;

assign inst0[16]    = ofifo_rd0;
assign inst0[15:12] = qkmem_add0;
assign inst0[11:8]  = pmem_add0;
assign inst0[7]     = execute0;
assign inst0[6]     = load0;
assign inst0[5]     = qmem_rd0;
assign inst0[4]     = qmem_wr0;
assign inst0[3]     = kmem_rd0;
assign inst0[2]     = kmem_wr0;
assign inst0[1]     = pmem_rd0;
assign inst0[0]     = pmem_wr0;

// ---- core1 signals ----
reg [pr*bw-1:0] mem_in1;
reg ofifo_rd1 = 0;
reg qmem_rd1 = 0, qmem_wr1 = 0;
reg kmem_rd1 = 0, kmem_wr1 = 0;
reg pmem_rd1 = 0, pmem_wr1 = 0;
reg execute1 = 0, load1 = 0;
reg [3:0] qkmem_add1 = 0;
reg [3:0] pmem_add1 = 0;
reg acc1 = 0, div1 = 0, sfp_ext_rd1 = 0;
wire [16:0] inst1;

assign inst1[16]    = ofifo_rd1;
assign inst1[15:12] = qkmem_add1;
assign inst1[11:8]  = pmem_add1;
assign inst1[7]     = execute1;
assign inst1[6]     = load1;
assign inst1[5]     = qmem_rd1;
assign inst1[4]     = qmem_wr1;
assign inst1[3]     = kmem_rd1;
assign inst1[2]     = kmem_wr1;
assign inst1[1]     = pmem_rd1;
assign inst1[0]     = pmem_wr1;

// ---- outputs ----
wire [bw_psum*col-1:0] out0, out1;
wire [bw_psum*col-1:0] sfp_out0, sfp_out1;

// ---- DUT ----
dual_core #(.col(col), .bw(bw), .pr(pr)) dut (
    .clk0(clk0), .clk1(clk1),
    .reset(reset),
    .mem_in0(mem_in0), .inst0(inst0),
    .mem_in1(mem_in1), .inst1(inst1),
    .acc0(acc0), .div0(div0), .sfp_ext_rd0(sfp_ext_rd0),
    .acc1(acc1), .div1(div1), .sfp_ext_rd1(sfp_ext_rd1),
    .out0(out0), .out1(out1),
    .sfp_out0(sfp_out0), .sfp_out1(sfp_out1)
);

// ---- tick task ----
task tick;
    input integer n;
    integer ii;
    begin
        for (ii = 0; ii < n; ii = ii+1) begin
            #0.5 clk0 = 0; clk1 = 0;
            #0.5 clk0 = 1; clk1 = 1;
        end
    end
endtask

// ---- load Q row into both mem_in ----
task load_q_row;
    input integer row;
    begin
        mem_in0[1*bw-1:0*bw]   = Q[row][0];  mem_in1[1*bw-1:0*bw]   = Q[row][0];
        mem_in0[2*bw-1:1*bw]   = Q[row][1];  mem_in1[2*bw-1:1*bw]   = Q[row][1];
        mem_in0[3*bw-1:2*bw]   = Q[row][2];  mem_in1[3*bw-1:2*bw]   = Q[row][2];
        mem_in0[4*bw-1:3*bw]   = Q[row][3];  mem_in1[4*bw-1:3*bw]   = Q[row][3];
        mem_in0[5*bw-1:4*bw]   = Q[row][4];  mem_in1[5*bw-1:4*bw]   = Q[row][4];
        mem_in0[6*bw-1:5*bw]   = Q[row][5];  mem_in1[6*bw-1:5*bw]   = Q[row][5];
        mem_in0[7*bw-1:6*bw]   = Q[row][6];  mem_in1[7*bw-1:6*bw]   = Q[row][6];
        mem_in0[8*bw-1:7*bw]   = Q[row][7];  mem_in1[8*bw-1:7*bw]   = Q[row][7];
        mem_in0[9*bw-1:8*bw]   = Q[row][8];  mem_in1[9*bw-1:8*bw]   = Q[row][8];
        mem_in0[10*bw-1:9*bw]  = Q[row][9];  mem_in1[10*bw-1:9*bw]  = Q[row][9];
        mem_in0[11*bw-1:10*bw] = Q[row][10]; mem_in1[11*bw-1:10*bw] = Q[row][10];
        mem_in0[12*bw-1:11*bw] = Q[row][11]; mem_in1[12*bw-1:11*bw] = Q[row][11];
        mem_in0[13*bw-1:12*bw] = Q[row][12]; mem_in1[13*bw-1:12*bw] = Q[row][12];
        mem_in0[14*bw-1:13*bw] = Q[row][13]; mem_in1[14*bw-1:13*bw] = Q[row][13];
        mem_in0[15*bw-1:14*bw] = Q[row][14]; mem_in1[15*bw-1:14*bw] = Q[row][14];
        mem_in0[16*bw-1:15*bw] = Q[row][15]; mem_in1[16*bw-1:15*bw] = Q[row][15];
    end
endtask

initial begin
    $dumpfile("dual_core_tb.vcd");
    $dumpvars(0, dual_core_tb);

    tick(10);
    reset = 0;

    // ================================================================
    // 1. Read Q data
    // ================================================================
    $display("##### Q data txt reading #####");
    qk_file = $fopen("../test files/qdata.txt", "r");
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    for (q = 0; q < total_cycle; q = q+1)
        for (j = 0; j < pr; j = j+1) begin
            qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
            Q[q][j] = captured_data;
        end
    $fclose(qk_file);

    // ================================================================
    // 2. Read K data core0
    // ================================================================
    $display("##### K data core0 txt reading #####");
    qk_file = $fopen("../test files/kdata_core0.txt", "r");
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    for (q = 0; q < col; q = q+1)
        for (j = 0; j < pr; j = j+1) begin
            qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
            K0[q][j] = captured_data;
        end
    $fclose(qk_file);

    // ================================================================
    // 3. Read K data core1
    // ================================================================
    $display("##### K data core1 txt reading #####");
    qk_file = $fopen("../test files/kdata_core1.txt", "r");
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
    for (q = 0; q < col; q = q+1)
        for (j = 0; j < pr; j = j+1) begin
            qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
            K1[q][j] = captured_data;
        end
    $fclose(qk_file);

    // ================================================================
    // 4. Compute expected sums
    // ================================================================
    $display("##### Expected partial sums #####");
    for (t = 0; t < total_cycle; t = t+1) begin
        sum0[t] = 0; sum1[t] = 0;
        for (q = 0; q < col; q = q+1) begin
            result0[t][q] = 0;
            result1[t][q] = 0;
            for (k = 0; k < pr; k = k+1) begin
                result0[t][q] = result0[t][q] + Q[t][k] * K0[q][k];
                result1[t][q] = result1[t][q] + Q[t][k] * K1[q][k];
            end
            sum0[t] = sum0[t] + (result0[t][q] < 0 ? -result0[t][q] : result0[t][q]);
            sum1[t] = sum1[t] + (result1[t][q] < 0 ? -result1[t][q] : result1[t][q]);
        end
        $display("Expected @cycle%2d: sum0=%0d sum1=%0d merged=%0d",
                  t, sum0[t], sum1[t], sum0[t]+sum1[t]);
    end

    // ================================================================
    // 5. Write Qmem both cores
    // ================================================================
    $display("##### Qmem writing #####");
    for (q = 0; q < total_cycle; q = q+1) begin
        #0.5 clk0 = 0; clk1 = 0;
        qmem_wr0 = 1; qmem_wr1 = 1;
        if (q > 0) begin qkmem_add0 = qkmem_add0+1; qkmem_add1 = qkmem_add1+1; end
        load_q_row(q);
        #0.5 clk0 = 1; clk1 = 1;
    end
    #0.5 clk0 = 0; clk1 = 0;
    qmem_wr0 = 0; qmem_wr1 = 0; qkmem_add0 = 0; qkmem_add1 = 0;
    #0.5 clk0 = 1; clk1 = 1;

    // ================================================================
    // 6. Write Kmem core0
    // ================================================================
    $display("##### Kmem writing core0 #####");
    for (q = 0; q < col; q = q+1) begin
        #0.5 clk0 = 0;
        kmem_wr0 = 1; if (q > 0) qkmem_add0 = qkmem_add0+1;
        mem_in0[1*bw-1:0*bw]   = K0[q][0];
        mem_in0[2*bw-1:1*bw]   = K0[q][1];
        mem_in0[3*bw-1:2*bw]   = K0[q][2];
        mem_in0[4*bw-1:3*bw]   = K0[q][3];
        mem_in0[5*bw-1:4*bw]   = K0[q][4];
        mem_in0[6*bw-1:5*bw]   = K0[q][5];
        mem_in0[7*bw-1:6*bw]   = K0[q][6];
        mem_in0[8*bw-1:7*bw]   = K0[q][7];
        mem_in0[9*bw-1:8*bw]   = K0[q][8];
        mem_in0[10*bw-1:9*bw]  = K0[q][9];
        mem_in0[11*bw-1:10*bw] = K0[q][10];
        mem_in0[12*bw-1:11*bw] = K0[q][11];
        mem_in0[13*bw-1:12*bw] = K0[q][12];
        mem_in0[14*bw-1:13*bw] = K0[q][13];
        mem_in0[15*bw-1:14*bw] = K0[q][14];
        mem_in0[16*bw-1:15*bw] = K0[q][15];
        #0.5 clk0 = 1;
    end
    #0.5 clk0 = 0; kmem_wr0 = 0; qkmem_add0 = 0; #0.5 clk0 = 1;

    // ================================================================
    // 7. Write Kmem core1
    // ================================================================
    $display("##### Kmem writing core1 #####");
    for (q = 0; q < col; q = q+1) begin
        #0.5 clk1 = 0;
        kmem_wr1 = 1; if (q > 0) qkmem_add1 = qkmem_add1+1;
        mem_in1[1*bw-1:0*bw]   = K1[q][0];
        mem_in1[2*bw-1:1*bw]   = K1[q][1];
        mem_in1[3*bw-1:2*bw]   = K1[q][2];
        mem_in1[4*bw-1:3*bw]   = K1[q][3];
        mem_in1[5*bw-1:4*bw]   = K1[q][4];
        mem_in1[6*bw-1:5*bw]   = K1[q][5];
        mem_in1[7*bw-1:6*bw]   = K1[q][6];
        mem_in1[8*bw-1:7*bw]   = K1[q][7];
        mem_in1[9*bw-1:8*bw]   = K1[q][8];
        mem_in1[10*bw-1:9*bw]  = K1[q][9];
        mem_in1[11*bw-1:10*bw] = K1[q][10];
        mem_in1[12*bw-1:11*bw] = K1[q][11];
        mem_in1[13*bw-1:12*bw] = K1[q][12];
        mem_in1[14*bw-1:13*bw] = K1[q][13];
        mem_in1[15*bw-1:14*bw] = K1[q][14];
        mem_in1[16*bw-1:15*bw] = K1[q][15];
        #0.5 clk1 = 1;
    end
    #0.5 clk1 = 0; kmem_wr1 = 0; qkmem_add1 = 0; #0.5 clk1 = 1;

    tick(2);

    // ================================================================
    // 8. Load K into MAC array
    // ================================================================
    $display("##### K loading to MAC array #####");
    for (q = 0; q < col+1; q = q+1) begin
        #0.5 clk0 = 0; clk1 = 0;
        load0 = 1; load1 = 1;
        if (q == 1) begin kmem_rd0 = 1; kmem_rd1 = 1; end
        if (q > 1)  begin qkmem_add0 = qkmem_add0+1; qkmem_add1 = qkmem_add1+1; end
        #0.5 clk0 = 1; clk1 = 1;
    end
    #0.5 clk0 = 0; clk1 = 0;
    kmem_rd0 = 0; kmem_rd1 = 0; qkmem_add0 = 0; qkmem_add1 = 0;
    #0.5 clk0 = 1; clk1 = 1;
    #0.5 clk0 = 0; clk1 = 0;
    load0 = 0; load1 = 0;
    #0.5 clk0 = 1; clk1 = 1;

    tick(10);

    // ================================================================
    // 9. Execute MAC
    // ================================================================
    $display("##### Execute MAC #####");
    for (q = 0; q < total_cycle; q = q+1) begin
        #0.5 clk0 = 0; clk1 = 0;
        execute0 = 1; execute1 = 1;
        qmem_rd0 = 1; qmem_rd1 = 1;
        if (q > 0) begin qkmem_add0 = qkmem_add0+1; qkmem_add1 = qkmem_add1+1; end
        #0.5 clk0 = 1; clk1 = 1;
    end
    #0.5 clk0 = 0; clk1 = 0;
    qmem_rd0 = 0; qmem_rd1 = 0; qkmem_add0 = 0; qkmem_add1 = 0;
    execute0 = 0; execute1 = 0;
    #0.5 clk0 = 1; clk1 = 1;

    tick(10);

    // ================================================================
    // 10. Move ofifo to pmem
    // ================================================================
    $display("##### Move ofifo to pmem #####");
    for (q = 0; q < total_cycle; q = q+1) begin
        #0.5 clk0 = 0; clk1 = 0;
        ofifo_rd0 = 1; pmem_wr0 = 1;
        ofifo_rd1 = 1; pmem_wr1 = 1;
        if (q > 0) begin pmem_add0 = pmem_add0+1; pmem_add1 = pmem_add1+1; end
        #0.5 clk0 = 1; clk1 = 1;
    end
    #0.5 clk0 = 0; clk1 = 0;
    pmem_wr0 = 0; pmem_add0 = 0; ofifo_rd0 = 0;
    pmem_wr1 = 0; pmem_add1 = 0; ofifo_rd1 = 0;
    #0.5 clk0 = 1; clk1 = 1;

    tick(5);

    // ================================================================
    // 11. Accumulate + exchange sums per cycle
    // ================================================================
    $display("##### Accumulate and exchange sums #####");
    pmem_add0 = 0; pmem_add1 = 0;
    for (q = 0; q < total_cycle; q = q+1) begin
        // read pmem
        #0.5 clk0 = 0; clk1 = 0;
        pmem_rd0 = 1; pmem_rd1 = 1;
        if (q > 0) begin pmem_add0 = pmem_add0+1; pmem_add1 = pmem_add1+1; end
        #0.5 clk0 = 1; clk1 = 1;

        // acc pulse
        #0.5 clk0 = 0; clk1 = 0;
        acc0 = 1; acc1 = 1;
        pmem_rd0 = 0; pmem_rd1 = 0;
        #0.5 clk0 = 1; clk1 = 1;

        #0.5 clk0 = 0; clk1 = 0;
        acc0 = 0; acc1 = 0;
        #0.5 clk0 = 1; clk1 = 1;

        // push sum into async FIFO
        #0.5 clk0 = 0; clk1 = 0;
        sfp_ext_rd0 = 1; sfp_ext_rd1 = 1;
        #0.5 clk0 = 1; clk1 = 1;

        #0.5 clk0 = 0; clk1 = 0;
        sfp_ext_rd0 = 0; sfp_ext_rd1 = 0;
        #0.5 clk0 = 1; clk1 = 1;

        // wait for CDC settling
        tick(8);

        // verify sum exchange
        $display("cycle %2d: sum_out0=%0d sum_out1=%0d (expected sum0=%0d sum1=%0d)",
                  q, dut.sum_out0, dut.sum_out1, sum0[q], sum1[q]);
        $display("         sum_in0=%0d (should match sum_out1=%0d) match=%b",
                  dut.sum_in0, dut.sum_out1, dut.sum_in0 == dut.sum_out1);
        $display("         sum_in1=%0d (should match sum_out0=%0d) match=%b",
                  dut.sum_in1, dut.sum_out0, dut.sum_in1 == dut.sum_out0);
    end

    $display("\n##### Done #####");
    tick(10);
    $finish;
end

endmodule