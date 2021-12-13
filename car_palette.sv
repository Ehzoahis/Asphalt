module car_palette (	input [4:0] colorIdx,
							output logic [7:0] Red, Green, Blue);

always_comb begin
	unique case (colorIdx)
	16'd0:
		begin
			 Red = 8'h43;
			 Green = 8'h1;
			 Blue = 8'h26;
		end

		16'd1:
		begin
			 Red = 8'hb8;
			 Green = 8'hb8;
			 Blue = 8'hb8;
		end

		16'd2:
		begin
			 Red = 8'he2;
			 Green = 8'h0;
			 Blue = 8'h7e;
		end

		16'd3:
		begin
			 Red = 8'h7;
			 Green = 8'h7;
			 Blue = 8'h7;
		end

		16'd4:
		begin
			 Red = 8'he8;
			 Green = 8'h81;
			 Blue = 8'h10;
		end

		16'd5:
		begin
			 Red = 8'h4e;
			 Green = 8'h51;
			 Blue = 8'hca;
		end

		16'd6:
		begin
			 Red = 8'hb0;
			 Green = 8'h1a;
			 Blue = 8'hf;
		end

		16'd7:
		begin
			 Red = 8'hf6;
			 Green = 8'hf7;
			 Blue = 8'hf6;
		end

		16'd8:
		begin
			 Red = 8'h8f;
			 Green = 8'h64;
			 Blue = 8'h16;
		end

		16'd9:
		begin
			 Red = 8'hfc;
			 Green = 8'hd9;
			 Blue = 8'hc;
		end

		16'd10:
		begin
			 Red = 8'h24;
			 Green = 8'h1c;
			 Blue = 8'ha5;
		end

		16'd11:
		begin
			 Red = 8'h17;
			 Green = 8'h15;
			 Blue = 8'h17;
		end

		16'd12:
		begin
			 Red = 8'hf1;
			 Green = 8'hee;
			 Blue = 8'h99;
		end

		16'd13:
		begin
			 Red = 8'h56;
			 Green = 8'h90;
			 Blue = 8'h2f;
		end

		16'd14:
		begin
			 Red = 8'h3c;
			 Green = 8'h2c;
			 Blue = 8'hf9;
		end

		16'd15:
		begin
			 Red = 8'hd4;
			 Green = 8'hd4;
			 Blue = 8'hd5;
		end

		16'd16:
		begin
			 Red = 8'hae;
			 Green = 8'h1;
			 Blue = 8'h61;
		end

		16'd17:
		begin
			 Red = 8'h97;
			 Green = 8'h96;
			 Blue = 8'h96;
		end

		16'd18:
		begin
			 Red = 8'h8;
			 Green = 8'h4d;
			 Blue = 8'h0;
		end

		16'd19:
		begin
			 Red = 8'hee;
			 Green = 8'h2a;
			 Blue = 8'h23;
		end

		16'd20:
		begin
			 Red = 8'h13;
			 Green = 8'h12;
			 Blue = 8'h4a;
		end

		16'd21:
		begin
			 Red = 8'h2a;
			 Green = 8'h2;
			 Blue = 8'h17;
		end

		16'd22:
		begin
			 Red = 8'h7f;
			 Green = 8'h13;
			 Blue = 8'hb;
		end

		16'd23:
		begin
			 Red = 8'h1;
			 Green = 8'h27;
			 Blue = 8'h1;
		end

		16'd24:
		begin
			 Red = 8'hc3;
			 Green = 8'hb8;
			 Blue = 8'h6e;
		end

		16'd25:
		begin
			 Red = 8'h26;
			 Green = 8'h26;
			 Blue = 8'h25;
		end

		16'd26:
		begin
			 Red = 8'h51;
			 Green = 8'h22;
			 Blue = 8'hc;
		end

		16'd27:
		begin
			 Red = 8'h74;
			 Green = 8'h4;
			 Blue = 8'h42;
		end

		16'd28:
		begin
			 Red = 8'h39;
			 Green = 8'h3a;
			 Blue = 8'h38;
		end

		16'd29:
		begin
			 Red = 8'h20;
			 Green = 8'h23;
			 Blue = 8'h7b;
		end

		16'd30:
		begin
			 Red = 8'hd5;
			 Green = 8'hbc;
			 Blue = 8'h13;
		end

		16'd31:
		begin
			 Red = 8'h66;
			 Green = 8'h66;
			 Blue = 8'h5c;
		end

	endcase
end
endmodule
