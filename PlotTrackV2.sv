`define WINDOW_HH 240
`define WINDOW_W 640
`define SCALE 0

module PlotTrackv2	(
				input pixel_clk,
				input [31:0] track,
				input [9:0] DrawX,
				input [9:0] DrawY,
				input isTrack,
				output [3:0] red,
				output [3:0] green,
				output [3:0] blue
	);

enum logic [3:0] {Far, GrassL, BumpL, Road, BumpR, GrassR} cur_sec, next_sec;	

logic [9:0] MidPoint, RoadWidth, ClipWidth;
assign MidPoint = track[29:20];
assign RoadWidth = track[19:10];
assign ClipWidth = track[9:0];

logic [9:0] DrawXS, DrawYS;
assign DrawXS = DrawX >> `SCALE;
assign DrawYS = DrawY >> `SCALE;

always_ff @ (posedge pixel_clk) begin
	if (~isTrack) cur_sec <= Far;
	else cur_sec <= next_sec;
end

always_comb begin
	next_sec = cur_sec;
	if (isTrack) begin
		if (DrawXS < MidPoint - RoadWidth - ClipWidth & MidPoint > RoadWidth + ClipWidth) next_sec = GrassL;
		else if (DrawXS < MidPoint - RoadWidth) next_sec = BumpL;
		else if (DrawXS < MidPoint + RoadWidth) next_sec = Road;
		else if (DrawXS < MidPoint + RoadWidth + ClipWidth) next_sec = BumpR;
		else next_sec = GrassR;
	end
	else
		next_sec = Far;
end

always_comb	begin
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
