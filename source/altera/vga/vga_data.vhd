library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_data is
	port(
		line		: in std_logic_vector(9 downto 0);
		colume		: in std_logic_vector(9 downto 0);
		
		rgb_data	: out std_logic_vector(23 downto 0)
	);
end vga_data;

architecture data of vga_data is
begin

process(line, colume)
begin

	if line < 160 then
		rgb_data(23 downto 16)	<= not colume(8 downto 1);
		rgb_data(15 downto 8) 	<= (others => '0');
		rgb_data(7 downto 0) 	<= (others => '0');
	elsif line < 320 then
		rgb_data(23 downto 16) 	<= (others => '0');
		rgb_data(15 downto 8) 	<= colume(8 downto 1);
		rgb_data(7 downto 0) 	<= (others => '0');
	elsif line < 480 then
		rgb_data(23 downto 16) 	<= (others => '0');
		rgb_data(15 downto 8) 	<= (others => '0');
		rgb_data(7 downto 0) 	<= not colume(8 downto 1);
	end if;

end process;


end data;
