library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity audio_input is
port (
	resetn : in std_logic;
	
	codec_dout : in std_logic;
	codec_lrcout : in std_logic;
	codec_bclk : in std_logic;
	
	audio_din : out std_logic_vector(31 downto 0);
	audio_din_en : out std_logic
);
end audio_input;

architecture a of audio_input is

signal din_en : std_logic;
signal din_cnt : integer range 32 downto 0;
signal din_buff : std_logic_vector(31 downto 0);

begin

process (resetn, codec_bclk)
begin
if resetn = '0' then
	din_en <= '0';
elsif codec_bclk'event and codec_bclk = '1' then
	if codec_lrcout = '1' then
		din_en <= '1';
	elsif din_cnt = 32 then
		din_en <= '0';
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	din_cnt <= 0;
elsif codec_bclk'event and codec_bclk = '1' then
	if din_en = '1' then
		if din_cnt = 32 then
			din_cnt <= 0;
		else
			din_cnt <= din_cnt + 1;
		end if;
	else
		din_cnt <= 0;
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	din_buff <= (others => '0');
elsif codec_bclk'event and codec_bclk = '1' then
	if din_en = '1' then
		din_buff <= din_buff(30 downto 0) & codec_dout;
	else
		din_buff <= (others => '0');
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	audio_din <= (others => '0');
elsif codec_bclk'event and codec_bclk = '1' then
	if din_cnt = 32 then
		audio_din <= din_buff(31 downto 0);
	end if;
end if;
end process;

process (resetn, codec_bclk)
begin
if resetn = '0' then
	audio_din_en <= '0';
elsif codec_bclk'event and codec_bclk = '1' then
	if din_cnt = 32 then
		audio_din_en <= '1';
	else
		audio_din_en <= '0';
	end if;
end if;
end process;

end a;
