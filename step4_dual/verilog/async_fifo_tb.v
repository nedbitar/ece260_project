`timescale 1ns/1ps

module async_fifo_tb;

    parameter bw    = 8;
    parameter depth = 8;

    reg wr_clk, rd_clk, reset;
    reg wr_en, rd_en;
    reg  [bw-1:0] wr_data;
    wire [bw-1:0] rd_data;
    wire full, empty;

    async_fifo #(
        .bw(bw),
        .depth(depth)
    ) dut (
        .reset(reset),
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );

    always #4 wr_clk = ~wr_clk;  // 125 MHz
    always #7 rd_clk = ~rd_clk;  // ~71 MHz

    task write_one;
        input [bw-1:0] data;
        begin
            @(posedge wr_clk); #1;
            if (!full) begin
                wr_en   = 1;
                wr_data = data;
                @(posedge wr_clk); #1;
                wr_en   = 0;
                $display("[WR @ %0t] data=%0d full=%b", $time, data, full);
            end else begin
                $display("[WR @ %0t] data=%0d full=1 (IGNORED)", $time, data);
            end
        end
    endtask

    task drain;
        integer timeout;
        begin
            timeout = 0;
            while (!empty && timeout < 50) begin
                @(posedge rd_clk); #1;
                rd_en = 1;
                @(posedge rd_clk); #1;
                rd_en = 0;
                @(posedge rd_clk); #1;
                $display("[RD @ %0t] data=%0d empty=%b", $time, rd_data, empty);
                timeout = timeout + 1;
            end
        end
    endtask

    task flush;
        begin
            wr_en = 0;
            rd_en = 0;
            repeat(20) begin
                @(posedge rd_clk); #1;
                rd_en = !empty;
            end
            rd_en = 0;
            repeat(10) @(posedge wr_clk);
            $display("--- flushed, empty=%b ---\n", empty);
        end
    endtask

    integer i;

    initial begin
        $dumpfile("async_fifo.vcd");
        $dumpvars(0, async_fifo_tb);

        wr_clk = 0; rd_clk = 0;
        wr_en  = 0; rd_en  = 0;
        wr_data = 0;

        reset = 1;
        #20;
        reset = 0;
        repeat(5) @(posedge wr_clk);

        // ---- Test 1: write then read ----
        $display("=== Test 1: Write then Read ===");
        write_one(8'hAA);
        write_one(8'hBB);
        write_one(8'hCC);
        write_one(8'hDD);

        repeat(10) @(posedge rd_clk);
        $display("--- Reading back ---");
        drain;
        flush;

        // ---- Test 2: overfill ----
        $display("=== Test 2: Overfill check ===");
        for (i = 0; i < depth+2; i = i+1)
            write_one(i);

        repeat(10) @(posedge rd_clk);
        $display("--- Draining ---");
        drain;
        flush;

        // ---- Test 3: simultaneous RW ----
        $display("=== Test 3: Simultaneous RW ===");
        fork
            begin
                for (i = 10; i < 14; i = i+1) begin
                    write_one(i);
                    repeat(3) @(posedge wr_clk);
                end
            end
            begin
                repeat(8) @(posedge rd_clk);
                repeat(4) begin
                    @(posedge rd_clk); #1;
                    if (!empty) begin
                        rd_en = 1;
                        @(posedge rd_clk); #1;
                        rd_en = 0;
                        @(posedge rd_clk); #1;
                        $display("[RD @ %0t] data=%0d", $time, rd_data);
                    end
                    repeat(4) @(posedge rd_clk);
                end
            end
        join

        $display("\n=== Done ===");
        #200 $finish;
    end

endmodule