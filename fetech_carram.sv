module fetch_carram (	input clk,
								input [8:0] CarSpriteX, CarSpriteY,
								output logic [4:0] colorIdx
								);
	logic [13:0] address;
	logic [1:0] offset, delayed_offset;
	logic [15:0] pixelIdx;
	logic [19:0] q;
	
	assign pixelIdx = CarSpriteX + CarSpriteY * 404;
	assign offset = pixelIdx[1:0];
	assign address = pixelIdx >> 2;
	
	car_ram cr0 (.*, .clock(clk), .wren(1'b0), .data());
	
	always_ff @ (posedge clk) begin
		delayed_offset <= offset;
	end
	
	always_comb begin
		unique case (delayed_offset)
			2'b11 : colorIdx = q[4:0];
			2'b10 : colorIdx = q[9:5];
			2'b01 : colorIdx = q[14:10];
			2'b00 : colorIdx = q[19:15];
		endcase
	end
	

endmodule
