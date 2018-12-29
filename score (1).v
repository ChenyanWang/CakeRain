///*
//Possible scores:
//Perfect	2'b11:
//	• 5/5 Order
//Great		2'b10:
//	• 4/5 Order
//Good		2'b01:
//	• 3/5 Order
//Soso		2'b00:
//	• 0/5 Order
//*/

module score(
	input clk,
	input resetn,
	input ld_score,
	input [17:0] recipe,
	input [17:0] caught_cake,
//	input result_done,
//	input [1:0] score_result,
	
	output reg [7:0] x_to_vga,
	output reg [6:0] y_to_vga,
	output reg [2:0] colour_to_vga,
	output done_score
	);
	
	localparam BLACK = 3'b000;
	reg [7:0] x_count;
	reg [6:0] y_count;
	reg [14:0] erase_counter;
	wire [15:0] address;
	wire h_reset, v_reset;
	wire [2:0] clr_perfecto, clr_soso, clr_good, clr_great;
	reg [2:0] clr_bkgnd;
	wire w_result_done;
	wire [1:0] w_score_result;
	
	assign done_score = (erase_counter == 15'd19200) ? 1'b1 : 1'b0; 
	assign address = (w_result_done) ? (160*y_count + x_count) : 16'd0;

	score_result result0(
		.clock(clk), 
		.resetn(resetn), 
		.score_enable(ld_score),
		.recipe(recipe), 
		.caught_cake(caught_cake),
		.result_done(w_result_done),
		.score_result(w_score_result)
	
	);
	
	
	perfecto_rom perfecto(
		.address(address),
		.clock(clk),
		.q(clr_perfecto)
		);
	
	
	great_rom great(
		.address(address),
		.clock(clk),
		.q(clr_great)
		);
		
	good_rom good(
		.address(address),
		.clock(clk),
		.q(clr_good)
		);
		
	soso_rom soso(
		.address(address),
		.clock(clk),
		.q(clr_soso)
		);
	
	
		
		
	always @(*)
	begin
		case (w_score_result)
			2'b00: clr_bkgnd = clr_soso;
			2'b01: clr_bkgnd = clr_good;
			2'b10: clr_bkgnd = clr_great;
			2'b11: clr_bkgnd = clr_perfecto;
		endcase
	end 
	
	
	//assign done_erase = ((y_count == 7'd119) && (x_count == 8'd159)) ? 1'b1 : 1'b0; 

	always @(posedge clk) begin
        if(!resetn) begin
            x_to_vga <= 8'b0; 
				y_to_vga <= 7'b0;
				colour_to_vga <= BLACK;
        end
        else begin
            if(w_result_done == 1'b1) begin
				x_to_vga <= x_count;
				y_to_vga <= y_count;
            colour_to_vga <= clr_bkgnd;
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
			if (w_result_done == 1'b1) begin
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




/*
Non-Consecutive Order
Possible scores:
Perfect	2'b11:
	• 5/5 Order
Great		2'b10:
	• 4/5 Order
Good		2'b01:
	• 3/5 Order
Soso		2'b00:
	• 0/5 Order
*/


module score_result (clock, resetn, score_enable, recipe, caught_cake, //Inputs
					result_done, score_result);//Outputs
	input clock, resetn, score_enable;
	input [17:0] recipe, caught_cake;
	output reg result_done;
	output reg [1:0] score_result;

	wire w_orderdone;
	wire [2:0] w_orderscore;
	
	always @(*)
	begin
		if (!resetn)
		begin
			result_done= 1'b0;
			score_result = 2'b0;
		end
		else
		begin
			if (w_orderdone)
			begin
				if (w_orderscore == 3'd5)
				begin
					score_result = 2'b11;
					result_done = 1'b1;
				end
				else if (w_orderscore >= 3'd4)
				begin
					score_result = 2'b10;
					result_done = 1'b1;
				end
				else if (w_orderscore >= 3'd3)
				begin
					score_result = 2'b01;
					result_done = 1'b1;
				end
				else
				begin
					score_result <= 2'b00;
					result_done <= 1'b1;
				end
			end
			else
			begin
				score_result = 2'b00;
			//	result_done = 1'b0;
			end
		end
	end	
	
	order_calculation o0(
		//Inputs
		.clock(clock),
		.resetn(resetn),
		.order_enable(score_enable),
		.recipe(recipe),
		.caught_cake(caught_cake),
		//Outputs
		.order_done(w_orderdone),
		.order_score(w_orderscore)
	);
				
endmodule


module order_calculation (clock, resetn, order_enable, recipe, caught_cake, //Inputs
									order_done, order_score);//Outputs
	input clock, resetn, order_enable;
	input [17:0] recipe, caught_cake;
	output reg order_done;
	output reg [2:0] order_score;

	reg [4:0] order_num;
	reg order_calc_done;
	
	always @(posedge clock)
	begin
		if (!resetn) //Reset
		begin
			order_num <= 5'b0;
			order_done <= 1'b0;
			order_calc_done <= 1'b0;
		end
		else
		begin
			if (order_enable)
				begin
				if (recipe [2:0] == caught_cake [2:0])
				begin
					order_num[0] <= 1'b1;
				end
				if (recipe [5:3] == caught_cake [5:3])
				begin
					order_num[1] <= 1'b1;
				end
				if (recipe [8:6] == caught_cake [8:6])
				begin
					order_num[2] <= 1'b1;
				end
				if (recipe [11:9] == caught_cake [11:9])
				begin
					order_num[3] <= 1'b1;
				end
				if (recipe [14:12] == caught_cake [14:12])
				begin
					order_num[4] <= 1'b1;
				end
				order_calc_done <= 1'b1;
			end
			else
			begin
				order_num <= order_num;
				order_done <= 1'b0;
				order_calc_done <= 1'b0;
			end
			if (order_calc_done)
			begin
				order_score <= {2'b0, order_num[0]} + {2'b0, order_num[1]} + {2'b0, order_num[2]} + {2'b0, order_num[3]} + {2'b0, order_num[4]};
				order_done <= 1'b1;
			end
			else
			begin
				order_score <= 3'b0;
				order_done <= 1'b0;
			end
		end
	end
	
					
endmodule
