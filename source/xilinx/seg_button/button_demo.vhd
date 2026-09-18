library ieee;
use ieee.std_logic_1164.all;

entity button_demo is
port(
	clk			: in std_logic;
	button_sw	: in std_logic_vector(15 downto 0);
	
	seg_data	: out std_logic_vector(7 downto 0));
end button_demo;

architecture hb of button_demo is

signal button_data : integer range 0 to 16;

begin

process(clk)
begin
if clk'event and clk = '1' then
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
end if;
end process;

process(clk)
begin
if clk'event and clk = '1' then
	case button_data is
		when 0 =>
			seg_data <= "11111100";
		when 1 =>
			seg_data <= "01100000";
		when 2 =>
			seg_data <= "11011010";
		when 3 =>
			seg_data <= "11110010";
		when 4 =>
			seg_data <= "01100110";
		when 5 =>
			seg_data <= "10110110";
		when 6 =>
			seg_data <= "10111110";
		when 7 =>
			seg_data <= "11100000";
		when 8 =>
			seg_data <= "11111110";
		when 9 =>
			seg_data <= "11100110";
		when 10 =>
			seg_data <= "11101110";
		when 11 =>
			seg_data <= "00111110";
		when 12 =>
			seg_data <= "10011100";
		when 13 =>
			seg_data <= "01111010";
		when 14 =>
			seg_data <= "10011110";
		when 15 =>
			seg_data <= "10001110";
		when 16 =>
			seg_data <= "00000000";
		when others =>
			seg_data <= "00000000";
	end case;
end if;
end process;

end hb;