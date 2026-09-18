library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rs_232 is
	port (
		reset : in std_logic;
		clk : in std_logic;  -- 25MHz input clock
		
		parity_en : in std_logic;
		parity_mode : in std_logic;
		
		rxd : in std_logic;
		txd : out std_logic;
		
		rxd_en : out std_logic;
		txd_en : in std_logic;
		uart_data_in : out std_logic_vector(7 downto 0);
		uart_data_out : in std_logic_vector(7 downto 0)
	);
end rs_232;

architecture a of rs_232 is

signal resetn : std_logic := '0';

constant bit_rate : std_logic_vector(7 downto 0) := "11011001";  -- 25M / 115200 = 217
constant bit_rate_half : std_logic_vector(7 downto 0) := "01101100";  -- 108

type rx_state is (rx_idle, rx_start, data_rx, rx_parity, rx_stop);
signal rx_routine : rx_state;

type tx_state is (tx_idle, tx_start, data_tx, tx_parity, tx_stop);
signal tx_routine : tx_state;

signal rx_bit_add : std_logic_vector(7 downto 0);

signal cnt_rx_bit_rate : std_logic_vector(7 downto 0);
signal cnt_rx_data : std_logic_vector(2 downto 0);
signal cnt_tx_bit_rate : std_logic_vector(7 downto 0);
signal cnt_tx_data : std_logic_vector(2 downto 0);

signal rx_data : std_logic_vector(7 downto 0);
signal tx_data : std_logic_vector(7 downto 0);

signal reg_rxd : std_logic_vector(15 downto 0);

signal tx_parity_chk : std_logic;

begin

resetn <= not reset;

process (resetn, clk)
begin
	if resetn = '0' then
		reg_rxd <= (others => '0');
	elsif clk'event and clk = '1' then
		reg_rxd <= rxd & reg_rxd(15 downto 1);
	end if;
end process;


process (resetn, clk)
begin
	if resetn = '0' then
		rx_bit_add <= (others => '0');
	elsif clk'event and clk = '1' then
		if rx_routine = data_rx then
			if cnt_rx_bit_rate = bit_rate then
				rx_bit_add <= (others => '0');
			else
				rx_bit_add <= rx_bit_add + reg_rxd(0);
			end if;
		else
			rx_bit_add <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		rx_routine <= rx_idle;
	elsif clk'event and clk = '1' then
		case rx_routine is
			when rx_idle => 
				if reg_rxd = "0000000000000000" then
					rx_routine <= rx_start;
				end if;
			when rx_start =>
				if cnt_rx_bit_rate = bit_rate then
					rx_routine <= data_rx;
				elsif cnt_rx_bit_rate = bit_rate_half then
					if reg_rxd(0) = '1' then
						rx_routine <= rx_idle;
					end if;
				end if;
			when data_rx => 
				if cnt_rx_data = "111" then
					if cnt_rx_bit_rate = bit_rate then
						if parity_en = '1' then
							rx_routine <= rx_parity;
						else
							rx_routine <= rx_stop;
						end if;
					end if;
				end if;
			when rx_parity =>
				if cnt_rx_bit_rate = bit_rate then
					rx_routine <= rx_stop;
				end if;
			when rx_stop => 
				if cnt_rx_bit_rate(5 downto 0) = bit_rate(7 downto 2) then
					rx_routine <= rx_idle;
				end if;
		end case;
	end if;
end process;



process (resetn, clk)
begin
	if resetn = '0' then
		cnt_rx_bit_rate <= (others => '0');
	elsif clk'event and clk = '1' then
		if rx_routine = rx_idle then
			cnt_rx_bit_rate <= (others => '0');
		elsif cnt_rx_bit_rate = bit_rate then
			cnt_rx_bit_rate <= (others => '0');
		else
			cnt_rx_bit_rate <= cnt_rx_bit_rate + '1';
		end if;
	end if;
end process;



process (resetn, clk)
begin
	if resetn = '0' then
		cnt_rx_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if rx_routine = data_rx then
			if cnt_rx_bit_rate = bit_rate then
				if cnt_rx_data = "111" then
					cnt_rx_data <= (others => '0');
				else
					cnt_rx_data <= cnt_rx_data + '1';
				end if;
			end if;
		else
			cnt_rx_data <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		rx_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if rx_routine = data_rx then
			if cnt_rx_bit_rate = bit_rate - 1 then
				if rx_bit_add >= bit_rate_half then
					rx_data <= '1' & rx_data(7 downto 1);
				else
					rx_data <= '0' & rx_data(7 downto 1);
				end if;
			end if;
		elsif rx_routine = rx_idle then
			rx_data <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		rxd_en <= '0';
	elsif clk'event and clk = '1' then
		if rx_routine = rx_stop then
			if cnt_rx_bit_rate >=  10 then
				rxd_en <= '1';
			else
				rxd_en <= '0';
			end if;
		else
			rxd_en <= '0';
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		uart_data_in <= (others => '0');
	elsif clk'event and clk = '1' then
		if rx_routine = rx_stop then
			uart_data_in <= rx_data;
		end if;
	end if;
end process;



process (resetn, clk)
begin
	if resetn = '0' then
		tx_routine <= tx_idle;
	elsif clk'event and clk = '1' then
		case tx_routine is
			when tx_idle =>
				if txd_en = '1' then
					tx_routine <= tx_start;
				end if;
			when tx_start => 
				if cnt_tx_bit_rate = bit_rate then
					tx_routine <= data_tx;
				end if;
			when data_tx =>
				if cnt_tx_data = "111" then
					if cnt_tx_bit_rate = bit_rate then
						if parity_en = '1' then
							tx_routine <= tx_parity;
						else
							tx_routine <= tx_stop;
						end if;
					end if;
				end if;
			when tx_parity =>
				if cnt_tx_bit_rate = bit_rate then
					tx_routine <= tx_stop;
				end if;
			when tx_stop => 
				if cnt_tx_bit_rate = bit_rate - 10 then
					tx_routine <= tx_idle;
				end if;
			when others =>
				tx_routine <= tx_idle;
		end case;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_tx_bit_rate <= (others => '0');
	elsif clk'event and clk = '1' then
		if tx_routine = tx_idle then
			cnt_tx_bit_rate <= (others => '0');
		elsif cnt_tx_bit_rate = bit_rate then
			cnt_tx_bit_rate <= (others => '0');
		else
			cnt_tx_bit_rate <= cnt_tx_bit_rate + '1';
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		cnt_tx_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if tx_routine = data_tx then
			if cnt_tx_bit_rate = bit_rate then
				if cnt_tx_data = "111" then
					cnt_tx_data <= (others => '0');
				else
					cnt_tx_data <= cnt_tx_data + '1';
				end if;
			end if;
		else
			cnt_tx_data <= (others => '0');
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		tx_data <= (others => '0');
	elsif clk'event and clk = '1' then
		if tx_routine = tx_idle then
			if txd_en = '1' then
				tx_data <= uart_data_out;
			end if;
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		tx_parity_chk <= '0';
	elsif clk'event and clk = '1' then
		if tx_routine = tx_idle then
			if txd_en = '1' then
				tx_parity_chk <= uart_data_out(7) xor uart_data_out(6) xor 
				                 uart_data_out(5) xor uart_data_out(4) xor 
				                 uart_data_out(3) xor uart_data_out(2) xor
				                 uart_data_out(1) xor uart_data_out(0) xor 
				                 parity_mode;
			end if;
		end if;
	end if;
end process;

process (resetn, clk)
begin
	if resetn = '0' then
		txd <= '1';
	elsif clk'event and clk = '1' then
		case tx_routine is
			when tx_idle =>
				txd <= '1';
			when tx_start =>
				txd <= '0';
			when data_tx =>
				if cnt_tx_data = "000" then
					txd <= tx_data(0);
				elsif cnt_tx_data = "001" then
					txd <= tx_data(1);
				elsif cnt_tx_data = "010" then
					txd <= tx_data(2);
				elsif cnt_tx_data = "011" then
					txd <= tx_data(3);
				elsif cnt_tx_data = "100" then
					txd <= tx_data(4);
				elsif cnt_tx_data = "101" then
					txd <= tx_data(5);
				elsif cnt_tx_data = "110" then
					txd <= tx_data(6);
				elsif cnt_tx_data = "111" then
					txd <= tx_data(7);
				else
					txd <= '1';
				end if;
			when tx_parity =>
				txd <= tx_parity_chk;
			when tx_stop => 
				txd <= '1';
			when others =>
				txd <= '1';
		end case;
	end if;
end process;

end a;