// 5CSEMA5F31C6

module plate_render (clock, resetn, draw_enable, left, right, draw_done, x, y, colour);

	input clock, resetn, draw_enable, left, right;
	output draw_done;
	output [7:0] x;
	output [6:0] y;
	output [2:0] colour;
	
	wire w_cdone, w_shiftlin, w_shiftrin, w_ld, w_shiftlout, w_shiftrout, w_cen;
	
	assign draw_done = w_cdone;
	
	plate_control C0 (
		//Inputs
		.clock(clock),
		.resetn(resetn),
		.count_done(w_cdone),
		.erase_done(draw_enable),
		.shift_lin(w_shiftlin),
		.shift_rin(w_shiftrin),
		//Outputs
		.load(w_ld),
		.shift_lout(w_shiftlout),
		.shift_rout(w_shiftrout),
		.count_enable(w_cen)//,		.plot(writeEn)
	);
	
	plate_data D0 (
		//Inputs
		.clock(clock),
		.resetn(resetn), 
		.colour_in(3'b111), //ALWAYS WHITE
		.load(w_ld),
		.count_enable(w_cen),
		.shift_lin(w_shiftlout),
		.shift_rin(w_shiftrout),
		//Outputs
		.count_done(w_cdone), //Plate draw done
		.x_out(x),
		.y_out(y),
		.colour_out(colour)
    );

	 assign w_shiftlin = ~left;
	 assign w_shiftrin = ~right;
//	//Key Debounce
//	key_debounce KD1(
//		.clock(clock),
//		.resetn(resetn),
//		.key_in(~left),
//		.key_out(w_shiftlin)
//	);
//	
//	key_debounce KD0(
//		.clock(clock),
//		.resetn(resetn),
//		.key_in(~right),
//		.key_out(w_shiftrin)
//	);

endmodule

module plate_control(
   input clock,
   input resetn,
	input count_done,
	input erase_done,
	input shift_lin, shift_rin,
   output reg  load, shift_lout, shift_rout,
	output reg count_enable
//   output reg plot //draw enable
	);

    reg [2:0] current_state, next_state; 
    
    localparam S0_LOAD					= 3'd0,
					S1_DRAW					= 3'd1,
					S2_WAITERASE			= 3'd2,
					S3_WAITMOVE				= 3'd3,
					S4_SHIFT_L				= 3'd4,
					S5_SHIFT_R				= 3'd5;

    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
				S0_LOAD: next_state = S1_DRAW;
				S1_DRAW: next_state = count_done ? S2_WAITERASE : S1_DRAW;
				S2_WAITERASE: next_state = erase_done ? S3_WAITMOVE : S2_WAITERASE;
				S3_WAITMOVE:
				begin
					if (shift_lin == shift_rin) //if both buttons are pressed or not pressed
						next_state = S1_DRAW;
					else if (shift_lin) //if left is pressed
						next_state = S4_SHIFT_L;
					else if (shift_rin) //if right is pressed
						next_state = S5_SHIFT_R;
					else //catch
						next_state = S1_DRAW;
				end
				S4_SHIFT_L: next_state = S1_DRAW;
				S5_SHIFT_R: next_state = S1_DRAW;
			default: next_state = S0_LOAD;
		endcase
    end // state_table
   
    // Output logic
    always @(*)
    begin: enable_signals
        load = 1'b0;
        count_enable = 1'b0;
        //plot = 1'b0;
		  shift_lout = 1'b0;
		  shift_rout = 1'b0;

        case (current_state)
            S0_LOAD:
				begin
					load = 1'b1;
            end
            S1_DRAW:
				begin
               count_enable = 1'b1;
					//plot = 1'b1;
            end
            //S2_WAITERASE:
					//plot = 1'b0;
				//S3_WAITMOVE:
				S4_SHIFT_L:
				begin
               shift_lout = 1'b1;
            end
				S5_SHIFT_R:
				begin
               shift_rout = 1'b1;
            end
			default: load = 1'b0;
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= S0_LOAD;
        else
            current_state <= next_state;
    end // state_FFS
endmodule

module plate_data(
	input clock,
	input resetn, 
	input [2:0] colour_in,
	input load,
	input count_enable,
	input shift_lin,
	input shift_rin,
	output reg count_done,
	output reg [7:0] x_out,
	output reg [6:0] y_out,
	output reg [2:0] colour_out
    );
    
   // input registers
   reg [7:0] x = 8'b0;
	reg [6:0] y = 7'b0;
	reg [2:0] colour_reg = 3'b0;
	reg [6:0] counter = 7'b0;

    
    // Registers x, y, colour, counter, clearcount with respective input logic
    always@(posedge clock)
	 begin
        if(!resetn)
		  begin
            x <= 8'b11; 
            y <= 7'd112;
            colour_reg <= 3'b0; 
            counter <= 7'b0; 
        end
		  
        else
		  begin
				if(load)
				begin
                x <= 8'd11;
                y <= 7'd112; //always same
                colour_reg <= colour_in;
				end
				if (shift_lin)
				begin
					if ((x >= 8'd12) && (x <= 8'd136)) // 10 left pix for sidebar
						x <= x - 7'd1;
					else
						x <= x;
					colour_reg <= 3'b111; // White
				end
				if (shift_rin)
				begin
					if ((x <= 8'd135) && (x >= 8'd11))
						x <= x + 7'd1;
					else
						x <= x;
					colour_reg <= 3'b111; // White
				end
            if(count_enable)
                counter <= counter + 7'd1;
				else
					counter <= 0;
        end
    end

	//Drawing
	always@(*) begin //always@(posedge clock) begin
		if (count_enable)
		begin
			x_out <= x + {3'b0, counter[6:2]};
			y_out <= y + {5'b0, counter[1:0]};
		end
		colour_out <= colour_reg;
		count_done <= (counter == 7'b10111_11); //23 for x, 3 for y (plate is 24x4)
	end

endmodule



module key_debounce (input clock, resetn, key_in, output reg key_out);
	reg [1:0] status; //1 old, 0 new
	reg [23:0] counter;

	always @(posedge clock)
	begin
	
		if (resetn)
		begin
			counter <= 24'b0;
		end
		
		status[1] = status[0];
		status[0] = key_in;
		
		if (status == 2'b01) //Key pressed
		begin
			counter <= 24'd120;//OUTPUT PULSE TIME (# OF CLOCKUPS)
		end
		else
		begin
			counter <= counter;
		end
		
		
		if (counter > 24'd0)
		begin
			key_out = 1'b1;
			counter <= counter - 24'd1;
		end
		else
		begin
			key_out = 1'b0;
		end

	end
endmodule

/*
module in_erase(input resetn, erase_enable, erase_done, output in_erase);
	reg erase;
	always @(*)
	begin
		if (~resetn)
		begin
			erase = 1'b0;
		end
		else
			erase <= erase_enable - erase_done + erase;
	end
	assign in_erase = erase;
endmodule
*/
