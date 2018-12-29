module recipe_render(
	input clk,
	input resetn,
	input ld_recipe,
	
	output done_recipe,
	output [17:0] recipe
	);
	
	reg [7:0] rand_addr;
	wire [7:0] rand_num;
	wire [2:0] clrOut;
	reg [2:0] layer1, layer2, layer3, layer4, layer5, cherry_layer;
	reg [2:0] layer_count;
	reg [2:0] rand_clr;
	
	assign done_recipe = (layer_count == 3'd6) ? 1'b1 : 1'b0;
	assign recipe = {cherry_layer, layer1, layer2, layer3, layer4, layer5};
	
	always @(posedge clk)
	begin
		if (!resetn) begin
			layer_count <= 3'd0;
			layer1 <= 3'd0;
			layer2 <= 3'd0;
			layer3 <= 3'd0; 
			layer4 <= 3'd0;
			layer5 <= 3'd0;
			cherry_layer <= 3'd0;
		end 
		else begin
					layer_count <= 3'd0;
					layer1 <= layer1;
					layer2 <= layer2;
					layer3 <= layer3;
					layer4 <= layer4;
					layer5 <= layer5;
					cherry_layer <= 3'b111;
			if (ld_recipe) begin
				if (layer_count == 3'd0) begin
					layer1 <= clrOut;
					layer_count <= layer_count + 1'b1;
					end 
				else if (layer_count == 3'd1) begin
					layer2 <= clrOut;
					layer_count <= layer_count + 1'b1;
					end 
				else if (layer_count == 3'd2) begin
					layer3 <= clrOut;
					layer_count <= layer_count + 1'b1;
					end 
				else if (layer_count == 3'd3) begin
					layer4 <= clrOut;
					layer_count <= layer_count + 1'b1;
					end 
				else if (layer_count == 3'd4) begin
					layer5 <= clrOut;
					cherry_layer <= 3'b111; //cherry
					layer_count <= layer_count + 1'b1;
					end  
				else if (layer_count == 3'd5) begin
					layer_count <= layer_count + 1'b1;
					end 
				end
			end 
	end 
	
	
	always @(posedge clk)
	begin: read_rand_rom
		if (!resetn) begin
			rand_addr <= 8'd56;
			rand_clr <= 3'b111;
			end 
		else begin
			rand_clr <= rand_num[2:0];
			if (rand_addr == 8'd255) begin
				rand_addr <= 8'b0;
				end 
			else begin
				rand_addr <= rand_addr + 1'b1;
				end 
		end 
	end 
	
	rand_num_rom rand_recipe(
		.address(rand_addr),
		.clk(clk),
		.data(rand_num)
		);
	
	colourMux layer_colour(
		.randNum(rand_clr), 
		.clrOut(clrOut)
		);

endmodule 