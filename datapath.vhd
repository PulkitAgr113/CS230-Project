-- Input signals for these are control pins which decide where the values of stuff such as
-- IR/PC etc is going to be taken from (which depends upon the instruction that we are executing)

library work;
use work.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity datapath is
	port
		(
			clk : in std_logic;
			master_data, master_wa : in std_logic_vector (15 downto 0);
			master_wc : in std_logic;
			
			m_we, m_rac, m_wac : in std_logic;
			
			upd_ir, upd_pc, trc, pc_c, upd_c, upd_z : in std_logic;
			
			alu_cin : in std_logic;
			alu_op: in std_logic_vector(1 downto 0);
			alu_ac, alu_bc : in std_logic_vector(1 downto 0);
			
			rf_we : in std_logic;
			rf_rc : in std_logic;
			rf_wc, rf_dc : in std_logic_vector(1 downto 0);
			rf_master : in std_logic_vector(2 downto 0);
			
			zc : in std_logic;
			ir : buffer std_logic_vector(15 downto 0);
			c,z : buffer std_logic;
			z_imm : out std_logic;
			
			r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic_vector(15 downto 0)
		);
end entity;

architecture datapath_arch of datapath is
	
	component ALU
		port
		(
			a,b : in std_logic_vector (15 downto 0);
			cin : in std_logic;
			op : in std_logic_vector(1 downto 0);
			o : out std_logic_vector (15 downto 0);
			cout, zero : out std_logic
		);
	end component;
	
	component memory
   port
		(
			clk, write_enable : in std_logic;
			data, write_addr, read_addr : in std_logic_vector (15 downto 0);
			o : out std_logic_vector (15 downto 0)
		);
	end component;
	
	component reg_file
   port
		(
			clk, write_enable : in std_logic;
			data : in std_logic_vector (15 downto 0);
			write_addr, read_addr_1, read_addr_2 : in std_logic_vector (2 downto 0);
			output1, output2, r0,r1,r2,r3,r4,r5,r6,r7 : out std_logic_vector (15 downto 0)
		);
	end component;
	
	signal alu_a, alu_b, alu_o : std_logic_vector(15 downto 0);
	signal alu_c, alu_z : std_logic;
	
	signal m_read, m_write, m_data, m_out : std_logic_vector(15 downto 0);

	signal rf_r1, rf_r2, rf_w : std_logic_vector(2 downto 0);
	signal rf_data, rf_out1, rf_out2 : std_logic_vector(15 downto 0);

	signal most_sig : std_logic_vector (15 downto 0) := "0000000000000000";
	
	signal sign_extended9, sign_extended6 : std_logic_vector (15 downto 0);
	
	signal pc, tr : std_logic_vector(15 downto 0) := (others => '0');	
	signal tr_combine, pc_combine : std_logic_vector(15 downto 0);

	signal mem0, z_combine : std_logic;	
	signal mem_we : std_logic;
begin
	
	mem_we <= master_wc or m_we;
	
	alu_instance : ALU
		port map (a => alu_a, b => alu_b, cin => alu_cin, op => alu_op, o => alu_o, cout => alu_c, zero => alu_z);
	
	memory_instance : memory
		port map (clk => clk, data => m_data, write_addr => m_write, read_addr => m_read, write_enable => mem_we, o => m_out );
	
	regfile_instance : reg_file
		port map (clk => clk, data => rf_data, write_addr => rf_w, read_addr_1 => rf_r1, read_addr_2 => rf_r2, write_enable => rf_we, output1 => rf_out1, output2 => rf_out2, r0 => r0, r1 => r1, r2 => r2, r3 => r3, r4 => r4, r5 => r5, r6=>r6, r7 => r7);
	
	se6 : for idx in 4 downto 0 generate
		sign_extended6(idx) <= ir(idx);
	end generate;
	se6_1 : for idx in 15 downto 5 generate
		sign_extended6(idx) <= ir(5);
	end generate;

	ms : for idx in 15 downto 7 generate
		most_sig(idx) <= ir(idx - 7);
	end generate;
	
	se9 : for idx in 7 downto 0 generate
		sign_extended9(idx) <= ir(idx);
	end generate;
	se9_1 : for idx in 15 downto 8 generate
		sign_extended9(idx) <= ir(8);
	end generate;

	alu_a <= rf_out1 when (alu_ac = "00") else sign_extended6 when (alu_ac = "01") else pc when (alu_ac = "10") else tr;
	alu_b <= rf_out2 when (alu_bc = "00") else "0000000000000001" when (alu_bc = "01") else sign_extended6 when (alu_bc = "10") else sign_extended9;
	
	rf_r1 <= rf_master when (rf_rc = '1') else ir(11 downto 9);
	rf_r2 <= ir(8 downto 6);
	rf_w <=  ir(11 downto 9) when (rf_wc = "00") else ir(8 downto 6) when (rf_wc = "01") else ir(5 downto 3) when (rf_wc = "10") else rf_master;
	rf_data <=  m_out when (rf_dc = "00") else alu_o when (rf_dc = "01") else pc when (rf_dc = "10") else most_sig;

	m_data <= master_data when(master_wc = '1') else rf_out1;
	m_write <= master_wa when (master_wc = '1') else alu_o when (m_wac = '1') else tr;
	m_read <= tr when (m_rac = '1') else pc;
					
	mem0 <= '1' when (m_out = "0000000000000000") else '0';
	z_combine <= mem0 when (zc = '1') else alu_z;
	
	tr_combine <= rf_out1 when (trc = '1') else alu_o;
	pc_combine <= rf_out2 when (pc_c = '1') else alu_o;
	z_imm <= alu_z;
	
	main : process(clk)
	begin
		if rising_edge(clk) then
			tr <= tr_combine;
			if upd_pc = '1' then
				pc <= pc_combine;
			end if;
			if upd_z = '1' then
				z <= z_combine;
			end if;
			if upd_ir = '1' then
				ir <= m_out;
			end if;
			if upd_c = '1' then 
				c <= alu_c;
			end if;
		end if;
	end process;
end architecture;