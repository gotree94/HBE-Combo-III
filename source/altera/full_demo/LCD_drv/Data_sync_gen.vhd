library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
------------------------------------------------------------------------------------------------------------------------
-- input data synchronization
entity Data_sync_gen is  
port(
		CLK130M			: in std_logic;									-- 130M Camera clock (54Mhz)
		CLKCVBS			: in std_logic;									-- CVBS Clock (27Mhz)
		HS_130M			: in std_logic;									-- 130M Camera Hsync
		VS_130M			: in std_logic;									-- 130M Camera Vsync
		HS_dly			: out std_logic;								-- Hsync delay
		VS_dly			: out std_logic;								-- Vsync delay					
		CNT130M			: out integer range 0 to 2047;					-- Write Address
		CNTCVBS			: out integer range 0 to 2047					-- Read Address
				
	);
	
end Data_sync_gen;

architecture a of Data_sync_gen is

signal cnt1 : integer range 0 to 2047;
signal cnt2 : integer range 0 to 2047; 
signal hs,hs_1,hs_2	: std_logic;
signal vs,vs_1,vs_2	: std_logic;


begin
	process(CLK130M,HS_130M)							--Write Address
	begin
		if HS_130M = '0' then
			cnt1 <= 0;
		elsif CLK130M'event and CLK130M = '1' then
			cnt1 <= cnt1 + 1;
		end if;
	end process;
	
	CNT130M <= cnt1;
	
	process(CLKCVBS,hs)									--Read Address
	begin
		if hs = '0' then
			cnt2 <= 0;
		elsif CLKCVBS'event and CLKCVBS = '1' then
			cnt2 <= cnt2 + 1;
		end if;
	end process;
	
	CNTCVBS <= cnt2;

	process(CLKCVBS)
	begin
		if CLKCVBS'event and CLKCVBS = '1' then
			hs 		<= HS_130M;
			hs_1	<= hs;
			hs_2	<= hs_1;
			vs		<= VS_130M;
			vs_1	<= vs;
			vs_2	<= vs_1;
		end if;
	end process;
	
	HS_dly	<= hs_2;
	VS_dly	<= vs_2;
		
	end a;