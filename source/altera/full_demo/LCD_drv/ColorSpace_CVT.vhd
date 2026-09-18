 -- ********************************************************
 -- *								              		   *
 -- *  Modulo  Y U(Cb)V(Cr) -> RGB  (8 bit input & output) *
 -- *								                       *
 -- *  R = 1.164*(Y-16) + 1.596*(V-128)                    *
 -- *  G = 1.164*(Y-16) - 0.391*(U-128) - 0.813*(V-128)    *
 -- *  B = 1.164*(Y-16) + 2.032*(V-128)                    *
 -- *								            		   *
 -- ********************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity COLORSPACE_CVT is  
port(
		CLK			: in std_logic;									-- clock 27MHz
		HS			: in std_logic;									-- cnt reset(Hsync = '0' reset)
		VS			: in std_logic;
		VPO_D		: in std_logic_vector(7 downto 0);				-- CCIR 601 or 656 Video data source
		Y,U,V		: buffer std_logic_vector(7 downto 0);			-- Cb,Y,Cr 24bit video data
		HS_dly		: out std_logic;
		VS_dly		: out std_logic;
		R,G,B		: out std_logic_vector(7 downto 0)

	);
	
end COLORSPACE_CVT;

architecture a of COLORSPACE_CVT is 

signal cnt 					: integer range 0 to 3;
signal Cb_sig,Y_sig,Cr_sig 	: std_logic_vector(7 downto 0);
signal Y_int, U_int1, V_int1, U_int2, V_int2 : std_logic_vector(19 downto 0);
signal UV_int,R_int,G_int,B_int : std_logic_vector(20 downto 0);
signal A1_int, A2_int, R_tmp,G_tmp,B_tmp : std_logic_vector(21 downto 0);
signal R_reg,G_reg,B_reg : std_logic_vector(7 downto 0);
signal hs1,hs2,vs1,vs2 : std_logic;

begin
-----------------------------------------------------------------------------
-- YUV 8bit 4:2:2 데이터를 4:4:4 데이터로 변환후 Cb,Y, Cr 각각 8bit로 변환 출력  

	process(CLK,HS)													--성분  분리 카운터 ,hsync가 '0'면 리셋 
	begin
		if(HS = '0')then
			cnt <= 0;
		elsif (CLK'event and CLK = '1')then
			cnt <= cnt + 1;
		end if;
	end process;
	
	process(CLK)												 
	begin															--Cb,Y,Cr을 차례로 분리 	
		if (CLK'event and CLK = '1')then
			if cnt = 0 then
				Cr_sig <= VPO_D;
			elsif (cnt = 1) or(cnt = 3)then
				Y_sig <= VPO_D;
			elsif CNT = 2 then
				Cb_sig <= VPO_D;  	
			end if;	
			
			if (CNT = 0)or(CNT = 2) then							--분리된 Cb,Y,Cr 출력 
				U <= Cb_sig;										--Y0,Y1 이 Cr0 값을 공유, Y1,Y2는 Cb1값을 공유  
				Y  <= Y_sig;
				V <= Cr_sig;
			end if;			
		end if;
	end process;
	
	process(CLK)													-- Hsync,Vsync Delay
	begin
		if CLK'event and CLK = '1' then
			hs1 <= HS;
			hs2 <= hs1;

			vs1 <= VS;
			vs2 <= vs1;

			HS_dly <= hs1;
			VS_dly <= vs1;
		end if;
	end process;

			R <= R_reg;
			G <= G_reg;
			B <= B_reg;
--------------------------------------------------------------------------
-- 
--   R*1024 = 1192*(Y-16) + 1634*(V-128)
--   G*1024 = 1192*(Y-16) - 400*(U-128) - 833X(V-128)
--   B*1024 = 1192*(Y-16) + 2065*(U-128)
--
--   R*1024 = 1192*Y + 1634*V - 228224
--   G*1024 = 1192*Y - 400*U - 833*V + 138752
--   B*1024 = 1192*Y + 2065*U - 283392
--
---------------------------------------------------------------------------
 
Y_int  <= Y * "010010101000";   -- Y_int  = Y * 1192
V_int1 <= V * "011001100010";   -- V_int1 = V * 1634
U_int1 <= U * "000110010000";   -- U_int1 = U * 400
V_int2 <= V * "001101000001";   -- V_int1 = V * 833
U_int2 <= U * "100000010001";   -- U_int1 = U * 2065

UV_int <= ('0' & U_int1) + ('0' & V_int2);      -- UV_int = U_int1 + V_int2
R_int  <= ('0' & Y_int) + ('0' & V_int1);       -- R_int  = Y_int + V_int1
G_int  <= ('0' & Y_int);                        -- G_int  = Y_int
B_int  <= ('0' & Y_int) + ('0' & U_int2);       -- B_int  = Y_int + U_int2

A1_int <= G_int  + "0000100001111000000000"; -- A1_int = G_int + 138752
A2_int <= UV_int + "0000011101111000000000"; -- A1_int = UV_int + 122368

R_tmp <= R_int - "0000110111101110000000";   -- R_tmp = R_int - 228224
G_tmp <= A1_int - ('0' & UV_int);            -- G_tmp = A1_int - UV_int
B_tmp <= B_int - "0001000101001100000000";   -- R_tmp = R_int - 283392

-----------------------------------------------------------------------------
-- Cb,Y,Cr 8bit 데이터를 R,G,B 8bit로 각각 변환 출력 

	process (R_int, R_tmp)    
	 begin
	   if R_int < 228224 then
	     R_reg <= "00000000";
	   elsif R_int > 489344 then
		 R_reg <= "11111111";
	   else
	     R_reg <= R_tmp(17 downto 10);  
	   end if;
	 end process;

	process (G_int, A1_int, A2_int, G_tmp, UV_int)    
	 begin
	   if A1_int < UV_int then
	     G_reg <= "00000000";
	   elsif G_int > A2_int then
		 G_reg <= "11111111";
	   else
	     G_reg <= G_tmp(17 downto 10);  
	   end if;
	 end process;

	process (B_int, B_tmp)    
	 begin
	   if B_int < 283392 then
	     B_reg <= "00000000";
	   elsif B_int > 544512 then
		 B_reg <= "11111111";
	   else
	     B_reg <= B_tmp(17 downto 10);  
	   end if;
	 end process;

	end a;