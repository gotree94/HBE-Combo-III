library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity full_demo is
port(
	clk		: in std_logic;			-- 50MHz
	
	button_sw	: in std_logic_vector(15 downto 0);
	dip_sw		: in std_logic_vector(7 downto 0);
	sensor		: in std_logic;
	
	motor_data	: out std_logic_vector(3 downto 0);
	led			: out std_logic_vector(15 downto 0);
	sega_scan	: out std_logic_vector(7 downto 0);
	sega_data	: out std_logic_vector(7 downto 0);
	seg_data	: out std_logic_vector(7 downto 0);
	dot_scan	: out std_logic_vector(9 downto 0);
	dot_data	: out std_logic_vector(13 downto 0);
	reset_out	: out std_logic;
	vfd_e		: out std_logic;
	vfd_rs		: out std_logic;
	vfd_rw		: out std_logic;
	vfd_data	: out std_logic_vector(7 downto 0);
	oled_cs		: out std_logic;
	oled_rstn	: out std_logic;
	oled_dc		: out std_logic;
	oled_wn		: out std_logic;
	oled_rn		: out std_logic;
	oled_d		: out std_logic_vector(7 downto 0)
	);
end full_demo;

architecture hb of full_demo is

component dip_switch
port(	
	dip_sw		: in std_logic_vector(3 downto 0);
	dip_data	: out integer range 0 to 16);
end component;

component bitman
port(
	clk_1MHz : in std_logic;			-- 1MHz
	reset : in std_logic;
	dot_d : out std_logic_vector(13 downto 0);
	dot_scan : out std_logic_vector(9 downto 0));
end component;

component led_demo
port(
	clk		: in std_logic;
	led_data: out std_logic_vector(15 downto 0));
end component;

component button_demo
port(
	button_sw	: in std_logic_vector(15 downto 0);
	button_data	: out integer range 0 to 16);
end component;

component vfd_demo
port(
	clk : in std_logic;			-- 1MHz Clock	
	rst	: in std_logic;
	vfd_e : out std_logic;
	vfd_rs : out std_logic;
	vfd_rw : out std_logic;
	vfd_data : out std_logic_vector(7 downto 0));
end component;

component segment_demo
port(
	clk		: in std_logic;
	s10, s1	: out integer range 0 to 9;
	m10, m1	: out integer range 0 to 9;
	h10, h1 : out integer range 0 to 9); 
end component;

component dec7
port(
	bcd		: in integer range 0 to 16;
	seg		: out std_logic_vector(7 downto 0));
end component;

component oled_demo
port(
	reset 		: in std_logic;
	clk			: in std_logic;
	oled_cs		: out std_logic;
	oled_rstn	: out std_logic;
	oled_dc		: out std_logic;
	oled_wn		: out std_logic;
	oled_rn		: out std_logic;
	oled_d		: out std_logic_vector(7 downto 0));
end component;

component motor
port(
	clk			: in std_logic;
	sensor 		: in std_logic;
	
	motor_data 	: out std_logic_vector(3 downto 0));
end component;

signal s10, s1	: integer range 0 to 9;
signal m10, m1	: integer range 0 to 9;
signal h10, h1	: integer range 0 to 9;
signal num		: integer range 0 to 16;
signal seg_bt	: integer range 0 to 16;
signal dip1, dip2	: std_logic_vector(3 downto 0);
signal seg_dip1	: integer range 0 to 16;
signal seg_dip2	: integer range 0 to 16;
signal seg_cnt	: integer range 0 to 7;
signal button_data : integer range 0 to 16;

signal reset	: std_logic;
signal cnt		: integer range 0 to 499;
signal clk_1khz	: std_logic;


signal cnt_clk	: integer range 0 to 50;

signal cnt_1m	: integer range 0 to 24;
signal clk_1mhz : std_logic;

begin

dip1 <= dip_sw(7 downto 4);
dip2 <= dip_sw(3 downto 0);

mo1 : motor
port map(
	clk => clk_1khz,
	sensor => sensor,
	motor_data => motor_data);

led1 : led_demo
port map(
	clk => clk_1mhz,
	led_data =>	led);

seg : segment_demo
port map(
	clk => clk_1khz,
	s10 => s10,
	s1 => s1,
	m10 => m10,
	m1 => m1,
	h10 => h10,
	h1 => h1);

dec1 : dec7
port map(
	bcd => num,
	seg => sega_data);

dec2 : dec7
port map(
	bcd => button_data,
	seg => seg_data);
	
bt : button_demo
port map(
	button_sw => button_sw,
	button_data => button_data);

dot : bitman
port map(
	clk_1mhz => clk_1mhz,
	reset => reset,
	dot_d => dot_data,
	dot_scan => dot_scan);

vfd : vfd_demo
port map(
	clk => clk_1mhz,
	rst => reset,
	vfd_e => vfd_e,
	vfd_rs => vfd_rs,
	vfd_rw => vfd_rw,
	vfd_data => vfd_data);

dip_1 : dip_switch
port map(
	dip_sw => dip1,
	dip_data => seg_dip1);

dip_2 : dip_switch
port map(
	dip_sw => dip2,
	dip_data => seg_dip2);

oled : oled_demo
port map(
	reset => reset,
	clk => clk_1mhz,
	oled_cs => oled_cs,
	oled_rstn => oled_rstn,
	oled_dc => oled_dc,
	oled_wn => oled_wn,
	oled_rn => oled_rn,
	oled_d => oled_d);
	

process (clk_1mhz)
begin
	if clk_1mhz'event and clk_1mhz = '1' then 
		if cnt_clk = 50 then
			cnt_clk <= cnt_clk;
		else
			cnt_clk <= cnt_clk + 1;
		end if;
	end if;
end process;

reset <= '0' when cnt_clk = 50 else '1';
reset_out <= reset;


process(clk)
begin
if clk'event and clk = '1' then
	if cnt_1m = 24 then
		clk_1mhz <= not clk_1mhz;
		cnt_1m <= 0;
	else
		cnt_1m <= cnt_1m + 1;
		clk_1mhz <= clk_1mhz;
	end if;
end if;
end process;

process(clk_1mhz)
begin
if clk_1mhz'event and clk_1mhz = '1' then
	if cnt = 499 then
		clk_1khz <= not clk_1khz;
		cnt <= 0;
	else
		cnt <= cnt + 1;
		clk_1khz <= clk_1khz;
	end if;
end if;
end process;

process(clk_1khz)
begin
if clk_1khz'event and clk_1khz = '1' then
	if seg_cnt = 7 then
		seg_cnt <= 0;
	else
		seg_cnt <= seg_cnt + 1;
	end if;
end if;
end process;

process(clk_1khz)
begin
if clk_1khz'event and clk_1khz = '1' then
	case seg_cnt is
		when 0 =>
			sega_scan <= "01111111";
			num <= h10;
		when 1 =>
			sega_scan <= "10111111";
			num <= h1;
		when 2 =>
			sega_scan <= "11011111";
			num <= m10;
		when 3 =>
			sega_scan <= "11101111";
			num <= m1;
		when 4 =>
			sega_scan <= "11110111";
			num <= s10;
		when 5 =>
			sega_scan <= "11111011";
			num <= s1;
		when 6 =>
			sega_scan <= "11111101";
			num <= seg_dip1;
		when 7 =>
			sega_scan <= "11111110";
			num <= seg_dip2;
		when others =>
			sega_scan <= "11111111";
	end case;
end if;
end process;

end hb;