library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
--------------------------------------------------------------------------------------------
-- Interace and Progressive timing generator

entity IP_Timing_gen is
port(
		--Common Part
		CLK27	: in std_logic;									--Main Clock (27MHz)
		CLK13_5	: buffer std_logic;								--Main Clock /2(13.5MHz)
		CLK6_75	: buffer std_logic;								--Main Clock /4 (6.75Mhz)
		nOE		: out std_logic;								--output enable (SRAM read enable)
		P_nWR	: out std_logic;								--SRAM Write enable
		P_CNT	: buffer integer range 0 to 1023;
		H_CNT	: buffer integer range 0 to 1023;
		LHS		: out std_logic;
		LVS		: out std_logic;

		--Progressive part
		P_HS		: in std_logic;								--Hsync
		P_VS		: in std_logic;								--Vsync
		P_R			: in std_logic_vector(7 downto 0);			--Video Red data
		P_G			: in std_logic_vector(7 downto 0);			--Video Green data
		P_B			: in std_logic_vector(7 downto 0);			--Video Blue data

		P_WR_ADD	: out std_logic_vector(17 downto 0);			--SRAM Write address
		P_RGB565	: out std_logic_vector(15 downto 0);		--RGB 565 format video data
		RST			: in std_logic

	);
	
end IP_Timing_gen;

architecture a of IP_Timing_gen is 
signal cnt : integer range 0 to 511;

signal M_HS : std_logic;
signal M_HS_CNT : integer range 0 to 1023;
signal M_VS_CNT : integer range 0 to 1023;

signal HS_cnt : integer range 0 to 2047;
signal VS_cnt : integer range 0 to 2047;
signal hs,vs,hs1,hs2,hs3,vs1,vs2,vs3 : std_logic;

signal P_Pcnt,P_Hcnt : std_logic_vector(9 downto 0);

signal int_cnt : integer range 0 to 3;
signal int_add : std_logic_vector(17 downto 0);--integer range 0 to 77000;
signal int : std_logic;


begin

	process(CLK27)													-- Hsync,Vsync Delay
	begin
		if CLK27'event and CLK27 = '1' then
			hs1 <= HS;
			hs2 <= hs1;
			hs3 <= hs2;
			vs1 <= VS;
			vs2 <= vs1;
			vs3 <= vs2;
		end if;
	end process;
	
LVS <= vs3;
LHS <= hs3;
------------------------------------------------------------------------------------------------------------
-- Common part

	process(CLK27,RST)
	begin
		if rst = '0' then
			CLK13_5 <= '0';
		elsif CLK27'event and CLK27 = '1' then
			CLK13_5 <= not CLK13_5;
		end if;
	end process;
	
	Process(CLK13_5,RST)
	begin
		if rst = '0' then
			CLK6_75 <= '0';
		elsif CLK13_5'event and CLK13_5 = '1' then
			CLK6_75 <= not CLK6_75;
		end if;
	end process;
		
	
------------------------------------------------------------------------------------------------------------
-- LCD Signal (320 x 240 samsung 3.5 TFT LCD)
------------------------------------------------------------------------------------------------------------
	process(CLK6_75,rst)
	begin
		if rst = '0' then
			M_HS_cnt <= 0;
				M_HS <= '0';
		elsif CLK6_75'event and CLK6_75 = '1' then
			if M_HS_cnt = 359 then
				M_HS_cnt <= 0;
				M_HS <= '0';
			else
				M_HS_cnt <= M_HS_cnt + 1;
				M_HS <= '1';
			end if;
		end if;
	end process;
	
	process(M_HS,rst)
	begin
		if rst = '0' then
			M_VS_cnt <= 0;
		elsif M_HS'event and M_HS = '0' then
			if M_VS_cnt = 254 then
				M_VS_cnt <= 0;
			else
				M_VS_cnt <= M_VS_cnt + 1;
			end if;
		end if;
	end process;
	
HS <= '0' when (M_HS_cnt < 9) else '1';
VS <= '0' when (M_VS_cnt < 1) else '1';

	process(CLK6_75,HS)
	begin
		if HS = '0' then
			P_CNT <= 0;
		elsif CLK6_75'event and CLK6_75 = '1' then
			P_CNT <= P_CNT + 1;
		end if;
	end process;
	
	process(VS,HS)
	begin
		if VS = '0' then
			H_CNT <= 0;
		elsif HS'event and HS = '0' then
			H_CNT <= H_CNT + 1;
		end if;
	end process;
	
									
------------------------------------------------------------------------------------------------------------
-- Progressive Part
------------------------------------------------------------------------------------------------------------
	process(CLK13_5,P_HS)																											
	begin
		if(P_HS = '0')then
			P_PCNT <= (others => '0');
		elsif (CLK13_5'event and CLK13_5 = '1')then
			P_PCNT <= P_PCNT + '1';
		end if;
	end process;

	process(P_VS,P_HS)																										   				 
	begin																		
		if(P_VS = '0')then
			P_HCNT <= (others => '0');														
		elsif (P_HS'event and P_HS = '0')then
			P_HCNT <= P_HCNT + '1';
		end if;
	end process;
	
	process(P_VS,RST)
	begin
		if RST = '0' then
			int_cnt <= 0;
			int <= '1';
		elsif P_VS'event and P_VS = '1' then
			if int_cnt > 2 then
				int_cnt <= int_cnt;
				int <= '0';
			else
				int_cnt <= int_cnt + 1;
				int <= '1';
			end if;
		end if;
	end process;
	
	process(CLK13_5,RST)
	begin
		if RST = '0' then
			int_add <= (others => '0');
		elsif CLK13_5'event and CLK13_5 = '1' then
			if int_add = "10010110011001000" then
				int_add <= (others => '0');
			else
				int_add <= int_add + 1;
			end if;
		end if;
	end process;
		
	nOE			<= CLK27 OR CLK13_5;--'1' when int = '1' else CLK27 when CLK13_5 = '0' else '1';
	P_nWR 		<= CLK27 OR NOT CLK13_5 WHEN (P_VS = '1' AND P_HS = '1') ELSE '1';--'0' when int = '1' else CLK27 when CLK13_5 = '1' else '1';
	P_WR_ADD	<= ((P_HCNT(9 downto 1))* "101000000") + (P_PCNT(9 downto 1));--int_add when int = '1' else ((P_HCNT(9 downto 1))* "101000000") + (P_PCNT(9 downto 1));
	P_RGB565	<= P_R(7 downto 3) & P_G(7 downto 2) & P_B(7 downto 3);--"0000000000000000" when int = '1' else P_R(7 downto 3) & P_G(7 downto 2) & P_B(7 downto 3); 


--		P_RGB565 <=	"0000000000000001" when (P_HCNT(9 downto 1) <10+20) else
--				 	"0000000000000010" when (P_HCNT(9 downto 1) >=  10+20)AND(P_HCNT(9 downto 1) < 20+20) else
--				 	"0000000000000100" when (P_HCNT(9 downto 1) >=  20+20)AND(P_HCNT(9 downto 1) < 30+20) else
--					"0000000000001000" when (P_HCNT(9 downto 1) >=  30+20)AND(P_HCNT(9 downto 1) < 40+20) else
--					"0000000000010000" when (P_HCNT(9 downto 1) >=  40+20)AND(P_HCNT(9 downto 1) < 50+20) else
--					"0000000000100000" when (P_HCNT(9 downto 1) >=  50+20)AND(P_HCNT(9 downto 1) < 60+20) else
--				 	"0000000001000000" when (P_HCNT(9 downto 1) >=  60+20)AND(P_HCNT(9 downto 1) < 70+20) else
--					"0000000010000000" when (P_HCNT(9 downto 1) >=  70+20)AND(P_HCNT(9 downto 1) < 80+20) else
--					"0000000100000000" when (P_HCNT(9 downto 1) >=  80+20)AND(P_HCNT(9 downto 1) < 90+20) else
--					"0000001000000000" when (P_HCNT(9 downto 1) >=  90+20)AND(P_HCNT(9 downto 1) < 100+20) else
--				 	"0000010000000000" when (P_HCNT(9 downto 1) >=  100+20)AND(P_HCNT(9 downto 1) < 110+20) else
--					"0000100000000000" when (P_HCNT(9 downto 1) >=  110+20)AND(P_HCNT(9 downto 1) < 120+20) else
--					"0001000000000000" when (P_HCNT(9 downto 1) >=  120+20)AND(P_HCNT(9 downto 1) < 130+20) else
--					"0010000000000000" when (P_HCNT(9 downto 1) >=  130+20)AND(P_HCNT(9 downto 1) < 140+20) else
--				 	"0100000000000000" when (P_HCNT(9 downto 1) >=  140+20)AND(P_HCNT(9 downto 1) < 150+20) else
--					"1000000000000000";
										
end a;