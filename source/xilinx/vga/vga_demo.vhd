library ieee;
use ieee.std_logic_1164.all;

entity vga_demo is
port(
	clk		: in std_logic;   -- 50mhz
	reset	: in std_logic;
	
	red		: out std_logic_vector(7 downto 0);
	green	: out std_logic_vector(7 downto 0);
	blue	: out std_logic_vector(7 downto 0);
	line	: out std_logic_vector(9 downto 0);
	colum	: out std_logic_vector(9 downto 0);
	m1		: out std_logic;
	m2		: out std_logic;
	blankn	: out std_logic;
	syncn	: out std_logic;
	synct	: out std_logic;
	vclk	: out std_logic;
	vsync	: out std_logic;
	hsync	: out std_logic);
end vga_demo;

architecture hb of vga_demo is

component vga_data
port(
	line	: in std_logic_vector(9 downto 0);
	colume	: in std_logic_vector(9 downto 0);
	
	rgb_data: out std_logic_vector(23 downto 0));
end component;

component interface_vga
port(
	reset	: in std_logic;
	clk		: in std_logic;
	rgb		: in std_logic_vector(23 downto 0);
	
	red		: out std_logic_vector(7 downto 0);
	green	: out std_logic_vector(7 downto 0);
	blue	: out std_logic_vector(7 downto 0);
	line_pix  : out std_logic_vector(9 downto 0);
	colum_pix : out std_logic_vector(9 downto 0);
	m1		: out std_logic;
	m2		: out std_logic;
	blank_n	: out std_logic;
	sync_n	: out std_logic;
	sync_t	: out std_logic;
	video_clk : out std_logic;
	vga_vs	: out std_logic;
	vga_hs	: out std_logic);
end component;

signal line_data	: std_logic_vector(9 downto 0);
signal colum_data	: std_logic_vector(9 downto 0);
signal line_d		: std_logic_vector(9 downto 0);
signal colum_d		: std_logic_vector(9 downto 0);
signal rgb_data		: std_logic_vector(23 downto 0);

signal clk_25m		: std_logic;

begin

process(clk)
begin
if clk'event and clk = '1' then
	clk_25m <= not clk_25m;
end if;
end process;

line_data <= line_d;
line <= line_d;
colum_data <= colum_d;
colum <= colum_d;

data_con	: vga_data
port map(
	line => line_data,
	colume => colum_data,
	rgb_data => rgb_data);

interface : interface_vga
port map(
	reset => reset,
	clk => clk_25m,
	rgb => rgb_data,
	red => red,
	green => green,
	blue => blue,
	line_pix => line_d,
	colum_pix => colum_d,
	m1 => m1,
	m2 => m2,
	blank_n => blankn,
	sync_n => syncn,
	sync_t => synct,
	video_clk => vclk,
	vga_vs => vsync,
	vga_hs => hsync);
	
end hb;

