module sram_w16 (CLK, D, Q, CEN, WEN, A);

  parameter sram_bit = 128;

  input                  CLK;
  input                  WEN;
  input                  CEN;
  input  [sram_bit-1:0]  D;
  input  [3:0]           A;
  output reg [sram_bit-1:0] Q;

  reg [sram_bit-1:0] memory [0:15];

  always @(posedge CLK) begin
    if (!CEN) begin
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