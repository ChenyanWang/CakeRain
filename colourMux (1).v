module colourMux (input [2:0] randNum, output reg [2:0] clrOut);

	always @(randNum)
		begin
			case (randNum[2:0])
				3'b000: clrOut = 3'b001; //blue
				3'b001: clrOut = 3'b010; //green		
				3'b010: clrOut = 3'b011; //aqua (blue/green)
				3'b011: clrOut = 3'b100; //red
				3'b100: clrOut = 3'b101; //magenta
				3'b101: clrOut = 3'b110; //yellow
				3'b110: clrOut = 3'b001; //blue 
				3'b111: clrOut = 3'b110; //yellow
				default:
					clrOut = 3'b101; //magenta
			endcase
		end
		
endmodule

