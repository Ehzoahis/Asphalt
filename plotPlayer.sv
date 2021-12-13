module plotPlayer (	input clk,
							input [9:0] PlayerX, PlayerY,
							input [9:0] DrawX, DrawY,
							output logic isPlayer,
							output logic [7:0] Red, Green, Blue);
							
	logic [2:0] CarIdx;
	logic [9:0] Car_XSize, Car_YSize;	
	logic [5:0] CarTileX, CarTileY;
	logic [8:0] CarSpriteX, CarSpriteY;
	logic [4:0]	colorIdx;
	logic reverse;
	
	assign CarIdx = 4'h7;    
	assign reverse = 1'b0;
	assign Car_XSize = 47;  
	assign Car_YSize = 65;  
	assign CarTileX = DrawX - PlayerX;
	assign CarTileY = DrawY - PlayerY;
	
	CarSpriteMatcher cpm0 (.*);
	fetch_carram fcr0 (.*);
	car_palette cp0 (.*);
	
	always_comb begin
		if ((PlayerX < DrawX) && (DrawX < PlayerX + Car_XSize) && (PlayerY < DrawY) && (DrawY < PlayerY + Car_YSize)) begin	
			if (colorIdx == 5'h2) isPlayer = 1'b0;
			else isPlayer = 1'b1;
		end
		else isPlayer = 1'b0;
	end
endmodule
	