library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha_hw is
	port ( 
        start: in std_logic;
        
        din: in STD_LOGIC_VECTOR(607 downto 0);
        data_out: out STD_LOGIC_VECTOR(255 downto 0);
        
        clk: in std_logic;
        rst: in std_logic;
        
        -- Debug Variables
        done: out std_logic;
        i_out: out STD_LOGIC_VECTOR(5 downto 0)
	);
end sha_hw;

architecture Behavioral of sha_hw is

	-- My signals
	type TState is (ST_WAITING, ST_ATTRIBUTION0, ST_ATTRIBUTION1, ST_HASHING, ST_EVALUATE ,ST_DONE);
	signal s_state : TState:= ST_WAITING;
	signal s_a, s_b, s_c, s_d, s_e, s_f, s_g, s_h: unsigned(31 downto 0);
	
	signal t_1 : unsigned(511 downto 0) := unsigned(din(607 downto 96));
	signal t_2 : unsigned(511 downto 0) := unsigned(din(95 downto 0)) & x"6961676f" & x"80" & (311 downto 0 => '0') & x"0000000000000280";
	
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
    -- signal s_data_in: unsigned(1023 downto 0) := unsigned(data_in) & x"01234567" & x"80" & (311 downto 0 => '0') & x"0000000000000280";
   
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
    
    
--	constant k : std_logic_vector(2047 downto 0) := 
	
--    x"428a2f98" & x"71374491" & x"b5c0fbcf" & x"e9b5dba5" & x"3956c25b" & x"59f111f1" & x"923f82a4" & x"ab1c5ed5" &
--    x"d807aa98" & x"12835b01" & x"243185be" & x"550c7dc3" & x"72be5d74" & x"80deb1fe" & x"9bdc06a7" & x"c19bf174" &
--    x"e49b69c1" & x"efbe4786" & x"0fc19dc6" & x"240ca1cc" & x"2de92c6f" & x"4a7484aa" & x"5cb0a9dc" & x"76f988da" &
--    x"983e5152" & x"a831c66d" & x"b00327c8" & x"bf597fc7" & x"c6e00bf3" & x"d5a79147" & x"06ca6351" & x"14292967" &
--    x"27b70a85" & x"2e1b2138" & x"4d2c6dfc" & x"53380d13" & x"650a7354" & x"766a0abb" & x"81c2c92e" & x"92722c85" &
--    x"a2bfe8a1" & x"a81a664b" & x"c24b8b70" & x"c76c51a3" & x"d192e819" & x"d6990624" & x"f40e3585" & x"106aa070" &
--    x"19a4c116" & x"1e376c08" & x"2748774c" & x"34b0bcb5" & x"391c0cb3" & x"4ed8aa4a" & x"5b9cca4f" & x"682e6ff3" &
--    x"748f82ee" & x"78a5636f" & x"84c87814" & x"8cc70208" & x"90befffa" & x"a4506ceb" & x"bef9a3f7" & x"c67178f2"
--	;


begin
	-- Add user logic here
	
    process(clk)
	begin
        if(rising_edge(clk)) then 
            if(rst = '1') then -- Reset
	            s_state <= ST_WAITING;
	           
            else                
                if (s_state = ST_WAITING) then
                    done <= '0';
                    i <= 0;
                    s_data_in <= (t_1,t_2 ); 
                    iteration <= 0;

                    
                    if (start = '1') then
                        s_state <= ST_ATTRIBUTION0;
                    end if;

                elsif (s_state = ST_ATTRIBUTION0) then

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

                elsif (s_state = ST_ATTRIBUTION1) then
                
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
                        s_state <= ST_ATTRIBUTION0;

                    else
                        s_state <= ST_EVALUATE;
                    end if;
	           
                elsif (s_state = ST_HASHING) then
                    if (i = 63) then
                        s_state <= ST_ATTRIBUTION1;
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
                
                elsif (s_state = ST_EVALUATE) then
                    data_out <= STD_LOGIC_VECTOR(h_0) & 
                        STD_LOGIC_VECTOR(h_1) &
                        STD_LOGIC_VECTOR(h_2) &
                        STD_LOGIC_VECTOR(h_3) &
                        STD_LOGIC_VECTOR(h_4) &
                        STD_LOGIC_VECTOR(h_5) &
                        STD_LOGIC_VECTOR(h_6) &
                        STD_LOGIC_VECTOR(h_7);
               
                elsif (s_state = ST_DONE) then
                    

                    s_state <= ST_WAITING;
                    done <= '1';

	           
                end if;
	       
	       
	       end if;
	   end if;
	end process;
	
	i_out<= std_logic_vector(to_unsigned(i,6));
	

end Behavioral;