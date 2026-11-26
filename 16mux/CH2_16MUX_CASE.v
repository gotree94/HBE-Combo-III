module CH2_16MUX_CASE (I0, I1, I2, I3, I4, I5, I6, I7,
                      I8, I9, I10, I11, I12, I13, I14, I15, S, Z);
    input  I0, I1, I2, I3, I4, I5, I6, I7;
    input  I8, I9, I10, I11, I12, I13, I14, I15;
    input  [3:0] S;
    output Z;
    reg    Z;

    always @(I0, I1, I2, I3, I4, I5, I6, I7,
             I8, I9, I10, I11, I12, I13, I14, I15, S) begin
        case (S)
            4'b0000: Z = I0;
            4'b0001: Z = I1;
            4'b0010: Z = I2;
            4'b0011: Z = I3;
            4'b0100: Z = I4;
            4'b0101: Z = I5;
            4'b0110: Z = I6;
            4'b0111: Z = I7;
            4'b1000: Z = I8;
            4'b1001: Z = I9;
            4'b1010: Z = I10;
            4'b1011: Z = I11;
            4'b1100: Z = I12;
            4'b1101: Z = I13;
            4'b1110: Z = I14;
            4'b1111: Z = I15;
            default: Z = I0;
        endcase
    end
endmodule
