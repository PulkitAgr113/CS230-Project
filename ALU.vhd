-- ALU: Performs three types of operations based on 2 bit control signal
-- 00 -> nand, 01 -> add, 10 -> adl
library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity gen_prop is
	port
		(
			gen1,prop1 : in std_logic;
			gen2,prop2 : in std_logic;
			gen,prop : out std_logic
		);
end entity;

architecture gen_prop_arch of gen_prop is
begin
	gen <= (prop1 and gen2) or gen1;
	prop <= prop1 and prop2;
end architecture;

--------------------------------------------------------------------------------------------
-- KOGGE STONE ADDER
library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity adder is
	port
		(
			a,b : in std_logic_vector (15 downto 0); --inputs
			cin : in std_logic; --carry
			sum : out std_logic_vector (15 downto 0); -- output
			cout : out std_logic --carry output 
		);
end entity;

architecture adder_arch of adder is
	component gen_prop
		port
			(
				gen1,prop1 : in std_logic;
				gen2,prop2 : in std_logic;
				gen,prop : out std_logic
			);
	end component;	
	
	signal bx : std_logic_vector (15 downto 0);
	signal g_0,p_0 : std_logic_vector (15 downto 0);
	signal g_1,p_1 : std_logic_vector (15 downto 0);
	signal g_2,p_2 : std_logic_vector (15 downto 0);
	signal g_3, p_3 : std_logic_vector (15 downto 0);
	signal g_4, p_4 : std_logic_vector (15 downto 0);
	signal c : std_logic_vector (16 downto 0);

begin

	c(0) <= cin;

	bxor : for I in 15 downto 0 generate
		bx(I) <= cin xor b(I);
	end generate bxor;
		
	level0 : for I in 15 downto 0 generate
		g_0(I) <= a(I) and bx(I);
		p_0(I) <= a(I) xor bx(I);
	end generate level0;
	
	cpy0 : for I in 0 to 0 generate
		g_1(I) <= g_0(I);
		p_1(I) <= p_0(I);
	end generate cpy0;
		
	level1 : for I in 15 downto 1 generate
		genprop1 : gen_prop
			port map (gen1 => g_0(I), prop1 => p_0(I), gen2 => g_0(I-1), prop2 => p_0(I-1), gen => g_1(I), prop => p_1(I));
	end generate level1;
	
	cpy1 : for I in 0 to 1 generate
		g_2(I) <= g_1(I);
		p_2(I) <= p_1(I);
	end generate cpy1;
		
	level2 : for I in 15 downto 2 generate
		genprop2 : gen_prop
			port map (gen1 => g_1(I), prop1 => p_1(I), gen2 => g_1(I-2), prop2 => p_1(I-2), gen => g_2(I), prop => p_2(I));
	end generate level2;
	
	cpy2 : for I in 0 to 3 generate
		g_3(I) <= g_2(I);
		p_3(I) <= p_2(I);
	end generate cpy2;
		
	level3 : for I in 15 downto 4 generate
		genprop3 : gen_prop
			port map (gen1 => g_2(I), prop1 => p_2(I), gen2 => g_2(I-4), prop2 => p_2(I-4), gen => g_3(I), prop => p_3(I));
	end generate level3;
	
	cpy3 : for I in 0 to 7 generate
		g_4(I) <= g_3(I);
		p_4(I) <= p_3(I);
	end generate cpy3;
		
	level4 : for I in 15 downto 8 generate
		genprop4 : gen_prop
			port map (gen1 => g_3(I), prop1 => p_3(I), gen2 => g_3(I-8), prop2 => p_3(I-8), gen => g_4(I), prop => p_4(I));
	end generate level4;
	
	
	fin : for I in 15 downto 0 generate
		c(I+1) <= g_4(I) or (p_4(I) and cin);
		sum(I) <= p_0(I) xor c(I);
	end generate fin;
			
	cout <= c(16);
			
end architecture;

---------------------------------------------------------------------------------------------------------

library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity ADL is
	port
		(
			a,b : in std_logic_vector (15 downto 0);
			cin : in std_logic;
			sum : out std_logic_vector (15 downto 0);
			cout : out std_logic
		);
end entity;

architecture adl_arch of ADL is
	component adder
			port
		(
			a,b : in std_logic_vector (15 downto 0);
			cin : in std_logic;
			sum : out std_logic_vector (15 downto 0);
			cout : out std_logic
		);
	end component;

	signal b_2: std_logic_vector(15 downto 0);
	
begin
	b_2 <= b(14 downto 0) &  "0";
	
	add: adder		
	port map ( a => a, b => b_2, cin => cin, sum => sum, cout => cout );
end architecture;

---------------------------------------------------------------------------------------------------------

library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity ALU is
	port
		(
			a,b : in std_logic_vector (15 downto 0);
			cin : in std_logic;
			op: in std_logic_vector(1 downto 0);
			o : out std_logic_vector (15 downto 0);
			cout, zero : out std_logic
		);
end entity;

architecture ALU_arch of ALU is

	component adder
			port
		(
			a,b : in std_logic_vector (15 downto 0);
			cin : in std_logic;
			sum : out std_logic_vector (15 downto 0);
			cout : out std_logic
		);
	end component;
	
	component ADL 
		port
			(
				a,b : in std_logic_vector (15 downto 0);
				cin : in std_logic;
				sum : out std_logic_vector (15 downto 0);
				cout : out std_logic
			);
	end component;
	
	signal add_out, adl_out, nand_out, f_out : std_logic_vector(15 downto 0);
	signal add_carry, adl_carry: std_logic;
begin
	nand_out <= a nand b;
	add : adder
		port map ( a => a, b => b, cin => cin, sum => add_out, cout => add_carry );
	adl_op : ADL
		port map( a => a, b => b, cin => cin, sum => adl_out, cout => adl_carry );
		
	f_out <= nand_out when op = "00" else add_out when op= "01" else adl_out when op = "10";
	cout <= add_carry when op = "01" else adl_carry when op= "10";
	zero <= '1' when f_out = "0000000000000000" else '0';
	o <= f_out;
end architecture;

---------------------------------------------------------------------------------------------------------



library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity PriorityEncoder is
	port
		(
			input: in std_logic_vector(7 downto 0);
			empty: out std_logic;
			output: out std_logic_vector(7 downto 0);
			reg: out std_logic_vector(2 downto 0)
		);
end entity;

architecture PEarch of PriorityEncoder is

begin
	process(input)
	begin
		if input(0) = '1' then
			empty <= '0';
			reg <= "000";
			output <= input  xor "00000001";
		elsif input(1) = '1' then
			empty <= '0';
			reg <= "001";
			output <= input  xor "00000010";
		elsif input(2) = '1' then
			empty <= '0';
			reg <= "010";
			output <= input  xor "00000100";
		elsif input(3) = '1' then
			empty <= '0';
			reg <= "011";
			output <= input  xor "00001000";
		elsif input(4) = '1' then
			empty <= '0';
			reg <= "100";
			output <= input  xor "00010000";
		elsif input(5) = '1' then
			empty <= '0';
			reg <= "101";
			output <= input  xor "00100000";
		elsif input(6) = '1' then
			empty <= '0';
			reg <= "110";
			output <= input  xor "01000000";
		elsif input(7) = '1' then
			empty <= '0';
			reg <= "111";
			output <= input  xor "10000000";
		else
			empty <= '1';
			reg <= "000";
			output <= "00000000";
		end if;
	end process;
end architecture;