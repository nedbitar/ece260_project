module sram_w16 (CLK, reset, D, Q, CEN, WEN, A);

  parameter sram_bit = 128;

  input                  CLK;
  input                  reset;
  input                  WEN;
  input                  CEN;
  input  [sram_bit-1:0]  D;
  input  [3:0]           A;
  output reg [sram_bit-1:0] Q;

  reg [sram_bit-1:0] memory [0:15];

  integer i;

  always @(posedge CLK or posedge reset) begin
    if (reset) begin
      Q <= 'b0;
      for (i = 0; i < 16; i = i + 1)
        memory[i] <= 'b0;
    end
    else if (!CEN) begin
      if (!WEN) begin
        // write
        memory[A] <= D;
      end
      else begin
        // read
        Q <= memory[A];
      end
    end
  end

endmodule