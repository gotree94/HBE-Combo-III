module CH2_16MUX_IF (I0, I1, I2, I3, I4, I5, I6, I7,
                    I8, I9, I10, I11, I12, I13, I14, I15, S, Z);
    input  I0, I1, I2, I3, I4, I5, I6, I7;
    input  I8, I9, I10, I11, I12, I13, I14, I15;
    input  [3:0] S;
    output Z;
    reg    Z;

    always @(I0, I1, I2, I3, I4, I5, I6, I7,
             I8, I9, I10, I11, I12, I13, I14, I15, S) begin
        if (S == 4'b0000)
            Z = I0;
        else if (S == 4'b0001)
            Z = I1;
        else if (S == 4'b0010)
            Z = I2;
        else if (S == 4'b0011)
            Z = I3;
        else if (S == 4'b0100)
            Z = I4;
        else if (S == 4'b0101)
            Z = I5;
        else if (S == 4'b0110)
            Z = I6;
        else if (S == 4'b0111)
            Z = I7;
        else if (S == 4'b1000)
            Z = I8;
        else if (S == 4'b1001)
            Z = I9;
        else if (S == 4'b1010)
            Z = I10;
        else if (S == 4'b1011)
            Z = I11;
        else if (S == 4'b1100)
            Z = I12;
        else if (S == 4'b1101)
            Z = I13;
        else if (S == 4'b1110)
            Z = I14;
        else
            Z = I15;
    end
endmodule
