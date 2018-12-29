module catch_observer (
	input clk,
	input resetn,
	input [7:0] cake1_x, cake2_x, cake3_x, cherry_x, plate_x,
	input [6:0] cake1_y, cake2_y, cake3_y, cherry_y, plate_y,
	input [2:0] cake1_clr, cake2_clr, cake3_clr, cherry_clr,
	output reg caught_cake, caught_cherry, 
	output reg [2:0] caught_clr
	); // Colour of cake caught; black if none caught
	
	 wire saveEn;
	 //assign saveEn = caught_cake;
	
    always@(posedge clk)
	 begin
			if (!resetn)
			begin
					caught_cake <= 1'b0;
					caught_cherry <= 1'b0; // Not caught
					caught_clr <= 3'b0; // default if not caught
			end 
				
			else 
			begin
					caught_cake <= 1'b0;
					caught_cherry <= 1'b0; // Not caught
					caught_clr <= 3'b0; // default if not caught
			
				if ( (cake1_y >= plate_y - 7'd6) && 
				((cake1_x <= plate_x + 8'd8) || (cake1_x >= plate_x - 8'd8)) )
					begin
					caught_cake <= 1'b1;
					caught_cherry <= 1'b0; // Not caught
					caught_clr <= cake1_clr;
					end
				
				if ( (cake2_y >= plate_y - 7'd6) && 
				((cake2_x <= plate_x + 8'd8) || (cake2_x >= plate_x - 8'd8)))
					begin
					caught_cake <= 1'b1;
					caught_cherry <= 1'b0; // Not caught
					caught_clr <= cake2_clr;
					end
				
				if ( (cake3_y >= plate_y - 7'd6) && 
				((cake3_x <= plate_x + 8'd8) || (cake3_x >= plate_x - 8'd8)))
					begin
					caught_cake <= 1'b1;
					caught_cherry <= 1'b0; // Not caught
					caught_clr <= cake3_clr;
					end
				
				if ( (cherry_y >= plate_y - 7'd14) &&
				((cherry_x <= plate_x + 8'd6) || (cherry_x >= plate_x - 8'd6)) )
					begin
					caught_cake <= 1'b0; //Nothing caught
					caught_cherry <= 1'b1;
					caught_clr <= 3'b111; 
					end 
				
			end
			
	end

endmodule




module game_record(
	input clk,
	input caught_cake,
	input caught_cherry,
	input [2:0] caught_clr,
	
	output [2:0] clr_record
	
	);
	reg [2:0] addr = 3'd0;
	reg [2:0] addr_ram = 3'd0;
	reg [2:0] record_ram [16:0];
	
	
	
	always @(posedge clk)
	begin 
		if (caught_cake) begin
			record_ram[addr] <= caught_clr;
			addr_ram <= addr;
			addr <= addr + 3'd3;
			end 
	end 
	
	assign clr_record = record_ram[addr_ram];
	
	

endmodule 
