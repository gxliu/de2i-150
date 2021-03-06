module aes_enc_128 (
	aes_clk_in,
	aes_rst_in,
	wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o,
	 wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o
	);

	input aes_clk_in;
	input aes_rst_in;
	
	// WISHBONE common
   input           wb_clk_i;     // WISHBONE clock
   input           wb_rst_i;     // WISHBONE reset
   input [31:0]    wb_dat_i;     // WISHBONE data input
   output [31:0] wb_dat_o;     // WISHBONE data output
   // WISHBONE error output

   // WISHBONE slave
   input [7:0] 	     wb_adr_i;     // WISHBONE address input
   input [3:0] 	     wb_sel_i;     // WISHBONE byte select input
   input 	     wb_we_i;      // WISHBONE write enable input
   input 	     wb_cyc_i;     // WISHBONE cycle input
   input 	     wb_stb_i;     // WISHBONE strobe input

   output 	     wb_ack_o;     // WISHBONE acknowledge output
	
	wire [127:0] plain_in;  //input plaintext
	wire [127:0] cipher_out;	  //encryption key
	wire [127:0] key;
	
	assign key = 128'h126a83546212def2;
 
	// Instantiate the Unit Under Test (UUT)
	aes_128 aes128 (
		.clk(aes_clk_in), 
		.state(plain_in), 
		.key(key), 
		.out(cipher_out)
	);	
	
	aes_wb aes128_wb (
		.wb_clk_i(wb_clk_i),
		.wb_rst_i(wb_rst_i),
		.wb_dat_i(wb_dat_i),
		.wb_dat_o(wb_dat_o),
		.wb_adr_i(wb_adr_i),
		.wb_sel_i(wb_sel_i),
		.wb_we_i(wb_we_i),
		.wb_cyc_i(wb_cyc_i),
		.wb_stb_i(wb_stb_i),
		.wb_ack_o(wb_ack_o),
		.plaintext_o(plain_in),
		.ciphertext_i(cipher_out)
	);
	
	
endmodule

