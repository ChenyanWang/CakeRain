module game_top(
	input clk, 
	input resetn,
	input game_start,
	
	input left,
	input right,
	
	// to manually end the game
	input caught_cherry,
	
	// for debugging purposes
	output [3:0] hex_sel,
	output [3:0] hex1,
	
	// outputs ports
	output [7:0] x_vga,
	output [6:0] y_vga,
	output [2:0] colour_vga,
	output writeEn
	
	);
	
	
	wire done_recipe, done_buffer, done_erase, done_sidebar;
	wire go_frame;
	wire done_cherry, done_plate;
	wire done_cake1, done_cake2, done_cake3;
	wire done_score, done_over;
	wire ld_game_over, ld_score;
	//wire caught_cherry;
	wire ld_recipe, ld_sidebar;
	wire go_cherry, go_plate;
	wire go_cake1, go_cake2, go_cake3; 
	wire go_save, go_erase, go_shift;
	wire [4:0] pixel_sel;
//	wire [2:0] cake_caught_count;
	
	
	
	wire [7:0] x_cherry, x_erase, x_cake1, x_cake2, x_cake3, x_sidebar, x_plate, x_score, x_game_over;
	wire [6:0] y_cherry, y_erase, y_cake1, y_cake2, y_cake3, y_sidebar, y_plate, y_score, y_game_over;
	wire [2:0] pixel_cherry, pixel_cake1, pixel_cake2, pixel_cake3;
	wire [2:0] pixel_erase, pixel_sidebar, pixel_plate;
	wire [2:0] pixel_score, pixel_game_over;
	
	wire done_score_delay;
	wire [2:0] caught_num;
	wire [17:0] cake_caught;
	wire [17:0] recipe;
	wire [17:0] output_pixels;
	wire loadEn;
	

	assign writeEn = loadEn;
	assign x_vga = output_pixels[17:10];
	assign y_vga = output_pixels[9:3];
	assign colour_vga = output_pixels[2:0];

	
	
	game_server game0(
				
	/* input ports */
		.game_start(game_start),
		.clk(clk), 
		.resetn(resetn),
		.done_erase(done_erase),
		.done_recipe(done_recipe),
		.done_sidebar(done_sidebar),
		.done_plate(done_plate),
	
		.done_cherry(done_cherry), 
		.caught_cherry(caught_cherry),  //caught_cherry
		.done_cake1(done_cake1),
		.done_cake2(done_cake2),
		.done_cake3(done_cake3),
		.done_buffer(done_buffer),
		.done_score(done_score),
		.done_over(done_over),
		.done_score_delay(done_score_delay),
		.caught_num(caught_num),
		
		//output testing port 
//		.hex_sel(hex_sel),
//		.hex1(hex1),

	/* output ports */
		//.ld_menu(ld_menu),
		.ld_recipe(ld_recipe),
		.ld_sidebar(ld_sidebar),
		.go_plate(go_plate),
		.go_cherry(go_cherry),
		.go_cake1(go_cake1),
		.go_cake2(go_cake2),
		.go_cake3(go_cake3),
		.go_erase(go_erase),
		.go_shift(go_shift),
		.ld_score(ld_score),
		.ld_game_over(ld_game_over),
		
		.pixel_sel(pixel_sel),
		.writeEn(loadEn)
		);
		
		
	score_delay_counter delay1(
		.clk(clk), 
		.resetn(resetn),
		.done_score_delay(done_score_delay)
	 );
		
	recipe_render recipe_render0(
		.clk(clk), 
		.resetn(resetn),
		.ld_recipe(ld_recipe),
		
		.done_recipe(done_recipe),
		.recipe(recipe)
		
		);
	plate_render plate_render0(
		.clock(clk), 
		.resetn(resetn),
		.draw_enable(go_plate),
		
		.left(left),
		.right(right),
		.draw_done(done_plate),
		.colour(pixel_plate),
		.x(x_plate),
		.y(y_plate)
		);
	
		
	cherry_render cherry_render0(
		.clk(clk), 
		.resetn(resetn),
		.go_cherry(go_cherry),
		.go_shift(go_shift),
	
	
		.x_cherry(x_cherry),
		.y_cherry(y_cherry),
		.colour_cherry(pixel_cherry),
	
		.done_cherry(done_cherry)
		
	);
	
	cake_render cake1(
		.clk(clk), 
		.resetn(resetn),
		.go_cake(go_cake1),
		.go_shift(go_shift),
		
		
		.x_cake(x_cake1),
		.y_cake(y_cake1),
		.colour_cake(pixel_cake1),
	
		.done_cake(done_cake1)
		
	);
	
	cake_render cake2(
		.clk(clk), 
		.resetn(resetn),
		.go_cake(go_cake2),
		.go_shift(go_shift),
		
		
		.x_cake(x_cake2),
		.y_cake(y_cake2),
		.colour_cake(pixel_cake2),
	
		.done_cake(done_cake2)
		
	);
	
	cake_render cake3(
		.clk(clk), 
		.resetn(resetn),
		.go_cake(go_cake3),
		.go_shift(go_shift),
		
		
		.x_cake(x_cake3),
		.y_cake(y_cake3),
		.colour_cake(pixel_cake3),
	
		.done_cake(done_cake3)
		
	);
	
	
	sidebar sidebar0(
		//input 
		.clock(clk),
		.cake_caught(cake_caught), 
		.recipe(recipe),
		.resetn(resetn), 
		.ld_sidebar(ld_sidebar), 
		.erase_done(done_erase),
		
		//output 
		.draw_done(done_sidebar),
		.colour(pixel_sidebar),
		.x(x_sidebar),
		.y(y_sidebar)
	);
	
		
	output_pixels pixels(
		//.clk(clk),
		//.writeEn(loadEn),
		.x_background(x_erase),
		.y_background(y_erase),
		.colour_background(pixel_erase),
		.x_plate(x_plate),
		.y_plate(y_plate),
		.colour_plate(pixel_plate),
		.colour_sidebar(pixel_sidebar),
		.x_sidebar(x_sidebar),
		.y_sidebar(y_sidebar),
		.x_cherry(x_cherry),
		.y_cherry(y_cherry),
		.colour_cherry(pixel_cherry),
		.x_cake1(x_cake1),
		.y_cake1(y_cake1),
		.x_cake2(x_cake2),
		.y_cake2(y_cake2),
		.x_cake3(x_cake3),
		.y_cake3(y_cake3),
		.x_game_over(x_game_over),
		.y_game_over(y_game_over),
		.colour_game_over(pixel_game_over),
		
		.x_score(x_score),
		.y_score(y_score),
		.colour_score(pixel_score),
		
		.colour_cake1(pixel_cake1),
		.colour_cake2(pixel_cake2),
		.colour_cake3(pixel_cake3),
		
		
		.pixel_sel(pixel_sel),
		
		
		.output_pixels(output_pixels)
		);
	
	erase_screen  erase0(
		.clk(clk),
		.resetn(resetn),
		.go_erase(go_erase),
	
		.x_to_vga(x_erase),
		.y_to_vga(y_erase),
		.colour_to_vga(pixel_erase),
		.done_erase(done_erase)
	);
	
	game_over  game_over0(
		.clk(clk),
		.resetn(resetn),
		.ld_game_over(ld_game_over),
	
		.x_to_vga(x_game_over),
		.y_to_vga(y_game_over),
		.colour_to_vga(pixel_game_over),
		.done_over(done_over)
	);
	
	delay_counter delay0(
		.clk(clk),
		.resetn(resetn),
		.frequency(20'd833334), // 20'd833334
		.go_frame(go_frame)
		);
		
	frame_counter frame(
		.clk(clk),
		.resetn(resetn),
		.go_frame(go_frame),
		.done_buffer(done_buffer)
		);
		
	
	
	////////						//////////
	////////check_catch //////////
	////////						//////////
	
	catch_to_sidebar catch0(
		.clock(clk), 
		.resetn(resetn),
		.cake1_x(x_cake1), 
		.cake2_x(x_cake2), 
		.cake3_x(x_cake3), 
		.cherry_x(x_cherry), 
		.plate_x(x_plate),
		.cake1_y(y_plate), 
		.cake2_y(y_cake2), 
		.cake3_y(y_cake3), 
		.cherry_y(y_cherry), 
		.plate_y(y_plate),
								
		.cake1_clr(pixel_cake1), 
		.cake2_clr(pixel_cake2), 
		.cake3_clr(pixel_cake3), 
		.cherry_clr(pixel_cherry),
		.cake_out(cake_caught),
		.caught_num(caught_num)
		);
		
		
		 score	score0(
			.clk(clk), 
			.resetn(resetn),
			.ld_score(ld_score),
			.recipe(recipe),
			.caught_cake(cake_caught),

			.x_to_vga(x_score),
			.y_to_vga(y_score),
			.colour_to_vga(pixel_score),
			.done_score(done_score)
			);
	
endmodule 





module game_server(
	///// 			/////
	////input ports/////
	input game_start,
	input clk, 
	input resetn,
	
	input done_recipe,
	input done_sidebar,
	input done_cherry,

	input caught_cherry,
	input done_cake1,
	input done_cake2,
	input done_cake3,


	input done_buffer,
	input done_score_delay,

	input done_erase,
	input done_score,
	input done_over,
	input [2:0] caught_num,
	input done_plate,
	
	///testing output ports 
	output reg [3:0] hex_sel,
	output [3:0] hex1,
	///
	
	
	
	//////				//////
	//// output ports //////
	
	output reg ld_recipe,
	output reg ld_sidebar,
	output reg go_plate,
	output reg go_cherry,
	output reg go_cake1,
	output reg go_cake2,
	output reg go_cake3,

	output reg go_erase,
	output reg go_shift,
	output reg ld_score,
	output reg ld_game_over,
	
	
	output reg [4:0] pixel_sel,
	output reg writeEn
	
	);
	
	//reg [14:0] bkgnd_counter;
	reg [5:0] current_state, next_state;
	localparam 		S_MENU 				= 6'd0,
						S_MENU_WAIT			= 6'd1,
						S_LOAD_RECIPE		= 6'd2,
						S_ERASE		 		= 6'd3,
						S_LOAD_SIDEBAR		= 6'd4,
						S_DRAW_IDLE0		= 6'd5,
						S_DRAW_PLATE		= 6'd6,
						S_DRAW_IDLE1		= 6'd7,
						S_DRAW_CHERRY     = 6'd8,
						S_CHECK_CHERRY		= 6'd9,
						S_DRAW_CAKE1		= 6'd10,
						S_DRAW_IDLE2		= 6'd11,
						S_DRAW_CAKE2		= 6'd12,
						S_DRAW_IDLE3		= 6'd13,
						S_DRAW_CAKE3 		= 6'd14,
						S_DRAW_IDLE4		= 6'd15,
						S_FRAME_BUFFER		= 6'd16,
						S_SHIFT				= 6'd17,
						S_LOAD_SCORE		= 6'd18,
						S_DRAW_IDLE5      = 6'd19,
						S_GAME_OVER			= 6'd20;
						
						
						
	always @(*)
	begin : state_table
		case (current_state)
			S_MENU: 				next_state = (game_start == 1'b1) ? S_MENU_WAIT : S_MENU;
			S_MENU_WAIT: 		next_state = (game_start == 1'b1) ? S_MENU_WAIT : S_LOAD_RECIPE;
			S_LOAD_RECIPE:    next_state = (done_recipe == 1'b1) ? S_ERASE : S_LOAD_RECIPE;
			S_ERASE:				next_state = (done_erase == 1'b1) ? S_LOAD_SIDEBAR : S_ERASE;
			S_LOAD_SIDEBAR:	next_state = (done_sidebar == 1'b1) ? S_DRAW_IDLE0 : S_LOAD_SIDEBAR;
			S_DRAW_IDLE0:		next_state = S_DRAW_PLATE;
			S_DRAW_PLATE: 		next_state = (done_plate == 1'b1) ? S_DRAW_IDLE1 : S_DRAW_PLATE;
			S_DRAW_IDLE1:		next_state = S_DRAW_CHERRY;
			S_DRAW_CHERRY: 	next_state = (done_cherry == 1'b1) ? S_CHECK_CHERRY : S_DRAW_CHERRY; 
			S_CHECK_CHERRY:	next_state = (caught_cherry == 1'b1) ? S_LOAD_SCORE : S_DRAW_CAKE1;
			S_DRAW_CAKE1:		next_state = (done_cake1 == 1'b1) ? S_DRAW_IDLE2 : S_DRAW_CAKE1;
			S_DRAW_IDLE2: 		next_state = S_DRAW_CAKE2;
			S_DRAW_CAKE2:		next_state = (done_cake2 == 1'b1) ? S_DRAW_IDLE3 : S_DRAW_CAKE2;
			S_DRAW_IDLE3: 		next_state = S_DRAW_CAKE3;
			S_DRAW_CAKE3:		next_state = (done_cake3 == 1'b1) ? S_DRAW_IDLE4 : S_DRAW_CAKE3;
			S_DRAW_IDLE4:		next_state = S_FRAME_BUFFER;
			S_FRAME_BUFFER:	next_state = (done_buffer == 1'b1) ? S_SHIFT : S_FRAME_BUFFER;
			S_SHIFT:				next_state = (caught_num == 3'd5) ? S_LOAD_SCORE : S_ERASE;
			S_LOAD_SCORE: 		next_state = (done_score == 1'b1) ? S_DRAW_IDLE5 : S_LOAD_SCORE;
			S_DRAW_IDLE5:     next_state = (done_score_delay == 1'b1) ? S_GAME_OVER : S_DRAW_IDLE5;
			S_GAME_OVER:      next_state = (done_over == 1'b1) ? S_MENU : S_GAME_OVER;
		default: 	next_state = S_MENU;
		endcase 
	end 
	
	always @(*)
	begin: output_logics
			
			hex_sel = 4'h0;
			ld_recipe = 1'b0;
			ld_sidebar = 1'b0;
			go_plate = 1'b0;
			go_cherry = 1'b0;
			go_cake1 = 1'b0;
			go_cake2 = 1'b0;
			go_cake3 = 1'b0;
			go_erase = 1'b0;
			go_shift = 1'b0;
			ld_score = 1'b0;
			ld_game_over = 1'b0;
			pixel_sel = 5'd0;
			writeEn = 1'b0;
		case (current_state) 
			S_LOAD_RECIPE: begin
				ld_recipe = 1'b1;
				hex_sel = 4'h1;
				end 
			S_ERASE: begin
				go_erase = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd0;
				hex_sel = 4'h2;
				end 
			S_LOAD_SIDEBAR: begin
				ld_sidebar = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd1;
				hex_sel = 4'h3;
				end 
			S_DRAW_PLATE: begin
				go_plate = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd2;
				hex_sel = 4'h4;
				end 
			S_DRAW_CHERRY: begin
				go_cherry = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd3;
				hex_sel = 4'h5;
				end 
			S_DRAW_CAKE1: begin
				go_cake1 = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd4;
				hex_sel = 4'h6;
				end 
			S_DRAW_CAKE2: begin
				go_cake2 = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd5;
				hex_sel = 4'h7;
				end 
			S_DRAW_CAKE3: begin
				go_cake3 = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd6;
				hex_sel = 4'h8;
				end 
			S_SHIFT: begin
				go_shift = 1'b1;
				hex_sel = 4'h9;
				end 
			S_LOAD_SCORE: begin
				ld_score = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd7;
				hex_sel = 4'hA;
				end 
			S_GAME_OVER: begin
				ld_game_over = 1'b1;
				writeEn = 1'b1;
				pixel_sel = 5'd8;
				hex_sel = 4'hB;
				end 
		endcase 
	end 

	
	
	always @(posedge clk)
	begin: state_FFS
		if (!resetn) begin
			current_state <= S_MENU;
			end 
		else 
			current_state <= next_state;
	end 
	
	

	
endmodule 








module frame_counter(
	input clk, go_frame, resetn, 
	output done_buffer);
	
	reg [3:0] counter;
	
	always @(posedge clk)
	begin
		if (!resetn) 
			counter <= 4'b0;
		else begin
			if (go_frame == 1'b1)
				counter <= counter + 1'b1;
			else begin
				if (counter == 4'b1111) //4'b1111
					counter <= 4'b0;
				 else 
				   counter <= counter;
				end
		end
	
	end 
	assign done_buffer = (counter == 4'b1111) ? 1'b1 : 1'b0; //4'b1111
	

endmodule 



module delay_counter(
	input clk, resetn, 
	input [19:0] frequency,
	output go_frame);
	
	reg [19:0] counter;
	always @(posedge clk)
	begin
		if (!resetn) 
			counter <= frequency;
		else begin
			if (counter == 20'd0)
			counter <= frequency;
			else
			counter <= counter - 1'b1;
			end 
	end
	
	assign go_frame = (counter == 20'd0) ? 1'b1 : 1'b0;
	
endmodule 

module score_delay_counter(
	input clk, resetn, 
	//input [:0] frequency,
	output done_score_delay);
	
	reg [24:0] counter;
	always @(posedge clk)
	begin
		if (!resetn) 
			counter <= 25'd24999_999;
		else begin
			if (counter == 25'd0)
			counter <= 25'd24_999_999;
			else
			counter <= counter - 1'b1;
			end 
	end
	
	assign done_score_delay = (counter == 25'd0) ? 1'b1 : 1'b0;
	
endmodule 
//

