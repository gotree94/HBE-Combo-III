library ieee;
use ieee.std_logic_1164.all;

entity button_demo is
port(
	button_sw	: in std_logic_vector(15 downto 0);
	button_data	: out integer range 0 to 16);
end button_demo;

architecture hb of button_demo is

begin

process(button_sw)
begin
	case button_sw is
		when "0000000000000001" => button_data <= 1;
		when "0000000000000010" => button_data <= 2;
		when "0000000000000100" => button_data <= 3;
		when "0000000000001000" => button_data <= 4;
		when "0000000000010000" => button_data <= 5;
		when "0000000000100000" => button_data <= 6;
		when "0000000001000000" => button_data <= 7;
		when "0000000010000000" => button_data <= 8;
		when "0000000100000000" => button_data <= 9;
		when "0000001000000000" => button_data <= 0;
		when "0000010000000000" => button_data <= 10;
		when "0000100000000000" => button_data <= 11;
		when "0001000000000000" => button_data <= 12;
		when "0010000000000000" => button_data <= 13;
		when "0100000000000000" => button_data <= 14;
		when "1000000000000000" => button_data <= 15;
		when others => button_data <= 16;
	end case;
end process;

end hb;