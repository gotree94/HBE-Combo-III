library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity audio_output is
port (
	resetn : in std_logic;
	
	codec_din : out std_logic;
	codec_lrcin : in std_logic;
	codec_bclk : in std_logic;
	
	audio_dout : in std_logic_vector(31 downto 0)
);
end audio_output;

architecture a of audio_output is

signal dout_buff : std_logic_vector(31 downto 0);
signal dout_en : std_logic;
signal dout_cnt : integer range 31 downto 0;

begin

process (resetn, codec_bclk)
begin
if resetn = '0' then
	dout_buff <= (others => '0');
elsif codec_bclk'event and codec_bclk = '1' then
	if codec_lrcin = '1' then
		dout_buff <= audio_dout;
	elsif dout_en = '1' then
		dout_buff <= dout_buff(30 downto 0) & '0';
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	codec_din <= '0';
elsif codec_bclk'event and codec_bclk = '0' then
	codec_din <= dout_buff(31);
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	dout_en <= '0';
elsif codec_bclk'event and codec_bclk = '1' then
	if codec_lrcin = '1' then
		dout_en <= '1';
	elsif dout_cnt = 31 then
		dout_en <= '0';
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	dout_cnt <= 0;
elsif codec_bclk'event and codec_bclk = '1' then
	if dout_en = '1' then
		if dout_cnt = 31 then
			dout_cnt <= 0;
		else
			dout_cnt <= dout_cnt + 1;
		end if;
	else
		dout_cnt <= 0;
	end if;
end if;
end process;



end a;

