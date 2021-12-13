module plotAI (	input clk,
						input [9:0] AIX, AIY,
						input [9:0] DrawX, DrawY,
						input inFrame,
						output logic isAI,
						output logic [7:0] Red, Green, Blue);
						
	logic [2:0] CarIdx;
	logic [9:0] Car_XSize, Car_YSize;	
	logic [5:0] CarTileX, CarTileY;
	logic [8:0] CarSpriteX, CarSpriteY;
	logic [4:0]	colorIdx;
	logic reverse;
	
	assign CarIdx = 4'h1;    
	assign reverse = 1'b0;
	assign Car_XSize = 47;  
	assign Car_YSize = 65;  
	assign CarTileX = DrawX - AIX;
	always_comb begin
		if (AIY > 0)  CarTileY = DrawY - AIY;
		else  CarTileY = DrawY;
	end
	
	CarSpriteMatcher cpm2 (.*);
	fetch_carram fcr2 (.*);
	car_palette cp2 (.*);
	
	always_comb begin
		if (inFrame) begin
			if ((AIX < DrawX) && (DrawX < AIX + Car_XSize) && ((AIY < DrawY) || (0 > AIY)) && (DrawY < AIY + Car_YSize)) begin	
				if (colorIdx == 5'h2) isAI = 1'b0;
				else isAI = 1'b1;
			end
			else isAI = 1'b0;
		end
		else isAI = 1'b0;
	end
endmodule
	