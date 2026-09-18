library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
-----------------------------------------------------------------------------------------------------------
--- 640 * 480 LCD Drive
entity LCD_drv is
port(

		nOE			: in std_logic;												-- SRAM Read Enable
		P_CNT		: in std_logic_vector(9 downto 0);							-- Pixel counter (1 horizontal Line)
		H_CNT		: in std_logic_vector(8 downto 0);							-- Horizontal counter (1 vertical Line)
		
		HS			: in std_logic;												-- Horizontal sync
		VS			: in std_logic;												-- Vetical sync
		SRAM2_DATA	: in std_logic_vector(15 downto 0);

		-----LCD DRIVER
		LHS			: out std_logic;
		LVS			: out std_logic;												
		LBIAS		: out std_logic;
		RD2_add		: out std_logic_vector(17 downto 0);						-- SRAM2 READ address
		HOST_DATA	: out std_logic_vector(15 downto 0);
		SRAM_nOE	: buffer std_logic
			
	);
	
end LCD_drv;

architecture a of LCD_drv is 

signal rd_add_temp2	: std_logic_vector(17 downto 0);
signal data_temp2 	: std_logic_vector(15 downto 0);


begin

	LVS <= VS;
	LHS <= HS;
------------------------------------------------------------------------------------------------------------
-- LCD DATA Enable
------------------------------------------------------------------------------------------------------------	
	LBIAS <= '1' when (P_CNT >= 20 and P_CNT <= 339)and( H_CNT >= 7 and H_CNT <= 246) else '0'; 
	SRAM_nOE <= nOE;

------------------------------------------------------------------------------------------------------------
--SRAM Read Address
------------------------------------------------------------------------------------------------------------
	RD2_add <= ((((H_CNT - 7)) * "101000000") + (P_CNT - 20));       
		
------------------------------------------------------------------------------------------------------------
-- Video Data output
------------------------------------------------------------------------------------------------------------

--	process(SRAM_nOE)
--	begin
--		if (SRAM_nOE'event and SRAM_nOE = '1')then
--			data_temp2 <= SRAM2_DATA;
--		end if;
--	end process;

	process(SRAM_nOE)
	begin
		if (SRAM_nOE'event and SRAM_nOE = '1')then
			if (P_CNT >= 24 and P_CNT <= 336)and( H_CNT >= 8 and H_CNT <= 242) then
				data_temp2 <= SRAM2_DATA;
			else
				data_temp2 <= (others => '0');
			end if;
		end if;
	end process;

	HOST_DATA <= data_temp2;-- when (P_CNT < 10) else data_temp2;
			--	 "0000000000000000"
--	HOST_DATA <=	"0000000000000001" when (H_CNT <10+20) else
--				 	"0000000000000010" when (H_CNT >=  10+20)AND(H_CNT < 20+20) else
--				 	"0000000000000100" when (H_CNT >=  20+20)AND(H_CNT < 30+20) else
--					"0000000000001000" when (H_CNT >=  30+20)AND(H_CNT < 40+20) else
--					"0000000000010000" when (H_CNT >=  40+20)AND(H_CNT < 50+20) else
--					"0000000000100000" when (H_CNT >=  50+20)AND(H_CNT < 60+20) else
--				 	"0000000001000000" when (H_CNT >=  60+20)AND(H_CNT < 70+20) else
--					"0000000010000000" when (H_CNT >=  70+20)AND(H_CNT < 80+20) else
--					"0000000100000000" when (H_CNT >=  80+20)AND(H_CNT < 90+20) else
--					"0000001000000000" when (H_CNT >=  90+20)AND(H_CNT < 100+20) else
--				 	"0000010000000000" when (H_CNT >=  100+20)AND(H_CNT < 110+20) else
--					"0000100000000000" when (H_CNT >=  110+20)AND(H_CNT < 120+20) else
--					"0001000000000000" when (H_CNT >=  120+20)AND(H_CNT < 130+20) else
--					"0010000000000000" when (H_CNT >=  130+20)AND(H_CNT < 140+20) else
--				 	"0100000000000000" when (H_CNT >=  140+20)AND(H_CNT < 150+20) else
--					"1000000000000000";
---------------------------------------------------------------------------------------------------------------------	
end a;