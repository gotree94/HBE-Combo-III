LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY buff IS
  PORT(
--    sel				: in std_logic;
	pclk			: in std_logic;
	disp			: in std_logic;
	lclk			: in std_logic;
	fclk			: in std_logic;
	den				: in std_logic;
	red				: in std_logic_vector(4 downto 0);
	green			: in std_logic_vector(5 downto 0);
	blue			: in std_logic_vector(4 downto 0);
	
	lcd_pclk		: inout std_logic;
	lcd_disp		: inout std_logic;
	lcd_lclk		: inout std_logic;
	lcd_fclk		: inout std_logic;
	lcd_den			: inout std_logic;
	lcd_red			: inout std_logic_vector(7 downto 0);
	lcd_green		: inout std_logic_vector(7 downto 0);
	lcd_blue		: inout std_logic_vector(7 downto 0));
--	LCD_EN			: out std_logic		  
--    );
END buff;


ARCHITECTURE hb OF buff IS

signal ch_sel : std_logic;


BEGIN

--LCD_EN <= ch_sel;

--	process(sel)
--	begin
--		if sel'event and sel = '1' then
--			ch_sel <= not ch_sel;
--		end if;
--	end process;

	process(ch_sel,pclk,disp,lclk,fclk,den,red,green,blue)
	begin
--		if ch_sel = '1' then
			lcd_pclk		<= pclk;
			lcd_disp		<= disp;
			lcd_lclk		<= lclk;
			lcd_fclk		<= fclk;
			lcd_den			<= den;
			lcd_red			<= red & red(4 downto 2);
			lcd_green		<= green & green(5 downto 4);
			lcd_blue		<= blue & blue(4 downto 2);
--			lcd_red			<= "000" & red;
--			lcd_green		<= "00" & green;
--			lcd_blue		<= "000" & blue;
--		else
--			lcd_pclk		<= 'Z';
--			lcd_disp		<= 'Z';
--			lcd_lclk		<= 'Z';
--			lcd_fclk		<= 'Z';
--			lcd_den			<= 'Z';
--			lcd_red			<= (others => 'Z');
--			lcd_green		<= (others => 'Z');
--			lcd_blue		<= (others => 'Z');
--		end if;
	end process;

END hb;
