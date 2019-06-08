// Verilog Template
// Simple Dual Port RAM with separate read/write addresses and
// single read/write clock

module DualPort_SRAM
#(parameter DATA_WIDTH=48, parameter ADDR_WIDTH=11)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] rdaddress, wraddress,
	input wren, clock,
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	always @ (posedge clock)
	begin
		// Write
		if (wren)
			ram[wraddress] <= data;

		// Read (if rdaddress == wraddress, return OLD data).	To return
		// NEW data, use = (blocking write) rather than <= (non-blocking write)
		// in the write assignment.	 NOTE: NEW data may require extra bypass
		// logic around the RAM.
		q <= ram[rdaddress];
	end

endmodule