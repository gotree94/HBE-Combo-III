LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

ENTITY CIF_int IS
	PORT(

			VCLK		: in std_logic;
			nreset		: in std_logic;
			CIF_FSYNC	: in std_logic;
			cif_irq		: out std_logic					
		);
			
END CIF_int;


ARCHITECTURE hb OF CIF_int IS
signal cnt : std_logic_vector(7 downto 0);

begin

	process(nreset,CIF_FSYNC)
	begin
		if nreset = '0' then
			cif_irq <= '0';
		elsif CIF_FSYNC = '1' then
			cif_irq <= '1';
		end if;
	end process;
	
end hb;

