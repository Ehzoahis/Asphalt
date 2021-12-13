//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

module color_mapper (	input [9:0] DrawX, DrawY,
								input pixel_clk, blank, Reset, frame_clk,
								input [7:0] keycode_0, keycode_1,
								output logic [7:0]  Red, Green, Blue
			);
	
logic [7:0] R_p, G_p, B_p;
logic [7:0] R_b, G_b, B_b;
logic [7:0] R_o, G_o, B_o;
logic [7:0] R_a, G_a, B_a;
logic [10:0] Distance;
logic isPlayer, isObs, isAI;
logic [9:0] PlayerX, PlayerY, PlayerSpeed, GroundSpeed;
logic GameLose, GameStart, GameWin;
logic [9:0] AIX, AIY;
logic [3:0]	PlayerCollide, AICollide;
logic inFrame;
logic [15:0] PlayerDistance, TarDistance;
logic [2:0] Scale;
logic slowClk;
logic [4:0] slow_counter;

always_ff @ (posedge Reset or posedge frame_clk) begin
	if (Reset) begin
		slowClk <= 1'b0;
		slow_counter <= 5'd0;
	end
	else if (slow_counter == 5'd15) begin
		slowClk <= ~slowClk;
		slow_counter <= 5'b0;
	end
	else begin
		slowClk <= slowClk;
		slow_counter <= slow_counter + 1;
	end
end



always_ff @ (posedge Reset or posedge slowClk) begin
	if (Reset) Scale <= 3'b000;
	else if (PlayerCollide[0] || PlayerCollide[1] || PlayerCollide[2] || PlayerCollide[3]) begin
		if (Scale != 3'b111) Scale <= Scale + 1;
		else Scale <= Scale;
	end
	else Scale <= 3'b000;
end

always_ff @ (posedge Reset or posedge frame_clk) begin
	if (Reset) begin
		GameStart <= 1'b0;
		GameWin <= 1'b0;
		GameLose <= 1'b0;
	end
	else if (keycode_1 != 0) begin
		GameStart <= 1'b1;
		GameWin <= 1'b0;
		GameLose <= 1'b0;
	end
	else if (TarDistance >= 16'h7FFF || Scale == 3'b111 && ~GameWin) begin
		GameStart <= GameStart;
		GameWin <= 1'b0;
		GameLose <= 1'b1;
	end
	else if (TarDistance <= 65 && ~ww) begin
		GameStart <= GameStart;
		GameWin <= 1'b1;
		GameLose <= 1'b0;
	end
	else begin
		GameStart <= GameStart;
		GameWin <= GameWin;
		GameLose <= GameLose;
	end
end

always_ff @ (posedge frame_clk) begin
	if (Reset) Distance <= 11'h000;
	else Distance <= Distance + GroundSpeed;
end

plotObstacles po0 (.*, .clk(pixel_clk), .Red(R_o), .Green(G_o), .Blue(B_o));
playerLogic pl0 (.*);
aiLogic al0 (.*);
plotBackground pbg0 (.*, .Red(R_b), .Green(G_b), .Blue(B_b));
plotPlayer pp0 (.*, .clk(pixel_clk), .Red(R_p), .Green(G_p), .Blue(B_p));
plotAI pa0 (.*, .clk(pixel_clk), .Red(R_a), .Green(G_a), .Blue(B_a));


always_ff @ (posedge pixel_clk) begin
	if (~blank) begin
		Red <= 8'h00;
		Green <= 8'h00;
		Blue <= 8'h00;
	end
	
	else if (isPlayer) begin
			Red <= R_p;
			Green <= G_p;
			Blue <= B_p;
	end
	
	else if (isAI) begin
			Red <= R_a;
			Green <= G_a;
			Blue <= B_a;
	end
	
	else if (isObs) begin
			Red <= R_o >> Scale;
			Green <= G_o >> Scale;
			Blue <= B_o >> Scale;
	end
	
	else begin
			if (GameWin) Red = 8'hff;
			else Red <= R_b >> Scale;
			Green <= G_b >> Scale;
			Blue <= B_b >> Scale;
	end
end
endmodule		
