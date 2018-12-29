module cherry_render(
	input clk,
	input resetn,
	input go_cherry,
	input go_shift,

	output [7:0] x_cherry,
	output [6:0] y_cherry,
	output [2:0] colour_cherry,
	
	output done_cherry
	);
	wire done_rom;
	wire ld_init,ld_plot, move;
	wire [7:0] x_start_loc;
	wire [6:0] y_start_loc;
	
	
	cherry_control che_control(
		.clk(clk),
		.resetn(resetn),
		.go_cherry(go_cherry),
		.go_shift(go_shift),
		.done_rom(done_rom),
		
		
		.x_start_loc(x_start_loc),
		.y_start_loc(y_start_loc),
		
		.ld_init(ld_init),
		.ld_plot(ld_plot),
		.move(move),
		.done_cherry(done_cherry)
		);
	
	draw_cherry cherry_inst(
		.done_rom(done_rom),
	
		.clk(clk),
		.resetn(resetn),
		
		.x_start_loc(x_start_loc),
		.y_start_loc(y_start_loc),
		.ld_init(ld_init),
		.ld_plot(ld_plot),
		.move(move),
		
		.x_cherry(x_cherry),
		.y_cherry(y_cherry),
		.colour_cherry(colour_cherry)
	);
	

endmodule 

module cherry_control(
	input clk,
	input resetn,
	input go_cherry,
	input go_shift,
	input done_rom, // flag = read memory done

	output reg ld_init,
	output reg ld_plot,
	output reg move,
	output reg [7:0] x_start_loc,
	output reg [6:0] y_start_loc,
	output done_cherry // flag = plot image done 
	
	);
	
	wire [7:0] x_rand_loc;
	reg [7:0] address;
	reg [2:0] speed;
	//reg ld_rand = 0;

	
	assign done_cherry = (done_rom) ? 1'b1 : 1'b0;

	
	
	reg [2:0] current_state, next_state;
	localparam 		S_IDLE 			= 3'd0,
						S_LOAD_INIT	 	= 3'd1,
						S_PLOT 			= 3'd2,
						S_PLOT_BUFFER 	= 3'd3,
						S_ERASE_WAIT 	= 3'd4,
						S_SHIFT			= 3'd5;
						
	
	always @(*)
	begin: state_table
		case (current_state) 
			S_IDLE: 			next_state = (go_cherry == 1'b1) ? S_LOAD_INIT : S_IDLE;
			S_LOAD_INIT: 	next_state = S_PLOT;
			S_PLOT: 		 	next_state = (done_rom == 1'b1) ? S_PLOT_BUFFER : S_PLOT;
			S_PLOT_BUFFER:  next_state = S_ERASE_WAIT;
			S_ERASE_WAIT: 	next_state = (go_shift == 1'b1) ? S_SHIFT : S_ERASE_WAIT;
			S_SHIFT:   	  	next_state = S_IDLE;
		default: 		 next_state = S_IDLE;
		endcase
	end
	
	always @(posedge clk)
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
				ld_plot = 1'b1; // to draw_cherry module 
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
			x_start_loc <= 8'd116;
			y_start_loc <= 7'd0;
			end 
		else begin
			if (current_state == S_LOAD_INIT) begin
				if ((y_start_loc >= 7'd99) || (y_start_loc == 7'd0)) begin
					x_start_loc <= x_rand_loc;
					y_start_loc <= 7'd0;
					end 
				else begin
					x_start_loc <= x_start_loc;
					y_start_loc <= y_start_loc;
					end 
				end 
			else if (current_state == S_SHIFT) begin
				x_start_loc <= x_start_loc;
				y_start_loc <= y_start_loc + {4'b0, speed};
				end 
//			else begin
//				end 
		end 
	end 

	// current_state registers
	always @(posedge clk)
	begin: state_FFS
		if (!resetn) begin
			current_state <= S_IDLE;
			end 
		else 
			current_state <= next_state;
	end 
	
	
	
	always @(posedge clk)
	begin: read_rand_rom
		if (!resetn) begin
			address <= 8'd0;
			end 
		else begin
			if (address == 8'd144)
				address <= 8'd0;
			else
				address <= address + 1'b1;
		end 
	
	end 
	
	
	
	
	rand_num_rom rand_cherry(
		.address(address),
		.clk(clk),
		.data(x_rand_loc)
		);
		
	

endmodule 


module draw_cherry(
	input clk,
	input resetn,
	
	input [7:0] x_start_loc,
	input [6:0] y_start_loc,
	
	input ld_init,
	input ld_plot,
	input move,

	output reg [7:0] x_cherry,
	output reg [6:0] y_cherry,
	output reg [2:0] colour_cherry,
	output done_rom
	);
	
	wire [7:0] address;
	reg [7:0] addr_count;
	reg [3:0] x_addr;
	reg [3:0] y_addr;
	wire [2:0] qout_cherry;
	
	reg [7:0] x_count;
	reg [6:0] y_count;
	
	reg [7:0] counter;
	
	
	assign done_rom = (addr_count == 8'd167) ? 1'b1 : 1'b0;
	assign address = 12*y_addr + x_addr;
	
	cherry_rom cherry(
		.address(address),
		.clock(clk),
		.q(qout_cherry)
		);
		
	always @(posedge clk)
	begin 
		if (!resetn) begin
			x_addr <= 4'd0;
			y_addr <= 4'd0;
			x_count <= 8'd0;
			y_count <= 7'd0;
			addr_count <= 8'd0;
		//	counter <= 8'd0;
			end 
		else begin
			if (ld_plot) begin 
				addr_count <= address;
				if (x_addr == 4'b1100) begin // when x = 12 (width)
					x_count <= 8'd0;
					x_addr <= 4'd0;
					y_count <= (y_addr==4'b1110) ? 7'd0 : (y_count + 1'b1);
					y_addr <= (y_addr==4'b1110) ? 4'd0 : (y_addr + 1'b1);
					end 
				else begin
					x_count <= x_count + 1'b1;
					x_addr  <= x_addr + 1'b1;
					y_count <= y_count;
					y_addr <= y_addr;
					//done_rom <= (y_addr == 4'b1110) ? 1'b1 : 1'b0;
					end 
				end 
			else begin
				x_addr <= 4'd0;
				y_addr <= 4'd0;
				x_count <= 8'd0;
				y_count <= 7'd0;
				counter <= 8'd0;
				addr_count <= 8'd0;
				end 
				
		end 
	end 
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			x_cherry <= 8'd116;
			y_cherry <= 7'd0;
			end
		else begin
			if (ld_init) begin
				x_cherry <= x_start_loc;
				y_cherry <= y_start_loc;
				colour_cherry <= 3'b000; //black
				end 
			if (ld_plot) begin
				x_cherry <= x_start_loc + x_count;
				y_cherry <= y_start_loc + y_count;
				colour_cherry <= qout_cherry;
				end 
			if (move) begin
				 x_cherry <= x_start_loc;
				 y_cherry <= y_start_loc;
				end
				
		end 
	end 
			
endmodule 







