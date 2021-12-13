module CarSpriteMatcher	(	input [2:0] CarIdx,
									input [5:0] CarTileX, CarTileY, 
									input reverse,
									output logic [8:0] CarSpriteX, CarSpriteY
								);
									
logic [2:0] CarCol;
logic CarRow;
assign CarCol = CarIdx;
assign CarRow = reverse;

assign CarSpriteX = CarCol * 51 + CarTileX; // 51 -- tile width + horizontal intv.
assign CarSpriteY = CarRow * 67 + CarTileY; // 67 -- tile height

endmodule
