library ieee;
use ieee.std_logic_1164.all;

entity diptoseg is
port(
	dip_sw	: in std_logic_vector(3 downto 0);
	seg_d	: out std_logic_vector(7 downto 0));
end diptoseg;

architecture a of diptoseg is

begin

process(dip_sw)
begin
case dip_sw is
	when "0000" => seg_d <= "11111100";
	when "0001" => seg_d <= "01100000";
	when "0010" => seg_d <= "11011010";
	when "0011" => seg_d <= "11110010";
	when "0100" => seg_d <= "01100110";
	when "0101" => seg_d <= "10110110";
	when "0110" => seg_d <= "10111110";
	when "0111" => seg_d <= "11100000";
	when "1000" => seg_d <= "11111110";
	when "1001" => seg_d <= "11100110";
	when "1010" => seg_d <= "11101110";
	when "1011" => seg_d <= "00111110";
	when "1100" => seg_d <= "10011100";
	when "1101" => seg_d <= "01111010";
	when "1110" => seg_d <= "10011110";
	when "1111" => seg_d <= "10001110";
	when others => seg_d <= "11111100";
end case;
end process;
end a;