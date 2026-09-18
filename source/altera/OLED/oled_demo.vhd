library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity oled_demo is
port (
	reset : in std_logic;
	clk_50MHz : in std_logic;
	
	oled_cs : out std_logic;
	oled_rstn : out std_logic;
	oled_dc : out std_logic;
	oled_wn : out std_logic;
	oled_rn : out std_logic;
	oled_d : out std_logic_vector(7 downto 0)
);
end oled_demo;

architecture a of oled_demo is

type ar_init_data is array (0 to 37) of std_logic_vector(8 downto 0);
signal init_data : ar_init_data;
 
signal start_cnt : std_logic_vector(7 downto 0);

signal oled_data : std_logic_vector(7 downto 0);

signal cnt_set_reg : integer range 0 to 4;
signal cnt_init_data : integer range 0 to 37;

signal cnt_ram_data : std_logic_vector(19 downto 0);
signal cnt_ram_cycle : std_logic_vector(15 downto 0);

type command_state is (idle, initial, wr_ram);
signal oled_routine : command_state;

signal reg_oled_data : std_logic_vector(15 downto 0);
signal resetn : std_logic;
signal cnt_ram_datan : std_logic_vector(13 downto 0);

signal clk : std_logic;
signal clk_cnt	: integer range 0 to 24;

component oled_rom_data 
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

begin

init_data(0)  <= "0" & x"AE"; -- display off 0xAE
init_data(1)  <= "0" & x"CA"; -- set mux ratio 0xCA
init_data(2)  <= "1" & x"7F"; -- 1/128 duty 0x7F
init_data(3)  <= "0" & x"A1"; -- display start line 0xA1
init_data(4)  <= "1" & x"00"; -- 0x00
init_data(5)  <= "0" & x"A2"; -- display offset 0xA2
init_data(6)  <= "1" & x"80"; -- 0x80
init_data(7)  <= "0" & x"A0"; -- set re_map -- 0xA0
init_data(8)  <= "1" & x"74"; -- 0x34 256 color, 0x74 64k color
init_data(9)  <= "0" & x"C7"; -- master current control 0xC7
init_data(10) <= "1" & x"06"; -- 0x06
init_data(11) <= "0" & x"C1"; -- set contrast level for R,G,B 0xC1
init_data(12) <= "1" & x"6F"; -- red contrast set 0x6F
init_data(13) <= "1" & x"5F"; -- green contrast set 0x5F
init_data(14) <= "1" & x"9F"; -- blue contrast set 0x9F
init_data(15) <= "0" & x"B1"; -- phase adjust 0xB1
init_data(16) <= "1" & x"24"; -- 0x24
init_data(17) <= "0" & x"B3"; -- set frame rate 0xB3
init_data(18) <= "1" & x"10"; -- 85Hz 0x10
init_data(19) <= "0" & x"BB"; -- set pre-charge level for R,G,B 0xBB
init_data(20) <= "1" & x"00"; -- red 0x00
init_data(21) <= "1" & x"00"; -- green 0x00
init_data(22) <= "1" & x"00"; -- blue 0x00
init_data(23) <= "0" & x"AD"; -- master configuration 0xAD
init_data(24) <= "1" & x"8E"; -- 0x8E
init_data(25) <= "0" & x"B0"; -- current saving 0xB0
init_data(26) <= "1" & x"00"; -- 0x00
init_data(27) <= "0" & x"BE"; -- VCOMH setting 0xBE
init_data(28) <= "1" & x"1C"; -- 0x1C
init_data(29) <= "0" & x"A6"; -- inverse display mode off 0xA6
init_data(30) <= "0" & x"AF"; -- display on 0xAF
init_data(31) <= "0" & x"15"; -- set column address 0x15
init_data(32) <= "1" & x"00"; -- 0x00
init_data(33) <= "1" & x"7F"; -- 0x7F
init_data(34) <= "0" & x"75"; -- set row address 0x75
init_data(35) <= "1" & x"00"; -- 0x00
init_data(36) <= "1" & x"7F"; -- 0x7F
init_data(37) <= "0" & x"5C"; -- write RAM command 0x5C
oled_rn <= '1';

resetn <= not reset;

oled_rstn <= '1';

process(resetn, clk_50MHz)
begin
if resetn = '0' then
	clk <= '0';
elsif clk_50MHz'event and clk_50MHz = '1' then
	if clk_cnt = 24 then
		clk <= not clk;
		clk_cnt <= 0;
	else
		clk <= clk;
		clk_cnt <= clk_cnt + 1;
	end if;
end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		start_cnt <= (others => '0');
	elsif clk'event and clk = '1' then
		if oled_routine = idle then
			if start_cnt = "11111111" then
				start_cnt <= (others => '0');
			else
				start_cnt <= start_cnt + 1;
			end if;
		else
			start_cnt <= (others => '0');
		end if;
	end if;
end process;


process (resetn, clk)
begin
	if resetn = '0' then
		cnt_set_reg <= 0;
	elsif clk'event and clk = '1' then
		if oled_routine = idle then
			cnt_set_reg <= 0;
		elsif cnt_set_reg = 4 then
			cnt_set_reg <= 0;
		else
			cnt_set_reg <= cnt_set_reg + 1;
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_init_data <= 0;
	elsif clk'event and clk = '1' then
		if oled_routine = initial then
			if cnt_set_reg = 4 then
				if cnt_init_data = 37 then
					cnt_init_data <= 0;
				else
					cnt_init_data <= cnt_init_data + 1;
				end if;
			end if;
		else
			cnt_init_data <= 0;
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_ram_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if oled_routine = wr_ram then
			if cnt_set_reg = 4 then
				if cnt_ram_data = x"FFFFF" then
					cnt_ram_data <= (others => '0');
				else
					cnt_ram_data <= cnt_ram_data + 1;
				end if;
			end if;
		else
			cnt_ram_data <= (others => '0');
		end if;
	end if;
end process;

--	process (resetn, clk)
--	begin
--		if resetn = '0' then
--			cnt_ram_cycle <= (others => '0');
--		elsif clk'event and clk = '1' then
--			if oled_routine = wr_ram then
--				if cnt_set_reg = 4 then
--					if cnt_ram_data = 16383 then
--						if cnt_ram_cycle = "1111111111111111" then
--							cnt_ram_cycle <= (others => '0');
--						else
--							cnt_ram_cycle <= cnt_ram_cycle + 1;
--						end if;
--					end if;
--				end if;
--			else
--				cnt_ram_cycle <= (others => '0');
--			end if;
--		end if;
--	end process;


process (resetn, clk)
begin
	if resetn = '0' then
		oled_routine <= idle;
	elsif clk'event and clk = '1' then
		case oled_routine is
			when idle =>
				if start_cnt = "11111111" then
					oled_routine <= initial;
				end if;
			when initial =>
				if cnt_init_data = 37 then
					if cnt_set_reg = 4 then
						oled_routine <= wr_ram;
					end if;
				end if;
			when wr_ram =>
				oled_routine <= wr_ram;
			when others =>
				null;
		end case;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		oled_cs <= '1';
	elsif clk'event and clk = '1' then
		if oled_routine = idle then
			oled_cs <= '1';
		elsif cnt_set_reg >= 1 and cnt_set_reg <= 3 then
			oled_cs <= '0';
		else
			oled_cs <= '1';
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		oled_wn <= '1';
	elsif clk'event and clk = '1' then
		if oled_routine = idle then
			oled_wn <= '1';
		elsif cnt_set_reg = 2 then
			oled_wn <= '0';
		else
			oled_wn <= '1';
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		oled_dc <= '0';
	elsif clk'event and clk = '1' then
		if oled_routine = initial then
			oled_dc <= init_data(cnt_init_data)(8);
		else
			oled_dc <= '1';
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		oled_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if oled_routine = initial then
			oled_data <= init_data(cnt_init_data)(7 downto 0);
		elsif oled_routine = wr_ram then
			if cnt_ram_data(0) = '0' then
				oled_data <= reg_oled_data(15 downto 8);
			else
				oled_data <= reg_oled_data(7 downto 0);
			end if;
	
--			oled_data <= reg_oled_data(15 downto 13) & reg_oled_data(10 downto 8) & reg_oled_data(4 downto 3);
--			oled_data <= cnt_ram_cycle(9 downto 2);

		else
			oled_data <= (others =>'0');
		end if;
	end if;
end process;

oled_d <= oled_data;

oled_data_inst : oled_rom_data
PORT MAP (
		address	 => cnt_ram_data(19) & cnt_ram_data(14 downto 1),
		clock	 => clk,
		q	 => reg_oled_data
	);

end a;
