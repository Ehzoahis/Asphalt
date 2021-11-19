`define WINDOW_W 480
`define WINDOW_H 640
`define SCALE 2

module PlotTrack	(
				input pixel_clk,
				input [31:0] track,
				input [9:0] DrawX,
				input [9:0] DrawY,
				input isTrack,
				output [3:0] red,
				output [3:0] green,
				output [3:0] blue,
				output [8:0] vram_addr
	);

enum logic [3:0] {Far, GrassL, BumpL, Road, BumpR, GrassR} cur_sec, next_sec;	

always_ff @ (posedge pixel_clk) begin
	if (~isTrack) cur_sec <= Far;
	else if (DrawX == 0 & isTrack) cur_sec <= GrassL;
	else cur_sec <= next_sec;
end
	
always_comb	begin
	next_sec = cur_sec;
	unique case (cur_sec)
		GrassL	: if (DrawX >= track[19:10])	next_sec = BumpL;
		BumpL		: if (DrawX >= track[9:0])	next_sec = Road;
		Road		: if (DrawX >= track[19:10])	next_sec = BumpR;
		BumpR		: if (DrawX >= track[9:0])	next_sec = GrassR;
		GrassR	: if (DrawX >= 640)	next_sec = GrassL;
		Far		: next_sec = GrassL;
		default: ;
	endcase
		
	unique case (next_sec)
		GrassL	: 	begin
							if (DrawX >= 640) vram_addr = DrawY-239;
							else vram_addr = DrawY-240;
						end
		BumpL		: vram_addr = DrawY-240;
		Road		: vram_addr = DrawY;
		BumpR		: vram_addr = DrawY;
		GrassR	: vram_addr = DrawY;
		default	: vram_addr = 9'hXXX;
	endcase
		
	unique case (cur_sec)
		GrassL	: 	begin
							red = 4'h0;
							green = 4'hf;
							blue = 4'h0;
						end
		BumpL		: 	begin
							if (track[31]) begin
								red = 4'hf;
								green = 4'hf;
								blue = 4'hf;
							end
							else begin
								red = 4'hf;
								green = 4'h0;
								blue = 4'h0;
							end
						end
		Road		: 	begin
							red = 4'h3;
							green = 4'h3;
							blue = 4'h3;
						end
		BumpR		: 	begin
							if (track[31]) begin
								red = 4'hf;
								green = 4'hf;
								blue = 4'hf;
							end
							else begin
								red = 4'hf;
								green = 4'h0;
								blue = 4'h0;
							end
						end
		GrassR	:	begin
							red = 4'h0;
							green = 4'hf;
							blue = 4'h0;
						end
		Far		:	begin
							red = 4'h0;
							green = 4'h0;
							blue = 4'hf;
						end
		default	: 	begin
							red = 4'hX;
							green = 4'hX;
							blue = 4'hX;
						end
	endcase
end

endmodule
