LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY buff_in IS
  PORT(
    sel			: in std_logic;
	CIF_pclk		: in std_logic;	
	CIF_lclk		: in std_logic;
	CIF_fclk		: in std_logic;
	CIF_V_DATA		: in std_logic_vector(7 downto 0);
	
	CMOS_pclk		: in std_logic;	
	CMOS_lclk		: in std_logic;
	CMOS_fclk		: in std_logic;
	CMOS_V_DATA		: in std_logic_vector(7 downto 0);	
	
	pclk	: out std_logic;	
	lclk	: out std_logic;
	fclk	: out std_logic;
	V_DATA	: out std_logic_vector(7 downto 0)
	  

    );
END buff_in;


ARCHITECTURE hb OF buff_in IS

--signal ch_sel : std_logic;


BEGIN

--	process(sel)
--	begin
--		if sel'event and sel = '1' then
--			ch_sel <= not ch_sel;
--		end if;
--	end process;

	process(sel,CMOS_pclk,CMOS_lclk,CMOS_fclk,CMOS_V_DATA,CIF_pclk,CIF_lclk,CIF_fclk,CIF_V_DATA)
	begin
--		if ch_sel = '1' then
		if sel = '1' then
			pclk	<= CMOS_pclk;	
			lclk	<= CMOS_lclk;
			fclk	<= CMOS_fclk;
			V_DATA	<= CMOS_V_DATA;
		else
			pclk	<= CIF_pclk;	
			lclk	<= CIF_lclk;
			fclk	<= CIF_fclk;
			V_DATA	<= CIF_V_DATA;
		end if;
	end process;
END hb;
