-- Tyler McGrew
-- ece310L
-- Uart

-- I have what the pins due explaned below. In order for tranmition to happen you
-- need to keep byte out the same for 10/9600 seconds. You want to turn transmit to zero before 
-- time in order for it to not send another byte. As long as you do that it should
-- work but I would give it extra time just in case. 

-- GVGAGD supports all ascii characters along with things like .?@# some of them look better then
-- others. backspace is also avalible, that is either 0x08 or 0x8f because ascii is one way and 
-- keyboards do the other. Tab and return also work but you want to put a space before them or 
-- it displays extra characters (timing problem I havent fixed). Tab is 9 and return is 13.
-- I never actualy talk back to the user so you dont really need to have uart recive working
-- or connected, just transmit.



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
  port(
    clock    : in  std_logic;  -- needs to be clock_50 for timing to be right
    byte_in  : out std_logic_vector(7 downto 0);  -- the byte I just got from user
    byte : in  std_logic_vector(7 downto 0);  -- byte sending to user
    bit_out  : out std_logic;           -- bit to send to user
    bit_in   : in  std_logic;           -- bit from user
    transmit : in  std_logic  -- turn on to transmit then turn off to stop transmition
   -- you need to hold this for a few clock cycles in order for 
   -- thr transmit signal to stick
    );
end uart;

architecture ut of uart is
  signal byte_out    : unsigned(7 downto 0);
  signal timer_trans : unsigned(15 downto 0) := to_unsigned(0, 16);
  signal index_trans : unsigned(3 downto 0)  := to_unsigned(0, 4);
  signal state_trans : std_logic;
  signal output      : std_logic             := '1';

  signal timer_rec : unsigned(15 downto 0) := to_unsigned(0, 16);
  signal index_rec : unsigned(3 downto 0)  := to_unsigned(0, 4);
  signal state     : std_logic;

  signal clock_cycles : unsigned(9 downto 0) := to_unsigned(5208, 10);  -- sets up time between cycles
                                        -- currently set to 9600 baud

begin

  process(clock)
  begin
    if rising_edge(clock) then
      if state_trans = '0' then         -- start
        if transmit = '1' then          -- check for transmit
          state_trans <= '1';
--			 if unsigned(byte) >= 10 then
--				byte_out <= unsigned(byte) + 55;
--			 else
				byte_out <= unsigned(byte); -- + 48;
			--end if;
        else                            -- finish up last transmition then stop
          if timer_trans = clock_cycles then bit_out <= '1';
          else timer_trans                           <= timer_trans + 1; end if;
        end if;
      else
        if timer_trans = clock_cycles then
          if index_trans = 0 then
            output      <= '0';
            index_trans <= to_unsigned(1, 4);
          elsif index_trans = 1 then
            output <= byte_out(0);
            index_trans <= to_unsigned(2, 4);
          elsif index_trans = 2 then
            output <= byte_out(1);
            index_trans <= to_unsigned(3, 4);
          elsif index_trans = 3 then
            output <= byte_out(2);
            index_trans <= to_unsigned(4, 4);
          elsif index_trans = 4 then
            output <= byte_out(3);
            index_trans <= to_unsigned(5, 4);
          elsif index_trans = 5 then
            output <= byte_out(4);
            index_trans <= to_unsigned(6, 4);
          elsif index_trans = 6 then
            output <= byte_out(5);
            index_trans <= to_unsigned(7, 4);
          elsif index_trans = 7 then
            output <= byte_out(6);
            index_trans <= to_unsigned(8, 4);
          elsif index_trans = 8 then
            output <= byte_out(7);
            index_trans <= to_unsigned(9, 4);
          elsif index_trans = 9 then
            output      <= '1';
            index_trans <= to_unsigned(0, 4);
            state_trans <= '0';
          end if;

          bit_out     <= output;
          timer_trans <= to_unsigned(0, 16);
        else timer_trans <= timer_trans + 1;  -- increment timer
        end if;
      end if;
    end if;

  end process;

  process(clock)
  begin
    if rising_edge(clock) then
      if state = '0' then               -- start
        if bit_in = '0' then
          state     <= '1';
          timer_rec <= to_unsigned(1, 16);
          index_rec <= to_unsigned(0, 4);
        end if;
      else                              --if state = '1' then -- rec
        if timer_rec = clock_cycles then

          timer_rec <= to_unsigned(0, 16);  -- reset timer
          if index_rec = 0 then
            index_rec <= to_unsigned(1, 4);
            timer_rec <= to_unsigned(100, 16);
          elsif index_rec = 1 then
            index_rec <= to_unsigned(2, 4);
          elsif index_rec = 2 then
            byte_in(0) <= bit_in;
            index_rec  <= to_unsigned(3, 4);
          elsif index_rec = 3 then
            byte_in(1) <= bit_in;
            index_rec  <= to_unsigned(4, 4);
          elsif index_rec = 4 then
            byte_in(2) <= bit_in;
            index_rec  <= to_unsigned(5, 4);
          elsif index_rec = 5 then
            byte_in(3) <= bit_in;
            index_rec  <= to_unsigned(6, 4);
          elsif index_rec = 6 then
            byte_in(4) <= bit_in;
            index_rec  <= to_unsigned(7, 4);
          elsif index_rec = 7 then
            byte_in(5) <= bit_in;
            index_rec  <= to_unsigned(8, 4);
          elsif index_rec = 8 then
            byte_in(6) <= bit_in;
            index_rec  <= to_unsigned(9, 4);
          elsif index_rec = 9 then
            byte_in(7) <= bit_in;
            state      <= '0';
            index_rec  <= to_unsigned(0, 4);
          else timer_rec <= to_unsigned(0, 16);
          end if;
        else timer_rec <= timer_rec + 1;    -- increment timer
        end if;
      end if;
    end if;
  end process;
end ut;