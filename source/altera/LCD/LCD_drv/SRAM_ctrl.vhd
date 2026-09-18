library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity sram_ctrl is
port(
	
	sram_hre	: in std_logic;                            -- Host
	sram_haddr	: in std_logic_vector(17 downto 0);
--	sram_hdout 	: out std_logic_vector(15 downto 0);

	sram_vwe	: in std_logic;                            -- Video In
	sram_vaddr	: in std_logic_vector(17 downto 0);
	sram_vdin	: in std_logic_vector(15 downto 0);
		
	sram_re		: out std_logic;
	sram_we		: out std_logic;
	sram_addr	: out std_logic_vector(17 downto 0);

	sram0_dd  	: inout std_logic_vector(15 downto 0);
	sram0_cs 	: out std_logic;
	sram1_ub, sram1_db : out std_logic;
	sram2_ub, sram2_db : out std_logic;
	
	write_off	: in std_logic;								-- '1' : read, '0' : write
	CLK			: in std_logic

	
	);
end sram_ctrl;

architecture behav of sram_ctrl is

signal	sram0_di  	: std_logic_vector(15 downto 0);
signal	sram0_do  	: std_logic_vector(15 downto 0);

begin

process(CLK)
begin
	if CLK'event and CLK = '0' then
		if write_off = '0' then
			sram0_dd  <= (others => 'Z');
			sram_addr <= sram_haddr;
		else 
			sram0_dd  <= sram_vdin(15 downto 0);
			sram_addr <= sram_vaddr;
		end if;
	end if;

end process;
	
--sram_hdout(15 downto 0) <= sram0_dd;
sram_we <= sram_vwe;
sram_re <= sram_hre;
sram1_ub <= '0';
sram1_db <= '0';
sram2_ub <= '0';
sram2_db <= '0';
sram0_cs <= '0';


end behav;			