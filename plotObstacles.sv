module plotObstacles (	input clk, Reset, frame_clk,
								input [9:0] DrawX, DrawY,
								input [9:0] PlayerX, PlayerY, 
								input [9:0] AIX, AIY,
								input [9:0] GroundSpeed,
								output logic [7:0] Red, Green, Blue,
								output logic isObs,
								output logic [3:0] PlayerCollide, AICollide
							);
							
	parameter [10:0] Car_speed = 11'd2;
	parameter [10:0] fast_Car_speed = 11'd3;
	parameter [31:0] right_right = 32'h82080080;
	parameter [31:0] right_left = 32'h20808208;
	parameter [31:0] left_right = 32'h22208200;
	parameter [31:0] left_left = 32'h20002800;
	parameter [4:0] rr_shift = 12;
	parameter [4:0] rl_shift = 12;
	parameter [4:0] lr_shift = 12;
	parameter [4:0] ll_shift = 12;
	parameter [4:0] AICollideBoxV = 20;
	parameter [4:0] AICollideBoxH = 15;
	parameter [4:0] PlayerCollideBox = 3;
	parameter [9:0] Car_X_Min=145;       // Leftmost point on the X axis
   parameter [9:0] Car_X_Max=495;     // Rightmost point on the X axis
   parameter [9:0] Car_Y_Min=0;       // Topmost point on the Y axis
   parameter [9:0] Car_Y_Max=479;     // Bottommost point on the Y axis
	
	logic [10:0] RL_Distance, RR_Distance, LL_Distance, LR_Distance;
	logic [10:0] RL_relativeSpeed, RR_relativeSpeed, LR_relativeSpeed, LL_relativeSpeed;
	logic [31:0] info;
		
	logic [4:0] Obs_Idx;
	logic EObs;
	
	logic reverse;	
	logic [2:0] CarIdx;
	logic [9:0] Car_XSize, Car_YSize;
	logic [9:0] ObsX, ObsY;
	logic [5:0] CarTileX, CarTileY;
	logic [8:0] CarSpriteX, CarSpriteY;
	logic [4:0]	colorIdx;
	
	logic [10:0] Y_Distance;

	assign Obs_Idx = Y_Distance[10:6];
	assign LR_relativeSpeed = fast_Car_speed + GroundSpeed;
	assign LL_relativeSpeed = Car_speed + GroundSpeed;
	assign RL_relativeSpeed = fast_Car_speed - GroundSpeed;
	assign RR_relativeSpeed = Car_speed - GroundSpeed;
	
	always_ff @ (posedge frame_clk) begin
		if (Reset) begin
			LR_Distance <= 11'd0;
			RR_Distance <= 11'd0;
			LL_Distance <= 11'd0;
			RL_Distance <= 11'd0;
		end
		else begin
			LL_Distance <= LL_Distance + LL_relativeSpeed;
			RL_Distance <= RL_Distance - RL_relativeSpeed;
			LR_Distance <= LR_Distance + LR_relativeSpeed;
			RR_Distance <= RR_Distance - RR_relativeSpeed;
		end
	end
	
	always_comb begin
		if (DrawX < 315) begin
			reverse = 1'b1;
			if (DrawX < 245) begin
				Y_Distance = DrawY - LL_Distance;
				info = left_left;
				ObsX = 165 + ll_shift + CarIdx;
			end
			else begin 
				info = left_right;
				ObsX = 245 + lr_shift + CarIdx;
				Y_Distance = DrawY - LR_Distance;
			end
		end
		else begin
			reverse = 1'b0;
			if (DrawX < 405) begin 
				info = right_left;
				ObsX = 325 + rl_shift + CarIdx;
				Y_Distance = DrawY - RL_Distance;
			end
			else begin 
				info = right_right;
				ObsX = 405 + rr_shift + CarIdx;
				Y_Distance = DrawY - RR_Distance;
			end
		end
	end
	
	always_comb begin
		if (info[Obs_Idx]) EObs = 1'b1;
		else EObs = 1'b0;
	end
	
	always_comb begin
		CarIdx = Obs_Idx[3:1];    
		if (~reverse && CarIdx == 7) CarIdx = 2;
		if (~reverse && CarIdx == 1) CarIdx = 0;
	end 
	
	assign Car_XSize = 47;  
	assign Car_YSize = 65;
	assign CarTileX = DrawX - ObsX;
	assign CarTileY = Y_Distance[5:0];
	assign ObsY = {Y_Distance[10:6], 6'd0};
	
	CarSpriteMatcher cpm1 (.*);
	fetch_carram fcr1 (.*);
	car_palette cp1 (.*);
	
	always_comb begin
		if ((ObsX < DrawX) && (DrawX < ObsX + Car_XSize) && EObs) begin	
			if (colorIdx == 5'h2) isObs = 1'b0;
			else isObs = 1'b1;
		end
		else isObs = 1'b0;
	end
	
	// Collide detecion
	enum logic [1:0] {LL, LR, RL, RR} AI_HLSec, Player_HLSec, AI_HRSec, Player_HRSec, AI_VLSec, Player_VLSec, AI_VRSec, Player_VRSec;
	logic [9:0] PlayerHLCX, PlayerHRCX, AIHLCX, AIHRCX;
	logic [9:0] PlayerVLCX, PlayerVRCX, AIVLCX, AIVRCX;
	logic [9:0] PlayerHTCY, PlayerHBCY, AIHTCY, AIHBCY;
	logic [9:0] PlayerVTCY, PlayerVBCY, AIVTCY, AIVBCY;
	
	assign PlayerHLCX = PlayerX - PlayerCollideBox + 12;
	assign PlayerHRCX = PlayerX + Car_XSize + PlayerCollideBox - 12;
	assign AIHLCX = AIX - AICollideBoxH;
	assign AIHRCX = AIX + Car_XSize + AICollideBoxH;
	
	assign PlayerVLCX = PlayerX;
	assign PlayerVRCX = PlayerX + Car_XSize;
	assign AIVLCX = AIX;
	assign AIVRCX = AIX + Car_XSize;
	
	assign PlayerHTCY = PlayerY;
	assign PlayerHBCY = PlayerY + Car_YSize;
	assign AIHTCY = AIY;
	assign AIHBCY = AIY + Car_YSize;
	
	assign PlayerVTCY = PlayerY - PlayerCollideBox;
	assign PlayerVBCY = PlayerY + Car_YSize + PlayerCollideBox;
	assign AIVTCY = AIY - AICollideBoxV;
	assign AIVBCY = AIY + Car_YSize + AICollideBoxV;
	
	always_comb begin
		if (PlayerHLCX < 235) Player_HLSec = LL;
		else if (PlayerHLCX < 315) Player_HLSec = LR;
		else if (PlayerHLCX < 405) Player_HLSec = RL;
		else Player_HLSec = RR;

		if (PlayerHRCX < 235) Player_HRSec = LL;
		else if (PlayerHRCX < 315) Player_HRSec = LR;
		else if (PlayerHRCX < 405) Player_HRSec = RL;
		else Player_HRSec = RR;
		
		if (PlayerVLCX < 235) Player_VLSec = LL;
		else if (PlayerVLCX < 315) Player_VLSec = LR;
		else if (PlayerVLCX < 405) Player_VLSec = RL;
		else Player_VLSec = RR;

		if (PlayerVRCX < 235) Player_VRSec = LL;
		else if (PlayerVRCX < 315) Player_VRSec = LR;
		else if (PlayerVRCX < 405) Player_VRSec = RL;
		else Player_VRSec = RR;
		
		if (AIHLCX < 405) AI_HLSec = RL;
		else AI_HLSec = RR;

		if (AIHRCX < 405) AI_HRSec = RL;
		else AI_HRSec = RR;
		
		if (AIVLCX < 405) AI_VLSec = RL;
		else AI_VLSec = RR;

		if (AIVRCX < 405) AI_VRSec = RL;
		else AI_VRSec = RR;
	end
	
	logic [10:0] PlayerHTLD, PlayerHTRD, AIHTLD, AIHTRD;
	logic [10:0] PlayerHBLD, PlayerHBRD, AIHBLD, AIHBRD;
	logic [10:0] PlayerVTLD, PlayerVTRD, AIVTLD, AIVTRD;
	logic [10:0] PlayerVBLD, PlayerVBRD, AIVBLD, AIVBRD;
	
	logic [4:0] PlayerHTLIdx, PlayerHTRIdx, PlayerHBLIdx, PlayerHBRIdx;
	logic [4:0] AIHTLIdx, AIHTRIdx, AIHBLIdx, AIHBRIdx;
	logic [4:0] PlayerVTLIdx, PlayerVTRIdx, PlayerVBLIdx, PlayerVBRIdx;
	logic [4:0] AIVTLIdx, AIVTRIdx, AIVBLIdx, AIVBRIdx;
	
	assign PlayerHTLIdx = PlayerHTLD[10:6];
	assign PlayerHTRIdx = PlayerHTRD[10:6];
	assign PlayerHBLIdx = PlayerHBLD[10:6];
	assign PlayerHBRIdx = PlayerHBRD[10:6];
	
	assign PlayerVTLIdx = PlayerVTLD[10:6];
	assign PlayerVTRIdx = PlayerVTRD[10:6];
	assign PlayerVBLIdx = PlayerVBLD[10:6];
	assign PlayerVBRIdx = PlayerVBRD[10:6];
	
	assign AIHTLIdx = AIHTLD[10:6];
	assign AIHTRIdx = AIHTRD[10:6];
	assign AIHBLIdx = AIHBLD[10:6];
	assign AIHBRIdx = AIHBRD[10:6];

	assign AIVTLIdx = AIVTLD[10:6];
	assign AIVTRIdx = AIVTRD[10:6];
	assign AIVBLIdx = AIVBLD[10:6];
	assign AIVBRIdx = AIVBRD[10:6];		
	
	logic [31:0] PHL_track, PHR_track, AHL_track, AHR_track;
	logic [31:0] PVL_track, PVR_track, AVL_track, AVR_track;
	
	always_comb begin
		if (Player_HLSec == RL) begin
			PlayerHTLD = PlayerHTCY - RL_Distance;
			PlayerHBLD = PlayerHBCY - RL_Distance;
			PHL_track = right_left;
		end
		else if (Player_HLSec == RR) begin
			PlayerHTLD = PlayerHTCY - RR_Distance;
			PlayerHBLD = PlayerHBCY - RR_Distance;
			PHL_track = right_right;
		end
		else if (Player_HLSec == LR) begin
			PlayerHTLD = PlayerHTCY - LR_Distance;
			PlayerHBLD = PlayerHBCY - LR_Distance;
			PHL_track = left_right;
		end
		else begin
			PlayerHTLD = PlayerHTCY - LL_Distance;
			PlayerHBLD = PlayerHBCY - LL_Distance;
			PHL_track = left_left;
		end
		
		if (Player_HRSec == RL) begin
			PlayerHTRD = PlayerHTCY - RL_Distance;
			PlayerHBRD = PlayerHBCY - RL_Distance;
			PHR_track = right_left;
		end
		else if (Player_HRSec == RR) begin
			PlayerHTRD = PlayerHTCY - RR_Distance;
			PlayerHBRD = PlayerHBCY - RR_Distance;
			PHR_track = right_right;
		end
		else if (Player_HRSec == LR) begin
			PlayerHTRD = PlayerHTCY - LR_Distance;
			PlayerHBRD = PlayerHBCY - LR_Distance;
			PHR_track = left_right;
		end
		else begin
			PlayerHTRD = PlayerHTCY - LL_Distance;
			PlayerHBRD = PlayerHBCY - LL_Distance;
			PHR_track = left_left;
		end
		
		if (AI_HLSec == RL) begin
			AIHTLD = AIHTCY - RL_Distance;
			AIHBLD = AIHBCY - RL_Distance;
			AHL_track = right_left;
		end
		else begin
			AIHTLD = AIHTCY - RR_Distance;
			AIHBLD = AIHBCY - RR_Distance;
			AHL_track = right_right;
		end
		
		if (AI_HRSec == RL) begin
			AIHTRD = AIHTCY - RL_Distance;
			AIHBRD = AIHBCY - RL_Distance;
			AHR_track = right_left;
		end
		else begin
			AIHTRD = AIHTCY - RR_Distance;
			AIHBRD = AIHBCY - RR_Distance;
			AHR_track = right_right;
		end
		
		if (Player_VLSec == RL) begin
			PlayerVTLD = PlayerVTCY - RL_Distance;
			PlayerVBLD = PlayerVBCY - RL_Distance;
			PVL_track = right_left;
		end
		else if (Player_VLSec == RR) begin
			PlayerVTLD = PlayerVTCY - RR_Distance;
			PlayerVBLD = PlayerVBCY - RR_Distance;
			PVL_track = right_right;
		end
		else if (Player_VLSec == LR) begin
			PlayerVTLD = PlayerVTCY - LR_Distance;
			PlayerVBLD = PlayerVBCY - LR_Distance;
			PVL_track = left_right;
		end
		else begin
			PlayerVTLD = PlayerVTCY - LL_Distance;
			PlayerVBLD = PlayerVBCY - LL_Distance;
			PVL_track = left_left;
		end
		
		if (Player_VRSec == RL) begin
			PlayerVTRD = PlayerVTCY - RL_Distance;
			PlayerVBRD = PlayerVBCY - RL_Distance;
			PVR_track = right_left;
		end
		else if (Player_VRSec == RR) begin
			PlayerVTRD = PlayerVTCY - RR_Distance;
			PlayerVBRD = PlayerVBCY - RR_Distance;
			PVR_track = right_right;
		end
		else if (Player_VRSec == LR) begin
			PlayerVTRD = PlayerVTCY - LR_Distance;
			PlayerVBRD = PlayerVBCY - LR_Distance;
			PVR_track = left_right;
		end
		else begin
			PlayerVTRD = PlayerVTCY - LL_Distance;
			PlayerVBRD = PlayerVBCY - LL_Distance;
			PVR_track = left_left;
		end
		
		if (AI_VLSec == RL) begin
			AIVTLD = AIVTCY - RL_Distance;
			AIVBLD = AIVBCY - RL_Distance;
			AVL_track = right_left;
		end
		else begin
			AIVTLD = AIVTCY - RR_Distance;
			AIVBLD = AIVBCY - RR_Distance;
			AVL_track = right_right;
		end
		
		if (AI_VRSec == RL) begin
			AIVTRD = AIVTCY - RL_Distance;
			AIVBRD = AIVBCY - RL_Distance;
			AVR_track = right_left;
		end
		else begin
			AIVTRD = AIVTCY - RR_Distance;
			AIVBRD = AIVBCY - RR_Distance;
			AVR_track = right_right;
		end
		
	end
	
	always_ff @ (posedge frame_clk) begin
		PlayerCollide[0] <= PVL_track[PlayerVTLIdx] || PVR_track[PlayerVTRIdx];
		PlayerCollide[2] <= PVL_track[PlayerVBLIdx] || PVR_track[PlayerVBRIdx];
		PlayerCollide[1] <= PHL_track[PlayerHTLIdx] || PHL_track[PlayerHBLIdx];
		PlayerCollide[3] <= PHR_track[PlayerHTRIdx] || PHR_track[PlayerHBRIdx];
		
		AICollide[0] <= AVL_track[AIVTLIdx] || AVR_track[AIVTRIdx];
		AICollide[1] <= AVL_track[AIVBLIdx] || AVR_track[AIVBRIdx];
		AICollide[2] <= AHL_track[AIHTLIdx] || AHL_track[AIHBLIdx];
		AICollide[3] <= AHR_track[AIHTRIdx] || AHR_track[AIHBRIdx];
	end
endmodule
