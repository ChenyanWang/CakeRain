module game_over(
	input clk,
	input resetn,
	input ld_game_over,
	
	output reg [7:0] x_to_vga,
	output reg [6:0] y_to_vga,
	output reg [2:0] colour_to_vga,
	output done_over
	);
	
	localparam BLACK = 3'b000;
	reg [7:0] x_count;
	reg [6:0] y_count;
	reg [14:0] erase_counter;
	wire [15:0] address;
	wire h_reset, v_reset;
	wire [2:0] colour_bkgnd;
	
	assign address = 160*y_count + x_count;
	game_over_rom game_over0(
		.address(address),
		.clock(clk),
		.q(colour_bkgnd)
		);
	
	
	//assign done_erase = ((y_count == 7'd119) && (x_count == 8'd159)) ? 1'b1 : 1'b0; 
	assign done_over = (erase_counter == 15'd19200) ? 1'b1 : 1'b0; 
	
	always @(posedge clk) begin
        if(!resetn) begin
            x_to_vga <= 8'b0; 
				y_to_vga <= 7'b0;
				colour_to_vga <= BLACK;
        end
        else begin
            if(ld_game_over == 1'b1) begin
				x_to_vga <= x_count;
				y_to_vga <= y_count;
            colour_to_vga <= colour_bkgnd;
				end
			end
    end
	 
	 assign h_reset = (x_count == 8'd159);
	 assign v_reset = (y_count == 7'd119);
	
	always @(posedge clk) begin
		if (!resetn) begin
			x_count <= 8'd0; 
			y_count <= 7'd0;
			erase_counter <= 15'd0;
			end
		else begin
			if (ld_game_over == 1'b1) begin
				x_count <= h_reset ? 1'b0 : (x_count + 1'b1);
				y_count <= h_reset ? (v_reset ? 1'b0 : y_count + 1'b1) : y_count;
				erase_counter <= erase_counter + 1'b1;
				end
			else begin
				x_count <= 8'd0;
				y_count <= 7'd0;
				erase_counter <= 15'd0;
				end 
			
			end
	end

endmodule 