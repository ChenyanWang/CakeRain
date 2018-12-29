module sidebar (clock, resetn, ld_sidebar, erase_done, draw_done, cake_caught, recipe, x, y, colour
	
	);
	
//For testing
//	reg [17:0] cake_caught = 18'b111_001_010_011_100_101;
//	reg [17:0] recipe = 18'b111_010_111_011_100_101;

	input clock;
	input [17:0] cake_caught, recipe;
	input resetn, ld_sidebar, erase_done;
	output draw_done;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	output [2:0] colour;
	output [7:0] x;
	output [6:0] y;
	//wire writeEn;
	wire w_state_draw_done, w_ccen, w_rcen, w_pcen;
    


	sidebar_control C0(
	//Input
		.clock(clock),
		.resetn(resetn),
		.ld_sidebar(ld_sidebar),
		.erase_done(erase_done),
		.state_draw_done(w_state_draw_done),
		.cake_caught(cake_caught),
	//Output
		.ccount_enable(w_ccen),
		.rcount_enable(w_rcen),
		//.plot(writeEn),
		.sidebar_draw_done(draw_done)
	);
	
	sidebar_data D0(
	//Input
		.clock(clock),
		.resetn(resetn),
		.ccount_enable(w_ccen),
		.rcount_enable(w_rcen),
		//.pcount_enable(w_pcen),
		.cake_caught(cake_caught),
		.recipe(recipe),
	//Output
		.x_out(x),
		.y_out(y),
		.colour_out(colour),
		.state_draw_done(w_state_draw_done)
	);
		

endmodule

module sidebar_control (
	input clock, resetn, ld_sidebar, erase_done,
	input state_draw_done, //cake/cherry, recipe & plate
	input [17:0] cake_caught,
	output reg ccount_enable, rcount_enable,
   output reg sidebar_draw_done//plot 
   );

	reg [3:0] current_state, next_state;
    
	localparam  	S0_DRAW_REP			= 4'd0,
						S2_DRAW_CAKE1 		= 4'd2,
						S3_DRAW_CAKE2		= 4'd3,
						S4_DRAW_CAKE3		= 4'd4,
						S5_DRAW_CAKE4		= 4'd5,
						S6_DRAW_CAKE5		= 4'd6,
						S7_DRAW_CHERRY		= 4'd7,
						S8_ERASE_WAIT     = 4'd8;

    wire caught_cake1, caught_cake2, caught_cake3, caught_cake4, caught_cake5, caught_cake6;
	 wire is_cherry1, is_cherry2, is_cherry3, is_cherry4, is_cherry5; // is_cherry6;
	 
	caught_cake_mod cc1(.colour(cake_caught[2:0]), .caught_cake(caught_cake1));
	is_cherry_mod ic1(.colour(cake_caught[2:0]), .is_cherry(is_cherry1));
	caught_cake_mod cc2(.colour(cake_caught[5:3]), .caught_cake(caught_cake2));
	is_cherry_mod ic2(.colour(cake_caught[5:3]), .is_cherry(is_cherry2));
	caught_cake_mod cc3(.colour(cake_caught[8:6]), .caught_cake(caught_cake3));
	is_cherry_mod ic3(.colour(cake_caught[8:6]), .is_cherry(is_cherry3));
	caught_cake_mod cc4(.colour(cake_caught[11:9]), .caught_cake(caught_cake4));
	is_cherry_mod ic4(.colour(cake_caught[11:9]), .is_cherry(is_cherry4));
	caught_cake_mod cc5(.colour(cake_caught[14:12]), .caught_cake(caught_cake5));
	is_cherry_mod ic5(.colour(cake_caught[14:12]), .is_cherry(is_cherry5));
	caught_cake_mod cc6(.colour(cake_caught[17:15]), .caught_cake(caught_cake6));
	
	// Next state logic aka our state table
	always@(*)
	begin: state_table 
		case (current_state)

			//S0_LOAD: next_state = ld_enable ?  S1_DRAW_REP_PLATE: S0_LOAD;
			S0_DRAW_REP: next_state = state_draw_done ? S2_DRAW_CAKE1 : S0_DRAW_REP;
			S2_DRAW_CAKE1:
				begin
					if (state_draw_done)
					begin
						if (~caught_cake2)
							next_state = S8_ERASE_WAIT;
						else
						//Cake caught
							next_state = S3_DRAW_CAKE2;
					end
					else
					//Not done drawing cake
						next_state = S2_DRAW_CAKE1;
				end
			S3_DRAW_CAKE2:
				begin
					if (state_draw_done)
					begin
						if (~caught_cake3)
							next_state = S8_ERASE_WAIT;
						else
						//Cake caught
							next_state = S4_DRAW_CAKE3;
					end
					else
					// Not done drawing cake
						next_state = S3_DRAW_CAKE2;
				end
			S4_DRAW_CAKE3:
				begin
					if (state_draw_done)
					begin
						if (~caught_cake4)
							next_state = S8_ERASE_WAIT;
						else
						//Cake caught
							next_state = S5_DRAW_CAKE4;
					end
					else
					// Not done drawing cake
						next_state = S4_DRAW_CAKE3;
				end
			S5_DRAW_CAKE4:
				begin
					if (state_draw_done)
					begin
						if (~caught_cake5)
							next_state = S8_ERASE_WAIT;
						else
						//Cake caught
							next_state = S6_DRAW_CAKE5;
					end
					else
					// Not done drawing cake
						next_state = S5_DRAW_CAKE4;
				end
			S6_DRAW_CAKE5:
				begin
					if (state_draw_done)
					begin
						if (~caught_cake6)
							next_state = S8_ERASE_WAIT;
						else
						//Cake caught
							next_state = S7_DRAW_CHERRY;
					end
					else
					// Not done drawing cake
						next_state = S6_DRAW_CAKE5;
				end
			S7_DRAW_CHERRY: next_state = state_draw_done ? S8_ERASE_WAIT : S7_DRAW_CHERRY;
			S8_ERASE_WAIT: next_state = erase_done ? S0_DRAW_REP : S8_ERASE_WAIT;
			default: next_state = S8_ERASE_WAIT; //S0_LOAD;
		endcase
	end // state_table
   

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
      // Default 0 to avoid latches:
		ccount_enable = 1'b0;
		rcount_enable = 1'b0;
		sidebar_draw_done = 1'b0;
		//plot = 1'b0;


        case (current_state)
				S0_DRAW_REP:
					begin
						if (ld_sidebar)
							begin
								rcount_enable = 1'b1;
							//	plot = 1'b1;
							end
					end
            S2_DRAW_CAKE1:
					begin
						ccount_enable = 1'b1;
					//	plot = 1'b1;
					end
				S3_DRAW_CAKE2:
					begin
						ccount_enable = 1'b1;
						//plot = 1'b1;
					end
				S4_DRAW_CAKE3:
					begin
						ccount_enable = 1'b1;
					//	plot = 1'b1;
					end
				S5_DRAW_CAKE4:
					begin
						ccount_enable = 1'b1;
						//plot = 1'b1;
					end
				S6_DRAW_CAKE5:
					begin
						ccount_enable = 1'b1;
						//plot = 1'b1;
					end
				S7_DRAW_CHERRY:
					begin
						ccount_enable = 1'b1;
						//plot = 1'b1;
					end
				S8_ERASE_WAIT:
					begin
						sidebar_draw_done = 1'b1;
					end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= S8_ERASE_WAIT;
        else
            current_state <= next_state;
    end // state_FFS
endmodule


module sidebar_data (
	input clock, resetn,
	input ccount_enable, rcount_enable,
	input [17:0] cake_caught, recipe,
	output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] colour_out,
	output reg state_draw_done
	);
	

	// input registers
	reg [7:0] x_reg;
	reg [6:0] y_reg;
	reg [17:0] caught_cake;
	reg [6:0] ccounter; //[5:0] //Cake/cherry 4x12
	reg [2:0] ccounter_x; //[1:0]
	reg [3:0] ccounter_y;
	reg [6:0] rcounter; //Recipe 6x13 (including cherry and plate)
	reg [2:0] rcounter_x;
	reg [3:0] rcounter_y;
	
	// output registers
	reg ccount_done, rcount_done;//, pcount_done;

 // Registers x, y, colour, ccount, rcount with respective input logic
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			x_reg <= 8'b0;
			y_reg <= 7'b0;
			ccounter = 7'b0;//Cake/cherry 4x12
			ccounter_x <= 3'b0;
			ccounter_y <= 4'b0;
			rcounter <= 7'b0; //Recipe 6x13 (including cherry and plate)
			rcounter_x <= 3'b0;
			rcounter_y <= 4'b0;
		end
		else
		begin
			if (ccount_enable)
			begin
			//draw cake caught
				x_reg <= 8'd2;//8'd3
				y_reg <= 7'd40;
				ccounter <= ccounter + 6'b1;
				ccounter_x <= ccounter[2:0];
				ccounter_y <= ccounter[6:3];
			end
			
			else if (rcount_enable)
			begin
			//draw recipe
				x_reg <= 8'd2;
				y_reg <= 7'd10;
				rcounter <= rcounter + 6'b1;
				rcounter_x <= rcounter[2:0];
				rcounter_y <= rcounter[6:3];
			end
		end
	end
	
	
	// Drawing portion
	always@(*)
	begin
		//X/Y Coordinate
		if (ccount_enable)
		begin
			x_out <= x_reg + ccounter_x;
			y_out <= y_reg + ccounter_y;
		end
		
		else if (rcount_enable)
		begin
			x_out <= x_reg + rcounter_x;
			y_out <= y_reg + rcounter_y;
		end
		
		else
		begin
			x_out <= 8'b0;
			y_out <= 7'b0;
		end
		
		//Colour = black if not in range
		if (ccount_enable)
		begin
		//cake caught
			if ((ccounter_y == 4'd0) || (ccounter_y == 4'd1))
			begin
			//Cherry
				if (cake_caught[17:15] == 3'b111)//Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else//Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[17:15];
					else
						colour_out = 3'b0;
				end
				
			end
			
			//Cake5
			else if ((ccounter_y == 4'd2) || (ccounter_y == 4'd3))
			begin
				if (cake_caught[14:12] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[14:12];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake4
			else if ((ccounter_y == 4'd4) || (ccounter_y == 4'd5))
			begin
				if (cake_caught[11:9] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[11:9];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake3
			else if ((ccounter_y == 4'd6) || (ccounter_y == 4'd7))
			begin
				if (cake_caught[8:6] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[8:6];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake2
			else if ((ccounter_y == 4'd8) || (ccounter_y == 4'd9))
			begin
				if (cake_caught[5:3] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[5:3];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake1
			else if ((ccounter_y == 4'd10) || (ccounter_y == 4'd11))
			begin
				if (cake_caught[2:0] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((ccounter_x >= 3'd1) && (ccounter_x <= 3'd4))
						colour_out = cake_caught[2:0];
					else
						colour_out = 3'b0;
				end
			end
			
			//Plate
			else if (ccounter_y == 4'd12)
			begin
				if ((ccounter_x >= 3'd0) && (ccounter_x <= 3'd5))
					colour_out = 3'b111;
				else
					colour_out = 3'b0;
			end
			
			//Not part of cake
			else
				colour_out = 3'b0;
		end
		
		else if (rcount_enable)
		begin
		//recipe
			if ((rcounter_y == 4'd0) || (rcounter_y == 4'd1))
			begin
			//Cherry
				if (recipe[17:15] == 3'b111)//Is cherry
				begin
					if((rcounter_x == 2'd2) || (rcounter_x == 2'd3))
						colour_out = 3'b100;//Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[17:15];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake5
			else if ((rcounter_y == 4'd2) || (rcounter_y == 4'd3))
			begin
				if (recipe[14:12] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[14:12];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake4
			else if ((rcounter_y == 4'd4) || (rcounter_y == 4'd5))
			begin
				if (recipe[11:9] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[11:9];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake3
			else if ((rcounter_y == 4'd6) || (rcounter_y == 4'd7))
			begin
				if (recipe[8:6] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[8:6];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake2
			else if ((rcounter_y == 4'd8) || (rcounter_y == 4'd9))
			begin
				if (recipe[5:3] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[5:3];
					else
						colour_out = 3'b0;
				end
			end
			
			//Cake1
			else if ((rcounter_y == 4'd10) || (rcounter_y == 4'd11))
			begin
				if (recipe[2:0] == 3'b111) //Is cherry
				begin
					if((ccounter_x == 2'd2) || (ccounter_x == 2'd3))
						colour_out = 3'b100; //Red
					else
						colour_out = 3'b0;
				end
				else //Is not cherry
				begin
					if ((rcounter_x >= 3'd1) && (rcounter_x <= 3'd4))
						colour_out = recipe[2:0];
					else
						colour_out = 3'b0;
				end
			end
			
			//Plate
			else if (rcounter_y == 4'd12)
			begin
				if ((rcounter_x >= 3'd0) && (rcounter_x <= 3'd5))
					colour_out = 3'b111;
				else
					colour_out = 3'b0;
			end
			
			//Not part of cake
			else
				colour_out = 3'b0;
		end
		
		//Not outputting
		else
		begin
			colour_out = 3'b0;
		end

		ccount_done = ((ccounter_x == 3'd5) && (ccounter_y == 4'd12));
		rcount_done = ((rcounter_x == 3'd5) && (rcounter_y == 4'd12));
		
		state_draw_done = ccount_done || rcount_done;
	end
	
	
endmodule



/*	
	// x: 6 pix, y: 12 pix
	// xcake_count: 0 to 5
	// ycake_count: 0 to 11
	// draw_count for cake + cherry portion
	// plate_count for plate 10 by 1
	// x_plate: 0 to 9
	
	
	// y: 11:10	cake_caught[17:15]
	// y: 9:8	cake_caught[14:12]
	// y: 7:6	cake_caught[11:9]
	// y: 5:4	cake_caught[8:6]
	// y: 3:2	cake_caught[5:3]
	// y: 1:0	cake_caught[2:0]
	
*/


// Helper module to determine if there is cake on layer
module caught_cake_mod (input [2:0] colour, output caught_cake);
	assign caught_cake = (colour != 3'b000);
endmodule

// Helper module to determine if layer is cherry
module is_cherry_mod (input [2:0] colour, output is_cherry);
	assign is_cherry = (colour == 3'b111);
endmodule
