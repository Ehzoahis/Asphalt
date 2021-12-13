module aiLogic (	input frame_clk, Reset, GameStart,
						input [3:0] AICollide,
						input [9:0] PlayerSpeed,
						input [9:0] PlayerX, PlayerY,GroundSpeed,
						input [7:0] keycode_1,
						input [15:0] PlayerDistance,
						output logic inFrame,
						output logic [9:0] AIX, AIY,
						output logic [15:0] TarDistance
						);
	logic [9:0] Car_X_Pos, Car_X_Motion, Car_Y_Pos, Car_Y_Motion, Car_XSize, Car_YSize, CarSpeed, realtiveSpeed;
	logic [15:0] AIDistance;
	enum logic {RL, RR} AI_LSec, AI_RSec;
	enum logic [2:0] {Left, Right, Slow, Init, Straight, SpeedUp} CurState, NextState;
	
	parameter [9:0] Car_Y_Init_Dist=180; 
	parameter [9:0] Car_X_Init=336; 	
	parameter [9:0] Car_X_Min=325;       // Leftmost point on the X axis
	parameter [9:0] Car_X_Max=495;     // Rightmost point on the X axis
	parameter [9:0] Car_Y_Min=0;       // Topmost point on the Y axis
	parameter [9:0] Car_Y_Max=479;     // Bottommost point on the Y axis
	parameter [9:0] Default_CarSpeed=5;

	assign Car_XSize = 10'd47;  
	assign Car_YSize = 10'd67; 
	assign realtiveSpeed = CarSpeed - GroundSpeed;
	assign TarDistance = AIDistance - PlayerDistance;
	
	always_comb begin
		if (AIX > 405) AI_LSec = RR;
		else AI_LSec = RL;
		if (AIX + Car_XSize < 395) AI_RSec = RL;
		else AI_RSec = RR;
		
		if (PlayerY - TarDistance + Car_YSize < Car_Y_Min) inFrame = 1'b0;
		else if (PlayerY - TarDistance > Car_Y_Max) inFrame = 1'b0;
		else inFrame = 1'b1;
	end

	always_ff @ (posedge Reset or posedge frame_clk) begin
		if (Reset) begin
			CurState <= Init;
			Car_X_Pos <= Car_X_Init;
			Car_Y_Pos <= PlayerY - Car_Y_Init_Dist;
			AIDistance <= Car_Y_Init_Dist;
		end
		
		else begin
			CurState <= NextState;
			Car_X_Pos <= Car_X_Pos + Car_X_Motion;
			Car_Y_Pos <= Car_Y_Pos - realtiveSpeed;	
			AIDistance <= AIDistance + CarSpeed;
		end
	end
	
	always_comb begin
		NextState = CurState;
		unique case (CurState)
			Init	: 
				if (GameStart) NextState = Straight;
			Straight	:
				begin
					if (AICollide[0]) NextState = Slow;
					else NextState = Straight;				
				end
			Slow :
				begin
					if (AI_LSec == RR) NextState = Left;
					else if (AI_RSec == RL) NextState = Right;
				end
			Left	:
				begin
					if (AI_RSec == RL && ~AICollide[3]) NextState = Straight;
				end
			Right	:
				begin
					if (AI_LSec == RR && ~AICollide[2]) NextState = Straight;
				end
		endcase
	end
	
	always_ff @ (posedge frame_clk) begin
		unique case (CurState)
			Init	: 
				begin
					CarSpeed <= Default_CarSpeed - 2;
					Car_X_Motion <= 10'd0;
				end
			Straight	:
				begin
					CarSpeed <= Default_CarSpeed;
					Car_X_Motion <= 10'd0;
				end
			Slow :
				begin
					CarSpeed <= CarSpeed - 2;
					Car_X_Motion <= 10'd0;
				end
			Left	:
				begin
					if (~AICollide[2]) begin
						Car_X_Motion <= -2;
						CarSpeed <= CarSpeed;
					end
					else begin 
						Car_X_Motion <= 0;
						if (AICollide[0]) CarSpeed <= Default_CarSpeed - 3;
						else CarSpeed <= CarSpeed;
					end
				end
			Right	:
				begin
					if (~AICollide[3]) Car_X_Motion <= 2;
					else Car_X_Motion <= 0;
					CarSpeed <= CarSpeed;
				end
		endcase
	end

	 assign AIX = Car_X_Pos;
	 always_comb begin
		if (Car_Y_Pos < 0) AIY = 0;
		else AIY = Car_Y_Pos;
	 end

endmodule
