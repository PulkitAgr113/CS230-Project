-- we: control to write
-- wa: writing address ( 3 bit)
-- ra1, ra2: reading addresses (can read from two places, but write at one in a single clock cycle)
-- o1, o2: outputs

library work;
use work.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg_file is
   port
		(
			clk, write_enable : in std_logic;
			data : in std_logic_vector (15 downto 0);
			write_addr, read_addr_1, read_addr_2 : in std_logic_vector (2 downto 0);
			output1, output2, r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic_vector (15 downto 0)
		);
end entity;

architecture reg_arch OF reg_file is
   type hexbitmem is array (0 to 7) of std_logic_vector(15 downto 0);  
   signal registers : hexbitmem := (others => (others => '0'));

begin
	r0 <= registers(0);
	r1 <= registers(1);
	r2 <= registers(2);
	r3 <= registers(3);
	r4 <= registers(4);
	r5 <= registers(5);
	r6 <= registers(6);
	r7 <= registers(7);
	
	output1 <= registers (to_integer(unsigned(read_addr_1)));
	output2 <= registers (to_integer(unsigned(read_addr_2)));

   	process (clk)
   	begin
      	if rising_edge(clk) then
         	if (write_enable = '1') then
					if(to_integer(unsigned(write_addr))<8) then
						registers (to_integer(unsigned(write_addr))) <= data; 
					end if;
				end if;
      	end if;
	end process;
end architecture;