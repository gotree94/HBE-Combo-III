library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SEL is
port(
		CLK				: in std_logic;
--		Output_sel		: in std_logic;
--		P_VS			: in std_logic;
		
		F_nOE			: in std_logic;
		F_nWE			: in std_logic;
		F_RD_ADD		: in std_logic_vector(17 downto 0);
		F_WR_ADD		: in std_logic_vector(17 downto 0);
		F_VID_IN		: in std_logic_vector(15 downto 0);
		F_hold			: in std_logic;	

--		H_nOE			: in std_logic;
--		H_nWE			: in std_logic;
--		H_RD_ADD		: in std_logic_vector(17 downto 0);
--		H_WR_ADD		: in std_logic_vector(17 downto 0);
--		H_VID_IN		: in std_logic_vector(15 downto 0);
--------------------------------------------------------------------		
		SRAM_hre		: out std_logic;
		SRAM_haddr		: out std_logic_vector(17 downto 0);
		
		SRAM_vwe		: out std_logic;
		SRAM_Vaddr		: out std_logic_vector(17 downto 0);
		
		SRAM_vdin		: out std_logic_vector(15 downto 0);
		
		write_off		: out std_logic
			
	);
	
end SEL;

architecture a of SEL is 

--signal cnt : integer range 0 to 7;
--signal irq : std_logic;

begin

--------------------------------------------------------------
-- host read timing	
--	process(P_VS)
--	begin
--		if P_VS'event and P_VS = '1' then
--			if cnt = 3 then
--				cnt <= 0;
--			else
--				cnt <= cnt + 1;
--			end if;
--		end if;
--	end process;
		
-- irq <= '1' when cnt >= 1 else '0';
		
	process(F_nOE,F_RD_ADD,F_nWE,F_WR_ADD,F_VID_IN,F_hold)--Output_sel,H_nOE,H_RD_ADD,H_nWE,irq,H_WR_ADD,H_VID_IN)
	begin
--		if Output_sel = '0' then
--			SRAM_hre		<= H_nOE;
--			SRAM_haddr		<= H_RD_ADD;
--			SRAM_vwe		<= H_nWE or irq;
--			SRAM_Vaddr		<= H_WR_ADD;
--			SRAM_vdin		<= H_VID_IN;
--			write_off		<= irq;
--		else
			SRAM_hre		<= F_nOE;
			SRAM_haddr		<= F_RD_ADD;
			SRAM_vwe		<= F_nWE;
			SRAM_Vaddr		<= F_WR_ADD;
			SRAM_vdin		<= F_VID_IN;
			write_off		<= F_hold;
--		end if;
	end process;
end A;