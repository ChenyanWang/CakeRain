
module cake_render(
	input clk,
	input resetn,
	input go_cake,
	input go_shift,
	
	output [7:0] x_cake,
	output [6:0] y_cake,
	output [2:0] colour_cake,
	
	output done_cake
	);
	wire done_rom,ld_init,ld_plot, move;
	wire [7:0] x_start_loc;
	wire [6:0] y_start_loc;
	wire [2:0] colour_sel;
	
	cake_layer_render render0(
		.clk(clk),
		.resetn(resetn),
		.go_cake(go_cake),
		.go_shift( go_shift),
		.done_rom(done_rom),
		
		.x_start_loc(x_start_loc),
		.y_start_loc(y_start_loc),
		.colour_sel(colour_sel), //select the colour of the cake layer 
		
		
		.ld_init(ld_init),
		.ld_plot(ld_plot),
		.move(move),
		.done_cake(done_cake)
		);
	
	draw_cake draw_cake_inst(
		.done_rom(done_rom),
	
		.clk(clk),
		.resetn(resetn),
		.x_start_loc(x_start_loc),
		.y_start_loc(y_start_loc),
		.colour_sel(colour_sel),
		.ld_init(ld_init),
		.ld_plot(ld_plot),
		.move(move),
		
		.x_cake(x_cake),
		.y_cake(y_cake),
		.colour_cake(colour_cake)
	);
	

endmodule 



module cake_layer_render(
	input clk,
	input resetn,
	input go_cake,
	input go_shift,
	input done_rom, // flag = read memory done
	
	output reg ld_init,
	output reg ld_plot,
	output reg move,
	output reg [7:0] x_start_loc,
	output reg [6:0] y_start_loc,
	output reg [2:0] colour_sel,
	output done_cake // flag = plot image done 
	);
	
	wire [7:0] x_rand_loc;
	reg [7:0] address;
	reg [2:0] speed;
	assign done_cake = (done_rom) ? 1'b1 : 1'b0;
	
	reg [2:0] current_state, next_state;
	localparam 		S_IDLE 			= 3'd0,
						S_LOAD_INIT	 	= 3'd1,
						S_PLOT 			= 3'd2,
						S_PLOT_BUFFER 	= 3'd3,
						S_SHIFT			= 3'd4;
						
	
	always @(*)
	begin: state_table
		case (current_state) 
			S_IDLE: 			next_state = (go_cake == 1'b1) ? S_LOAD_INIT : S_IDLE;
			S_LOAD_INIT: 	next_state = S_PLOT;
			S_PLOT: 		 	next_state = (done_rom == 1'b1) ? S_PLOT_BUFFER : S_PLOT;
			S_PLOT_BUFFER:  next_state = (go_shift == 1'b1) ? S_SHIFT : S_PLOT_BUFFER;
			S_SHIFT:   	  	next_state = S_IDLE;
		default: 		 next_state = S_IDLE;
		endcase
	end
	
	always @(*)
	begin: enable_signals
	
			ld_init = 1'b0;
			//ld_rand = 1'b0;
			ld_plot = 1'b0;
			move = 1'b0;
		case (current_state)
			S_LOAD_INIT: begin
				ld_init = 1'b1;
			//	ld_rand = 1'b1;
				end
			S_PLOT: begin
				ld_plot = 1'b1; // to draw_cake module 
				end 
			S_SHIFT: begin
				move = 1'b1;
				end
		endcase
	end 
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			speed <= 3'd0;
			end
		else begin
			if (current_state == S_LOAD_INIT) begin
				speed <= speed + 1'b1;
				end 
			else begin
				speed <= (speed == 3'd7) ? 3'd0 : speed;
				end 
			end 
	end 
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			x_start_loc <= 8'd11;
			y_start_loc <= 7'd0;
			colour_sel <= 3'd0;
			end 
		else begin
			if (current_state == S_LOAD_INIT) begin
				if ((y_start_loc >= 7'd107) || (y_start_loc == 7'd0)) begin
					x_start_loc <= x_rand_loc;
					y_start_loc <= 7'd0;
					colour_sel <= x_rand_loc[2:0];
					end 
				else begin
					x_start_loc <= x_start_loc;
					y_start_loc <= y_start_loc;
					end 
				end 
//			if (current_state == S_LOAD_INIT) begin
//					x_start_loc <= x_start_loc;
//					y_start_loc <= y_start_loc;
//					end 
			else if (current_state == S_SHIFT) begin
				x_start_loc <= x_start_loc;
				y_start_loc <= y_start_loc + 1'b1;
				end 
//			else begin
//				x_start_loc <= x_start_loc;
//				y_start_loc <= y_start_loc;
//				end 
			
		end 
	end 
	
	
	
	// current_state registers
	always @(posedge clk)
	begin: state_FFS
		if (!resetn)
			current_state <= S_IDLE;
		else 
			current_state <= next_state;
	end 
	
	always @(posedge clk)
	begin: read_rand_rom
		if (!resetn) begin
			address <= 8'd68;
			end 
		else begin
			if (address == 8'd144)
				address <= 8'd0;
			else
				address <= address + 1'b1;
		end 
	
	end 
	

	
	rand_num_rom rand_cake(
		.address(address),
		.clk(clk),
		.data(x_rand_loc)
		);

endmodule 


module draw_cake(
	input clk,
	input resetn,
	
	input [7:0] x_start_loc,
	input [6:0] y_start_loc,
	input [2:0] colour_sel,
	input ld_init,
	input ld_plot,
	input move,

	output reg [7:0] x_cake,
	output reg [6:0] y_cake,
	output reg [2:0] colour_cake,
	output done_rom
	);
	

	reg [3:0] hsq_count;
	reg [3:0] vsq_count;
	reg [6:0] counter; 

	wire [2:0] clrOut;
	reg [2:0] rand_clr;
	wire hsq_reset, vsq_reset;

	
	colourMux cake_colour(
		.randNum(rand_clr), 
		.clrOut(clrOut)
		);
	
	//counter
	assign done_rom = (counter == 7'd96) ? 1'b1 : 1'b0;
	localparam BLACK = 3'b000;
	
//	always @(posedge clk)
//	begin
//		if (!resetn)
//			counter <= 7'd0;
//		else begin
//			if (ld_plot)
//				counter <= counter + 1'b1;
//			else if (counter == 7'b1100000)
//				counter <= 7'd0;
//			end 
//	
//	
//	end 
	


	 assign hsq_reset = (hsq_count == 4'b1111); //15
	 assign vsq_reset = (vsq_count == 4'b0101); //5
	 
	 always @(posedge clk) begin
		if (resetn == 1'b0) begin
			hsq_count <= 4'd0;
			vsq_count <= 4'd0;
			counter <= 7'd0;
			end
		else begin
			if (ld_plot == 1'b1) begin
				hsq_count <= hsq_reset ? 1'b0 : (hsq_count + 1'b1);
				vsq_count <= hsq_reset ? (vsq_reset ? 1'b0 : vsq_count + 1'b1) : vsq_count;
				counter <= counter + 1'b1;
				end
			else begin
				hsq_count <= 4'd0;
				vsq_count <= 4'd0;
				counter <= 7'd0;
				end 
			
			end
	end
	
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			x_cake <= 8'd16;
			y_cake <= 7'd0;
			colour_cake <= BLACK;
			end
		else begin
			if (ld_init) begin
				x_cake <= x_start_loc;
				y_cake <= y_start_loc;
				rand_clr <= colour_sel;
				end
			if (ld_plot) begin
				x_cake <= x_start_loc + hsq_count;
				y_cake <= y_start_loc + vsq_count;
				colour_cake <= clrOut;
				end 
			if (move) begin
				 x_cake <= x_start_loc;
				 y_cake <= y_start_loc;
				 colour_cake <= BLACK;
				end
//			else begin
//				x_cake <= x_cake;
//				y_cake <= y_cake;
//				rand_clr <= rand_clr;
//				end 
				
		end 
	end 
			
endmodule 






