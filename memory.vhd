-- ra: address to be read (converted to unsigned int)
-- wa: address to write, we: write pin (0 or 1) 
-- data: stuff to be written

library work;
use work.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
   port
		(
			clk, write_enable : in std_logic;
			data, write_addr, read_addr : in std_logic_vector (15 downto 0);
			o : out std_logic_vector (15 downto 0)
		);
end entity;

architecture memory_arch of memory is
   type hexbitmem is array (0 to 2**10-1) of std_logic_vector(15 downto 0); 
   signal memory_block : hexbitmem := (others => (others => '0')); 

begin
   process (clk)
   begin
      if rising_edge(clk) then
         if (write_enable = '1') then
            memory_block (to_integer(unsigned(write_addr))) <= data;
         end if;
         
			o <= memory_block (to_integer(unsigned(read_addr)));
      end if;
	end process;
end architecture; 