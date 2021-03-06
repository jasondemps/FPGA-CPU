library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.helpers.all;

entity Fetch is
  port(
    clock        : in     std_logic;
    branch_value : in     signed(11 downto 1);
    stall        : in     std_logic;
    im_addr      : buffer unsigned(31 downto 1);
    pc           : buffer unsigned(31 downto 1) := (others => '0')
    );
end Fetch;

architecture Fetch of Fetch is
  signal pc_tmp : unsigned(31 downto 1) := (others => '0');
begin
  -- pc <= pc_tmp;

  --im_addr <= unsigned(signed(pc) + branch_value);
  with stall select im_addr <=
    unsigned(signed(pc) + branch_value) when '0',
    unsigned(signed(pc))                when others;

  --im_addr <= pc_tmp;

  process(clock)
  begin
    if rising_edge(clock) then
      pc <= im_addr;
    --if stall = '0' then
    --  pc_tmp <= unsigned(signed(pc_tmp) + branch_value);
    --end if;
    end if;
  end process;

end Fetch;
