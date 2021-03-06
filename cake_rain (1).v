module cake_rain(

 		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,							// On Board Keys
		SW,							// On Board Switches
		LEDR,
		HEX0,
		HEX1,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);	
	
		// Declare your inputs and outputs here
	input			CLOCK_50;				//	50 MHz
	input	[3:0]	KEY;					
	input [9:0] SW;
	
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1;
	
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn, game_start;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire left, right;
	wire [3:0] hex_sel, hex1;

	assign resetn = KEY[0];
	assign game_start = ~KEY[1];
	assign right = KEY[2];
	assign left = KEY[3];

	
	game_top game0(
		.clk(CLOCK_50), 
		.resetn(resetn),
		.game_start(game_start),
		
		.left(left),
		.right(right),
		
//		.hex_sel(hex_sel),
//		.hex1(hex1),
//	
		.caught_cherry(SW[0]),
		.x_vga(x),
		.y_vga(y),
		.colour_vga(colour),
		.writeEn(writeEn)
	);
	
	
    hex_decoder H0(
        .hex_digit(hex_sel), 
        .segments(HEX0)
        );
		  
	 hex_decoder H1(
	  .hex_digit(hex1), 
	  .segments(HEX1)
	  );
        
	
	
//	cake_render cake0(
//		.clk(CLOCK_50), 
//		.resetn(resetn),
//		.go_cake(1'b1),
//		.go_shift(1'b1),
//		
//		
//		.x_cake(x),
//		.y_cake(y),
//		.colour_cake(colour),
//	
//		.done_cake(LEDR[0])
//		
//	);

//	cherry_render cherry_render0(
//		.clk(CLOCK_50), 
//		.resetn(resetn),
//		.go_cherry(1'b1),
//		.go_shift(1'b1),
//	
//	
//		.x_cherry(x),
//		.y_cherry(y),
//		.colour_cherry(colour),
////	
////		//.done_cherry(done_cherry)
////		
////		);
//
//	erase_screen  erase0(
//			.clk(CLOCK_50),
//			.resetn(resetn),
//			.go_erase(SW[0]),
//		
//			.x_to_vga(x),
//			.y_to_vga(y),
//			.colour_to_vga(colour),
//			//.done_erase()
//		);
	
	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "start_screen.mif";

endmodule
module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
