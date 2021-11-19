`define WINDOW_HH 60 // 240
`define WINDOW_W 160 // 640
`define SCALE 2 // 0

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
logic [9:0] DrawXS, DrawYS;
assign DrawXS = DrawX >> `SCALE;
assign DrawYS = DrawY >> `SCALE;

always_ff @ (posedge pixel_clk) begin
	if (~isTrack) cur_sec <= Far;
	else if (DrawXS == 0 & isTrack) cur_sec <= GrassL;
	else cur_sec <= next_sec;
end
	
always_comb	begin
	next_sec = cur_sec;
	unique case (cur_sec)
		GrassL	: if (DrawXS >= track[19:10])	next_sec = BumpL;
		BumpL		: if (DrawXS >= track[9:0])	next_sec = Road;
		Road		: if (DrawXS >= track[19:10])	next_sec = BumpR;
		BumpR		: if (DrawXS >= track[9:0])	next_sec = GrassR;
		GrassR	: if (DrawXS >= `WINDOW_W)	next_sec = GrassL;
		Far		: next_sec = GrassL;
		default: ;
	endcase
		
	unique case (next_sec)
		GrassL	: 	begin
							if (DrawXS >= `WINDOW_W) vram_addr = DrawYS-`WINDOW_HH+1;
							else vram_addr = DrawYS-`WINDOW_HH;
						end
		BumpL		: vram_addr = DrawYS-`WINDOW_HH;
		Road		: vram_addr = DrawYS;
		BumpR		: vram_addr = DrawYS;
		GrassR	: vram_addr = DrawYS;
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
