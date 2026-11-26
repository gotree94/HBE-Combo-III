`timescale 1ns/1ps

module tb_CH2_16MUX_IF;
    reg  I0, I1, I2, I3, I4, I5, I6, I7;
    reg  I8, I9, I10, I11, I12, I13, I14, I15;
    reg  [3:0] S;
    wire Z;

    integer i;

    CH2_16MUX_IF dut (
        .I0(I0),   .I1(I1),   .I2(I2),   .I3(I3),
        .I4(I4),   .I5(I5),   .I6(I6),   .I7(I7),
        .I8(I8),   .I9(I9),   .I10(I10), .I11(I11),
        .I12(I12), .I13(I13), .I14(I14), .I15(I15),
        .S(S),     .Z(Z)
    );

    initial begin
        I0=0; I1=0; I2=0; I3=0; I4=0; I5=0; I6=0; I7=0;
        I8=0; I9=0; I10=0; I11=0; I12=0; I13=0; I14=0; I15=0;
        S = 4'b0000;
    end

    // I0~I15: 서로 다른 토글 주기 (10ns ~ 40ns)
    always #5  I0  = ~I0;
    always #6  I1  = ~I1;
    always #7  I2  = ~I2;
    always #8  I3  = ~I3;
    always #9  I4  = ~I4;
    always #10 I5  = ~I5;
    always #11 I6  = ~I6;
    always #12 I7  = ~I7;
    always #13 I8  = ~I8;
    always #14 I9  = ~I9;
    always #15 I10 = ~I10;
    always #16 I11 = ~I11;
    always #17 I12 = ~I12;
    always #18 I13 = ~I13;
    always #19 I14 = ~I14;
    always #20 I15 = ~I15;

    // S 선택 시간: 200ns씩 유지, 전체 3200ns
    initial begin
        $dumpfile("tb_CH2_16MUX_IF.vcd");
        $dumpvars(0, tb_CH2_16MUX_IF);

        for (i = 0; i < 16; i = i + 1) begin
            S = i[3:0];
            #200;
        end

        $finish;
    end
endmodule
