LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY id_chk_s IS
	PORT(

			ID_CLK	: in std_logic;
			ID_OE	: in std_logic;
			ID_IN	: in std_logic;
			ID_OUT	: inout std_logic;
			cnt		: out std_logic_vector(3 downto 0)					
		);
			
END id_chk_s;


ARCHITECTURE hb OF id_chk_s IS

signal id_cnt	: std_logic_vector(3 downto 0);
signal idout	: std_logic;
signal id		: std_logic_vector(4 downto 0);
constant ID_value		: std_logic_vector(4 downto 0):= "00011";

begin
	
	process(ID_CLK,ID_OE)
	begin
		if ID_CLK'event and ID_CLK = '1' then
			if ID_OE = '0' then
				id_cnt <= "0000";
			else
				id_cnt <= id_cnt + 1;
			end if;
		end if;
	end process;

	process(id_cnt,ID_CLK)
	begin
		if ID_CLK'event and ID_CLK = '0' then
			if ID_OE = '0' then
				id <= "00000";
			elsif id_cnt = "0000" then
				id(0) <= ID_IN;
			elsif id_cnt = "0001" then
				id(1) <= ID_IN;
			elsif id_cnt = "0010" then
				id(2) <= ID_IN;
			elsif id_cnt = "0011" then
				id(3) <= ID_IN;
			elsif id_cnt = "0100" then
				id(4) <= ID_IN;	
			end if;
		end if;
	end process;
	
idout <= '1' when id_cnt >= 5 and id =	ID_value else '0';

id_out <= '1' when idout = '1' else 'Z';
cnt <= id_cnt;
end hb;