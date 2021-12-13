module playerLogic ( input Reset, frame_clk,
							input [7:0] keycode_0, keycode_1,
							output logic [9:0] PlayerX, PlayerY, PlayerSpeed, GroundSpeed,
							output logic [15:0] PlayerDistance);
							
	logic [9:0] Car_X_Pos, Car_X_Motion, Car_Y_Pos, Car_Y_Motion, Car_XSize, Car_YSize, Car_Speed;
	 
	 parameter [9:0] Car_X_Init=336; 
    parameter [9:0] Car_Y_Init=315;  
    parameter [9:0] Car_X_Min=145;       // Leftmost point on the X axis
    parameter [9:0] Car_X_Max=495;     // Rightmost point on the X axis
    parameter [9:0] Car_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Car_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Default_CarSpeed=3;      // Step size on the X axis

    assign Car_XSize = 10'd47;  
	 assign Car_YSize = 10'd67; 

    always_ff @ (posedge Reset or posedge frame_clk ) begin: Move_Car
        if (Reset) begin 
				Car_Speed <= Default_CarSpeed;
            Car_Y_Motion <= 10'd0; 
				Car_X_Motion <= 10'd0;
				Car_Y_Pos <= Car_Y_Init;
				Car_X_Pos <= Car_X_Init;
				GroundSpeed <= Default_CarSpeed;
				PlayerDistance <= 16'd0;
        end
           
        else begin 
				 if ( (Car_Y_Pos + Car_YSize + 10'd20) >= Car_Y_Max && Car_Speed <= Default_CarSpeed - 1 )  // Car is at the bottom edge
					  GroundSpeed <= Car_Speed;  
				  
				 else if ( Car_Y_Pos <= Car_Y_Min + 10'd160 && Car_Speed >= 10'd2)  // Car is at the top edge
					  GroundSpeed <= Car_Speed;
					  
				 else 
					   GroundSpeed <= Default_CarSpeed;

				
				case (keycode_0)
					8'h04 : 
						begin
							if ( Car_X_Pos > Car_X_Min)
								Car_X_Motion <= -2;//A
							else
								Car_X_Motion <= 0;
						end 
					8'h07 : 
						begin
							if ( (Car_X_Pos + Car_XSize) < Car_X_Max )
								Car_X_Motion <= 2;//D
							else
								Car_X_Motion <= 0;
						end
					default: Car_X_Motion <= 0;
				endcase
				
				case (keycode_1)
					8'h16 : 
						begin
							if ( (Car_Y_Pos + Car_YSize + 10'd20) >= Car_Y_Max) Car_Speed <= Default_CarSpeed - 2;
							else Car_Speed <= Default_CarSpeed - 1 ;//S
						end
							  
					8'h1A : 
						begin
							if (Car_Speed + 1 <= 5) Car_Speed <= Car_Speed + 1 ;//W
							else Car_Speed <= Car_Speed;
						end	  
					default: 
						begin
							if (Car_Speed > 0 && Car_Speed - 1 >= Default_CarSpeed) Car_Speed <= Car_Speed - 1 ;
							else Car_Speed <= Car_Speed;
						end
				endcase
					 
				Car_Y_Pos <= (Car_Y_Pos - Car_Speed + GroundSpeed);  // Update Car position
				Car_X_Pos <= (Car_X_Pos + Car_X_Motion);
				PlayerDistance <= PlayerDistance + PlayerSpeed;
				 
		end  
    end
       
    assign PlayerX = Car_X_Pos;
   
    assign PlayerY = Car_Y_Pos;
   
    assign PlayerSpeed = Car_Speed;
    

endmodule
