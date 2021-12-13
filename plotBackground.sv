module plotBackground ( input [9:0] DrawX, DrawY,
								input [10:0]	Distance,
								output logic [7:0] Red, Green, Blue
								);
								
enum logic [1:0] {Grass, Road, White, Orange} ColorIdx;
logic [9:0] YDistance;
assign YDistance = DrawY - Distance[9:0];		
			
always_comb begin
	if (0 <= DrawX && DrawX < 145) ColorIdx = Grass;
	else if (DrawX < 155) ColorIdx = Road;
	else if (DrawX < 165) ColorIdx = White;
	else if (DrawX < 235) ColorIdx = Road;
	else if (DrawX < 245) begin
		if (YDistance[6]) ColorIdx = White;
		else ColorIdx = Road;
	end
	else if (DrawX < 315) ColorIdx = Road;
	else if (DrawX < 325) ColorIdx = Orange;
	else if (DrawX < 395) ColorIdx = Road;
	else if (DrawX < 405) begin
		if (YDistance[6]) ColorIdx = White;
		else ColorIdx = Road;
	end
	else if (DrawX < 475) ColorIdx = Road;
	else if (DrawX < 485) ColorIdx = White;
	else if (DrawX < 495) ColorIdx = Road;
	else ColorIdx = Grass;
end

always_comb begin
	unique case(ColorIdx) 
		Grass :
			begin
				Red = 8'h1c;
				Green = 8'ha3;
				Blue = 8'h39;
			end
		Road :
			begin
				Red = 8'h31;
				Green = 8'h31;
				Blue = 8'h31;
			end
		White :
			begin
				Red = 8'hff;
				Green = 8'hff;
				Blue = 8'hff;
			end
		Orange :
			begin
				Red = 8'hf3;
				Green = 8'h98;
				Blue = 8'h00;
			end
	endcase
end
endmodule
