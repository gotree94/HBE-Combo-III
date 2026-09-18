library ieee;
use ieee.std_logic_1164.all;

entity decod is
	port(
		bcd : in integer range 0 to 15;
		dot : in std_logic;
		seg_data : out std_logic_vector(7 downto 0)
		);
end decod;

architecture gk of decod is

signal seg_d : std_logic_vector(6 downto 0);

begin

process(bcd)
begin
	case bcd is
		when 0 => seg_d <= "1111110";
		when 1 => seg_d <= "0110000";
		when 2 => seg_d <= "1101101";
		when 3 => seg_d <= "1111001";
		when 4 => seg_d <= "0110011";
		when 5 => seg_d <= "1011011";
		when 6 => seg_d <= "1011111";
		when 7 => seg_d <= "1110000";
		when 8 => seg_d <= "1111111";
		when 9 => seg_d <= "1110011";
		when others => seg_d <= "0000000";
	end case;
	seg_data <= seg_d & dot;
end process;

end gk;

		
		








