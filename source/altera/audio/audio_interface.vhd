library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity audio_interface	is
port (
	resetn :	in	std_logic;
	clk :	in	std_logic;

	-- 0:2wire, 1:SPI  
	codec_mode : out std_logic;
	-- control port serial data clock
	codec_sclk : out std_logic;
	-- control port input latch/address select
	codec_csn :	out std_logic;
	-- control port serial data input
	codec_sdin : out std_logic;

	-- I2S format serial data input
	codec_din :	out std_logic;
	-- I2S format serial data output
	codec_dout : in std_logic;
	-- I2S DAC-word clock signal
	codec_lrcin	: in	std_logic;
	-- I2S ADC-word clock signal
	codec_lrcout :	in std_logic;
	-- I2S serial-bit clock
	codec_bclk : in std_logic;
	
	audio_din : out std_logic_vector(31 downto 0);
	audio_din_en : out std_logic;
	audio_dout_en : out std_logic;
	audio_dout : in std_logic_vector(31 downto 0)
);
end entity audio_interface;

architecture a of audio_interface is
   
component audio_setup is
port (
	resetn :	in	std_logic;
	clk :	in	std_logic;

	-- 0:2wire, 1:SPI  
	codec_mode : out std_logic;
	-- control port serial data clock
	codec_sclk : out std_logic;
	-- control port input latch/address select
	codec_csn :	out std_logic;
	-- control port serial data input
	codec_sdin : out std_logic
);
end component;

component audio_input is
port (
	resetn : in std_logic;
	
	codec_dout : in std_logic;
	codec_lrcout : in std_logic;
	codec_bclk : in std_logic;
	
	audio_din : out std_logic_vector(31 downto 0);
	audio_din_en : out std_logic
);
end component;

component audio_output is
port (
	resetn : in std_logic;
	
	codec_din : out std_logic;
	codec_lrcin : in std_logic;
	codec_bclk : in std_logic;
	
	audio_dout : in std_logic_vector(31 downto 0)
);
end component;


begin

audio_dout_en <= codec_lrcin;

u0 : audio_setup
port map (
	resetn => resetn,
	clk => clk,
	
	codec_mode => codec_mode,
	codec_sclk => codec_sclk,
	codec_csn => codec_csn,
	codec_sdin => codec_sdin
);

u1 : audio_input 
port map (
	resetn => resetn,
	
	codec_dout => codec_dout,
	codec_lrcout => codec_lrcout,
	codec_bclk => codec_bclk,
	
	audio_din => audio_din,
	audio_din_en => audio_din_en
);

u2 : audio_output
port map (
	resetn => resetn,
	
	codec_din => codec_din,
	codec_lrcin => codec_lrcin,
	codec_bclk => codec_bclk,
	
	audio_dout => audio_dout
);

end architecture a;