library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha_hw is
    generic(
        N_ZEROS : integer := 9;
        N_COMPONENTS: integer := 2
        
        );
    
    
	port ( 
        enable: in std_logic;
        high_nounce : in unsigned(N_COMPONENTS-1 downto 0);
        din: in STD_LOGIC_VECTOR(607 downto 0);
        data_out: out STD_LOGIC_VECTOR(255 downto 0);
        clk: in std_logic;
        hardware_rst: in std_logic;
        full_rst : in std_logic;
        has_sha : out std_logic;
        
        
        nounce_out : out std_logic_vector(31 downto 0);
        
        -- Debug Variables
        done: out std_logic
	);
end sha_hw;

architecture Behavioral of sha_hw is

	-- My signals
	type TState is (ST_WAITING, ST_ATTRIBUTION, ST_SCND_ATTRIBUTION, ST_HASHING, ST_EVALUATE1, ST_EVALUATE2 ,ST_DONE, ST_SCND_WAITING, ST_THRD_ATTRIBUTION, ST_FINISH);
	signal s_state : TState:= ST_WAITING;
	signal s_a, s_b, s_c, s_d, s_e, s_f, s_g, s_h: unsigned(31 downto 0);
		
    signal h_0: unsigned(31 downto 0) := x"6a09e667";
    signal h_1: unsigned(31 downto 0) := x"bb67ae85";
    signal h_2: unsigned(31 downto 0) := x"3c6ef372";
    signal h_3: unsigned(31 downto 0) := x"a54ff53a";
    signal h_4: unsigned(31 downto 0) := x"510e527f";
    signal h_5: unsigned(31 downto 0) := x"9b05688c";
    signal h_6: unsigned(31 downto 0) := x"1f83d9ab";
    signal h_7: unsigned(31 downto 0) := x"5be0cd19";

    -- Data in Array
    type data_in_array is array (integer range 0 to 1) of unsigned(511 downto 0);
    signal s_data_in : data_in_array;
    
    signal s_sha_in : unsigned(511 downto 0);
   
    -- Iterators
    signal iteration : integer range 0 to 2;
	signal i : integer range 0 to 63;
	
	-- Arrays
	type big_array is array (integer range 0 to 63) of unsigned(31 downto 0);
    constant k : big_array := 
    (
        x"428a2f98", x"71374491", x"b5c0fbcf", x"e9b5dba5", x"3956c25b", x"59f111f1", x"923f82a4", x"ab1c5ed5",
        x"d807aa98", x"12835b01", x"243185be", x"550c7dc3", x"72be5d74", x"80deb1fe", x"9bdc06a7", x"c19bf174",
        x"e49b69c1", x"efbe4786", x"0fc19dc6", x"240ca1cc", x"2de92c6f", x"4a7484aa", x"5cb0a9dc", x"76f988da",
        x"983e5152", x"a831c66d", x"b00327c8", x"bf597fc7", x"c6e00bf3", x"d5a79147", x"06ca6351", x"14292967",
        x"27b70a85", x"2e1b2138", x"4d2c6dfc", x"53380d13", x"650a7354", x"766a0abb", x"81c2c92e", x"92722c85",
        x"a2bfe8a1", x"a81a664b", x"c24b8b70", x"c76c51a3", x"d192e819", x"d6990624", x"f40e3585", x"106aa070",
        x"19a4c116", x"1e376c08", x"2748774c", x"34b0bcb5", x"391c0cb3", x"4ed8aa4a", x"5b9cca4f", x"682e6ff3",
        x"748f82ee", x"78a5636f", x"84c87814", x"8cc70208", x"90befffa", x"a4506ceb", x"bef9a3f7", x"c67178f2"
    );
    
    
    -- Array W[]
    signal w: big_array := (others=>(others=>'0'));
    
    -- Sinalização de que ocorreu um hash
    signal s_low_nouce : unsigned(31-N_COMPONENTS downto 0) := (others => '0');
    signal s_full_nounce: unsigned(31 downto 0);
    signal s_has_sha : std_logic := '0';
    
    signal s_zeros : std_logic_vector(31 downto 0); 
    		
    signal temp1, temp2 , S1, ch, S0, maj, sw0, sw1 : unsigned(31 downto 0);
    
    
    

    
begin
	-- Add user logic here
	
    process(clk)
	begin
        if(rising_edge(clk)) then 
            if(full_rst = '0' or hardware_rst ='1') then -- Reset
	            s_state <= ST_WAITING;
	            s_low_nouce <= (others => '0');
	            s_full_nounce <= high_nounce & s_low_nouce ;

            elsif (enable = '1') then              
                if (s_state = ST_WAITING) then
                

                    s_has_sha <= '0';
                    done <= '0';
                    i <= 0;
                    -- s_data_in <= (unsigned(din(607 downto 96)), unsigned(din(95 downto 0)) & x"e3143991" & x"80" & (311 downto 0 => '0') & x"0000000000000280" ); 
                     s_data_in <= (unsigned(din(607 downto 96)), unsigned(din(95 downto 0)) & s_full_nounce & x"80" & (311 downto 0 => '0') & x"0000000000000280" ); 
                    iteration <= 0;
                    
                    
                    h_0 <= x"6a09e667";
                    h_1<= x"bb67ae85";
                    h_2<= x"3c6ef372";
                    h_3<= x"a54ff53a";
                    h_4<= x"510e527f";
                    h_5<= x"9b05688c";
                    h_6<= x"1f83d9ab";
                    h_7 <= x"5be0cd19";
                    s_state <= ST_ATTRIBUTION;

                elsif (s_state = ST_ATTRIBUTION) then

                    w(0) <= unsigned(s_data_in(iteration)(511 downto 480));
                    w(1) <= unsigned(s_data_in(iteration)(479 downto 448));
                    w(2) <= unsigned(s_data_in(iteration)(447 downto 416));
                    w(3) <= unsigned(s_data_in(iteration)(415 downto 384));
                    w(4) <= unsigned(s_data_in(iteration)(383 downto 352));
                    w(5) <= unsigned(s_data_in(iteration)(351 downto 320));
                    w(6) <= unsigned(s_data_in(iteration)(319 downto 288));
                    w(7) <= unsigned(s_data_in(iteration)(287 downto 256));
                    w(8) <= unsigned(s_data_in(iteration)(255 downto 224));
                    w(9) <= unsigned(s_data_in(iteration)(223 downto 192));
                    w(10) <= unsigned(s_data_in(iteration)(191 downto 160));
                    w(11) <= unsigned(s_data_in(iteration)(159 downto 128));
                    w(12) <= unsigned(s_data_in(iteration)(127 downto 96));
                    w(13) <= unsigned(s_data_in(iteration)(95 downto 64));
                    w(14) <= unsigned(s_data_in(iteration)(63 downto 32));
                    w(15) <= unsigned(s_data_in(iteration)(31 downto 0));
                    
                    
                    s_a <= h_0;
                    s_b <= h_1;
                    s_c <= h_2;
                    s_d <= h_3;
                    s_e <= h_4;
                    s_f <= h_5;
                    s_g <= h_6;
                    s_h <= h_7;
                    
                    s_state <= ST_HASHING;

                elsif (s_state = ST_SCND_ATTRIBUTION) then
                
                    h_0 <= h_0 + s_a; 
                    h_1 <= h_1 + s_b; 
                    h_2 <= h_2 + s_c; 
                    h_3 <= h_3 + s_d; 
                    h_4 <= h_4 + s_e; 
                    h_5 <= h_5 + s_f; 
                    h_6 <= h_6 + s_g; 
                    h_7 <= h_7 + s_h;
                    i   <= 0;
                    iteration <= iteration + 1;

                    if (iteration = 0) then
                        s_state <= ST_ATTRIBUTION;
                        
                    elsif(iteration = 1) then
                        s_state <= ST_SCND_WAITING;

                    else
                        s_state <= ST_EVALUATE1;
                    end if;
	           
                elsif (s_state = ST_HASHING) then
                    if (i = 63) then
                        s_state <= ST_SCND_ATTRIBUTION;
                    end if;
                    
                     w(i + 16) <= 
                             -- w[i-16] + 
                             w(i) +
                             -- s0 + 
                             (
                                 (w(i + 1) ror 7) xor
                                 (w(i + 1) ror 18) xor
                                 (w(i + 1) srl 3)
                             ) + 
                             --w[i-7] + 
                             w(i + 9) + 
                             -- s1
                             (
                                 (w(i + 14) ror 17) xor
                                 (w(i + 14) ror 19) xor
                                 (w(i + 14) srl 10)
                             );
                                     
                  
                                             
                     s_h <= s_g;
                     s_g <= s_f;
                     s_f <= s_e;
                     -- s_d + temp1
                     s_e <= s_d + (s_h + ((s_e ror 6) xor (s_e ror 11) xor (s_e ror 25)) + ((s_e and s_f) xor (not(s_e) and s_g)) + k(i) + w(i));
                     s_d <= s_c;
                     s_c <= s_b;
                     s_b <= s_a;
                     -- temp2 + temp1
                     s_a <= (s_h + ((s_e ror 6) xor (s_e ror 11) xor (s_e ror 25)) + ((s_e and s_f) xor (not(s_e) and s_g)) + k(i) + w(i)) + (((s_a ror 2) xor (s_a ror 13) xor (s_a ror 22)) + ((s_a and s_b) xor (s_a and s_c) xor (s_b and s_c)));

                   
                    i <= i + 1;
                
                elsif (s_state = ST_EVALUATE1) then
                
                h_0(31 downto 24) <= h_7(7 downto 0);
                h_7(7 downto 0) <= h_0(31 downto 24);
                
                h_0(23 downto 16) <= h_7(15 downto 8);
                h_7(15 downto 8) <= h_0(23 downto 16);
                
                h_0(15 downto 8) <= h_7(23 downto 16);
                h_7(23 downto 16) <= h_0(15 downto 8);
                
                h_0(7 downto 0) <= h_7(31 downto 24);
                h_7(31 downto 24) <= h_0(7 downto 0);
                
                h_1(31 downto 24) <= h_6(7 downto 0);
                h_6(7 downto 0) <= h_1(31 downto 24);
                
                h_1(23 downto 16) <= h_6(15 downto 8);
                h_6(15 downto 8) <= h_1(23 downto 16);
                
                h_1(15 downto 8) <= h_6(23 downto 16);
                h_6(23 downto 16) <= h_1(15 downto 8);
                
                h_1(7 downto 0) <= h_6(31 downto 24);
                h_6(31 downto 24) <= h_1(7 downto 0);
                
                h_2(31 downto 24) <= h_5(7 downto 0);
                h_5(7 downto 0) <= h_2(31 downto 24);
                
                h_2(23 downto 16) <= h_5(15 downto 8);
                h_5(15 downto 8) <= h_2(23 downto 16);
                
                h_2(15 downto 8) <= h_5(23 downto 16);
                h_5(23 downto 16) <= h_2(15 downto 8);
                
                h_2(7 downto 0) <= h_5(31 downto 24);
                h_5(31 downto 24) <= h_2(7 downto 0);
                
                h_3(31 downto 24) <= h_4(7 downto 0);
                h_4(7 downto 0) <= h_3(31 downto 24);
                
                h_3(23 downto 16) <= h_4(15 downto 8);
                h_4(15 downto 8) <= h_3(23 downto 16);
                
                h_3(15 downto 8) <= h_4(23 downto 16);
                h_4(23 downto 16) <= h_3(15 downto 8);
                
                h_3(7 downto 0) <= h_4(31 downto 24);
                h_4(31 downto 24) <= h_3(7 downto 0);
                s_state <= ST_EVALUATE2;
                
                elsif (s_state = ST_EVALUATE2) then
                    
                    s_has_sha <= '1';        
                    if h_0(31 downto 0)  = x"00000000" then
                        s_state <= ST_DONE;
                    else
                        s_state <= ST_WAITING;
                        s_full_nounce <= s_full_nounce +1;                                  
    
                    end if;
                   
                    
                elsif (s_state = ST_DONE) then
                    done <= '1';
                    nounce_out <=   std_logic_vector(s_full_nounce(7 downto 0)) &
                                    std_logic_vector(s_full_nounce(15 downto 8)) &
                                    std_logic_vector(s_full_nounce(23 downto 16)) &
                                    std_logic_vector(s_full_nounce(31 downto 24));
                                    
                    s_has_sha <= '0';
                    data_out <= STD_LOGIC_VECTOR(h_0) & 
                                   STD_LOGIC_VECTOR(h_1) &
                                   STD_LOGIC_VECTOR(h_2) &
                                   STD_LOGIC_VECTOR(h_3) &
                                   STD_LOGIC_VECTOR(h_4) &
                                   STD_LOGIC_VECTOR(h_5) &
                                   STD_LOGIC_VECTOR(h_6) &
                                   STD_LOGIC_VECTOR(h_7);
                    s_state <= ST_FINISH;
                elsif (s_state = ST_FINISH) then
                    s_has_sha <= '0';
                    done <= '0';
                    
                elsif (s_state = ST_SCND_WAITING) then
                
                    i <= 0;
                    s_sha_in <= (h_0 & h_1 & h_2 & h_3 & h_4 & h_5 & h_6 & h_7 & x"80" & (183 downto 0 => '0') & x"0000000000000100" ); 
                     --s_data_in <= (unsigned(din(607 downto 96)), unsigned(din(95 downto 0)) & (s_count_hash + starting_nounce) & x"80" & (311 downto 0 => '0') & x"0000000000000280" ); 

                 
                     h_0 <= x"6a09e667";
                     h_1<= x"bb67ae85";
                     h_2<= x"3c6ef372";
                     h_3<= x"a54ff53a";
                     h_4<= x"510e527f";
                     h_5<= x"9b05688c";
                     h_6<= x"1f83d9ab";
                     h_7 <= x"5be0cd19";
                     s_state <= ST_THRD_ATTRIBUTION;
                     
                elsif (s_state = ST_THRD_ATTRIBUTION) then

                    w(0) <= unsigned(s_sha_in(511 downto 480));
                    w(1) <= unsigned(s_sha_in(479 downto 448));
                    w(2) <= unsigned(s_sha_in(447 downto 416));
                    w(3) <= unsigned(s_sha_in(415 downto 384));
                    w(4) <= unsigned(s_sha_in(383 downto 352));
                    w(5) <= unsigned(s_sha_in(351 downto 320));
                    w(6) <= unsigned(s_sha_in(319 downto 288));
                    w(7) <= unsigned(s_sha_in(287 downto 256));
                    w(8) <= unsigned(s_sha_in(255 downto 224));
                    w(9) <= unsigned(s_sha_in(223 downto 192));
                    w(10) <= unsigned(s_sha_in(191 downto 160));
                    w(11) <= unsigned(s_sha_in(159 downto 128));
                    w(12) <= unsigned(s_sha_in(127 downto 96));
                    w(13) <= unsigned(s_sha_in(95 downto 64));
                    w(14) <= unsigned(s_sha_in(63 downto 32));
                    w(15) <= unsigned(s_sha_in(31 downto 0));
                    
                    
                    s_a <= h_0;
                    s_b <= h_1;
                    s_c <= h_2;
                    s_d <= h_3;
                    s_e <= h_4;
                    s_f <= h_5;
                    s_g <= h_6;
                    s_h <= h_7;
                    
                    s_state <= ST_HASHING;
                    
	           
                end if;
	       
	       
	       end if;
	   end if;
	end process;
	
	has_sha <= s_has_sha;
	
end Behavioral;
