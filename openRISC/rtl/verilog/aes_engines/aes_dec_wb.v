module aes_dec_wb(
		  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

		  // WISHBONE slave
		  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o,

		  // encryption reg
		  plaintext_i, ciphertext_o, dec_cs, dec_done
		  );
   
   /************ Input/Output Declaration **************/

   // WISHBONE common
   input           wb_clk_i;     // WISHBONE clock
   input           wb_rst_i;     // WISHBONE reset
   input [31:0]    wb_dat_i;     // WISHBONE data input
   output reg [31:0] wb_dat_o;     // WISHBONE data output

   // WISHBONE slave
   input [7:0] 	     wb_adr_i;     // WISHBONE address input
   input [3:0] 	     wb_sel_i;     // WISHBONE byte select input
   input 	     wb_we_i;      // WISHBONE write enable input
   input 	     wb_cyc_i;     // WISHBONE cycle input
   input 	     wb_stb_i;     // WISHBONE strobe input
   output 	     wb_ack_o;     // WISHBONE acknowledge output

   // control signal
   output reg 	     dec_cs;
   input 	     dec_done;

   // data in/out
   input [127:0]     plaintext_i;
   output reg [127:0] ciphertext_o;

   /************ Internal Signal/Register **************/

   // internal wire/reg
   reg [127:0] 	      plaintext_reg;
   reg [127:0] 	      ciphertext_reg;

   reg [4:0] 	      count;
   reg 		      start;

   //Register Addreses 
`define cipherIn0 8'h00
`define cipherIn1 8'h04
`define cipherIn2 8'h08
`define cipherIn3 8'h0c
`define plainOut0 8'h10
`define plainOut1 8'h14
`define plainOut2 8'h18
`define plainOut3 8'h1c
`define decdone 8'h20

   assign wb_ack_o = wb_cyc_i & wb_stb_i;

   initial
     count = 0;

   always @(posedge wb_clk_i or posedge wb_rst_i)
     begin
	
	if ( wb_rst_i )begin
	   plaintext_reg <= 128'b0;
	   ciphertext_reg <= 128'b0;      
	end
	else if ((wb_stb_i  & wb_cyc_i) || wb_ack_o )begin 
	   dec_cs <= 0;
	   if (wb_we_i) begin
	      case (wb_adr_i) 
		// MSB first, LSB last
	        `cipherIn0:  ciphertext_reg[127:96]  <=  wb_dat_i;
	        `cipherIn1:  ciphertext_reg[95:64]  <=  wb_dat_i;
	        `cipherIn2:  ciphertext_reg[63:32]  <=  wb_dat_i;
	        `cipherIn3:  begin
		   ciphertext_reg[31:0]  <=  wb_dat_i;
		   dec_cs <= 1;
		end
	        `plainOut0:  plaintext_reg[127:96]  <=  wb_dat_i;
	        `plainOut1:  plaintext_reg[95:64]  <=  wb_dat_i;
	        `plainOut2:  plaintext_reg[63:32]  <=  wb_dat_i;
	        `plainOut3:  plaintext_reg[31:0]  <=  wb_dat_i;
	      endcase
	   end 
	   plaintext_reg <= plaintext_i;
	   ciphertext_o <= ciphertext_reg;
	end // if ((wb_stb_i  & wb_cyc_i) || wb_ack_o )
	else begin
	   plaintext_reg <= plaintext_i;
	   ciphertext_o <= ciphertext_reg;
	end
     end

   always @(posedge wb_clk_i )begin
      if (wb_stb_i  & wb_cyc_i) begin //CS
	 case (wb_adr_i)
	   `cipherIn0:  wb_dat_o  <=   plaintext_reg[127:96];
	   `cipherIn1:  wb_dat_o  <=   plaintext_reg[95:64];
	   `cipherIn2:  wb_dat_o  <=   plaintext_reg[63:32];
	   `cipherIn3:  wb_dat_o  <=   plaintext_reg[31:0];
	   `plainOut0:  wb_dat_o  <=  ciphertext_reg[127:96];
	   `plainOut1:  wb_dat_o  <=  ciphertext_reg[95:64];
	   `plainOut2:  wb_dat_o  <=  ciphertext_reg[63:32];
	   `plainOut3:  wb_dat_o  <=  ciphertext_reg[31:0];	   
	   `decdone:  wb_dat_o  <=  {31'b0, dec_done};
	 endcase
      end 
   end

endmodule
