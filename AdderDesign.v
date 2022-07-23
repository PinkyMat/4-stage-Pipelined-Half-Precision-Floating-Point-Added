module AdderDesign(input [15:0]A10, input [15:0]B10, input clk10,input reset10, output
[15:0]sum10);
 reg [4:0] E_A10, E_B10, ResultantExp_10, FinalExp_10;
 reg [4:0] SignEA_10, SignEB_10, SignE_10;
 reg [10:0] MA_10, MB_10, NewMA_10, NewMB_10, TwosComp_10;
 reg [10:0] MSA_10, MSB_10;
reg [15:0] DummyA_10;
 reg [15:0] DummyB_10;
 reg [11:0] ModifiedM_10, s2_M_10, s3_M_10, FinalMantissa_10;
 reg [5:0] shiftnum_10, s3_shiftnum_10;
reg SA_10, SB_10, ResultS_10;
 reg S1_A_10, S1_B_10, S_10, S_Fin_10;
 reg shift_10, s3_shift_10;
 assign DummyA_10 = A10; //Assign inputs to temporary registers for operations
 assign DummyB_10 = B10;
//combining different part of the FP number to form final sum
 assign sum10 = {S_Fin_10, FinalExp_10, FinalMantissa_10[9:0]};
//Extracting each part of FP number
 always @(*) begin
 shiftnum_10 = 0;
 SA_10 = DummyA_10[15]; // sign bit of A
 SB_10 = DummyB_10[15]; // sign bit of B
 E_A10 = DummyA_10[14:10]; //exponent of A
 E_B10 = DummyB_10[14:10]; //exponent of B
 MA_10 = (DummyA_10==16'b0 ? {1'b0, DummyA_10[9:0]} : {1'b1, DummyA_10[9:0]}); //
mantissa of A with hidden bit
 MB_10 = (DummyB_10==16'b0 ? {1'b0, DummyB_10[9:0]} : {1'b1, DummyB_10[9:0]}); //
mantissa of B with hidden bit
 /* Stage 1: The exponents are compared, and the number of shifts needed to align the mantissa
so that the exponents are equal is calculated.
 The mantissa of the smaller exponent is then right shifted by the needed amount
(alignment). */
 if(E_A10 > E_B10) begin
 ResultantExp_10 = E_A10; //exponent of the higher number
 NewMA_10 = MA_10;
 NewMB_10 = MB_10 >> (E_A10 - E_B10); //shifting mantissa of the one with smaller
exponent
 end
 else begin
 ResultantExp_10 = E_B10;
 NewMA_10 = MA_10 >> (E_B10 - E_A10);
 NewMB_10 = MB_10;
 end

 /* Stage 2: Compare the two aligned mantissas to determine which is smaller.
 If the signs of the two numbers vary, take the 2's complement of the smaller
mantissa.
 The two mantissas were then attached. */
 if(MSA_10 > MSB_10) begin
 ResultS_10 = S1_A_10; //taking the sign bit of the bigger mantissa
 if(S1_A_10 == S1_B_10)
 ModifiedM_10 = MSA_10 + MSB_10; //adding the mantissa if both sign bits are same
 else begin
 TwosComp_10 = MSA_10 + (~MSB_10 + 1);
 ModifiedM_10 = {1'b0, TwosComp_10[10:0]}; //sub the mantissa if sign bits are
different by taking 2's complement
 end
 end
 else if(MSA_10 < MSB_10) begin
 ResultS_10 = S1_B_10;
 if(S1_A_10 == S1_B_10)
 ModifiedM_10 = MSA_10 + MSB_10; //adding the mantissa if both sign bits are same
 else begin
 TwosComp_10 = (~MSA_10 + 1) + MSB_10;
 ModifiedM_10 = {1'b0, TwosComp_10[10:0]}; //substract the mantissa if sign bits are
different by taking 2's complement
 end
 end
 else begin //when both are same: special case
 ResultS_10 = S1_A_10;
 if(S1_A_10 == S1_B_10)
 ModifiedM_10 = MSA_10 + MSB_10;
 else
 ModifiedM_10 = 12'b0;
 end
 /* Stage 3: Determined the number of shifts needed and the direction in which
 they should be applied to normalize the outcome (normalization 1).*/

 if(s2_M_10 == 12'b0) begin //if all 12 bits are 0 then no shift is required as the value is 0
 shift_10 = 0;
 shiftnum_10 = 0;
 end
 else if(s2_M_10[11] == 1'b1) begin //if the last bit is 0, have to shift 1 bit to right
 shift_10 = 1; //1 indicated shifting to right
 shiftnum_10 = 1;
 end
 else if(s2_M_10[11:10] == 2'b00) begin //else check the first 10 bits and shift to get 1.xxx
format
 shift_10 = 0; //0 indicates shifting to left
 for(int i=0; i<=9; i++) begin
 if(s2_M_10[i]==1'b1) begin
 shiftnum_10 = 10 - i; //calculating the amount of shift required
 end
 end
 end
 /* Stage 4: Shifted the mantissa by the specified amount in the appropriate direction.
 The exponent has been changed and is being checked for any unusual
conditions.*/

 if(s3_shiftnum_10 > 0) begin
 if(s3_shift_10 == 1'b1) begin
 FinalMantissa_10 = s3_M_10 >> s3_shiftnum_10; //shifting the final mantissa
 FinalExp_10 = SignE_10 + s3_shiftnum_10; //adjusting the final exponent
 end
 else begin
 FinalMantissa_10 = s3_M_10 << s3_shiftnum_10;
 FinalExp_10 = SignE_10 - s3_shiftnum_10;
 end
 end
 else begin
 FinalMantissa_10 = s3_M_10;
 FinalExp_10 = SignE_10;
 end
 end
 always @(posedge clk10 or posedge reset10)
begin
 if(reset10) begin
 MA_10 <= 0;
 MB_10 <= 0;
 E_A10 <= 0;
 E_B10 <= 0;
 SA_10 <= 0;
 SB_10 <= 0;
 MSA_10 <= 0;
 MSB_10 <= 0;
 SignEA_10 <= 0;
 S1_A_10 <= 0;
 S1_B_10 <= 0;
 s2_M_10 <= 0;
 SignEB_10 <= 0;
 S_10 <= 0;
 s3_shift_10 <= 0;
 s3_shiftnum_10 <= 0;
 s3_M_10 <= 0;
 SignE_10 <= 0;
 S_Fin_10 <= 0;
 end
 else
 begin
 //pipelining
 MSA_10 <= NewMA_10;
 MSB_10 <= NewMB_10;
 SignEA_10 <= ResultantExp_10;
 S1_A_10 <= SA_10;
 S1_B_10 <= SB_10;
 //pipelining
 s2_M_10 <= ModifiedM_10;
 SignEB_10 <= SignEA_10;
 S_10 <= ResultS_10;
 //pipelining
 s3_shift_10 <= shift_10;
 s3_shiftnum_10 <= shiftnum_10;
 s3_M_10 <= s2_M_10;
 SignE_10 <= SignEB_10;
 S_Fin_10 <= S_10;
 end
 end
endmodule
