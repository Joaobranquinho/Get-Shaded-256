library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha_hw is
	port ( 
        start: in std_logic;
        
        data_in: in STD_LOGIC_VECTOR(511 downto 0);
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
	type TState is (ST_WAITING, ST_HASHING, ST_DONE);
	signal s_state : TState:= ST_WAITING;
	signal s_a, s_b, s_c, s_d, s_e, s_f, s_g, s_h : std_logic_vector(31 downto 0);
	
	
    
    -- Iterators
	signal i : integer range 0 to 63;
	
	type big_array is array (integer range 0 to 63) of std_logic_vector(31 downto 0);
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
                    
                    s_a <= x"6a09e667";
                    s_b <= x"bb67ae85";
                    s_c <= x"3c6ef372";
                    s_d <= x"a54ff53a";
                    s_e <= x"510e527f";
                    s_f <= x"9b05688c";
                    s_g <= x"1f83d9ab";
                    s_h <= x"5be0cd19";
                    
                    w(0) <= data_in(511 downto 480);
                    w(1) <= data_in(479 downto 448);
                    w(2) <= data_in(447 downto 416);
                    w(3) <= data_in(415 downto 384);
                    w(4) <= data_in(383 downto 352);
                    w(5) <= data_in(351 downto 320);
                    w(6) <= data_in(319 downto 288);
                    w(7) <= data_in(287 downto 256);
                    w(8) <= data_in(255 downto 224);
                    w(9) <= data_in(223 downto 192);
                    w(10) <= data_in(191 downto 160);
                    w(11) <= data_in(159 downto 128);
                    w(12) <= data_in(127 downto 96);
                    w(13) <= data_in(95 downto 64);
                    w(14) <= data_in(63 downto 32);
                    w(15) <= data_in(31 downto 0);
                    
                    if (start = '1') then
                        s_state <= ST_HASHING;
                    end if;
	           
	           
                elsif (s_state = ST_HASHING) then

	               
                    if (i = 63) then
                        s_state <= ST_DONE;

                    else
                        -- calculate W
                        --s0 := (w[i-15] rotacionarparadireita 7) xor (w[i-15] rotacionarparadireita 18) xor (w[i-15] deslicarparadireita 3)
                        --s1 := (w[i-2] rotacionarparadireita 17) xor (w[i-2] rotacionarparadireita 19) xor (w[i-2] deslocarparadireita 10)
                        --w[i] := w[i-16] + s0 + w[i-7] + s1
                        w(i + 16) <= 
                        std_logic_vector(
                            -- w[i-16] + 
                            unsigned(w(i)) +
                            -- s0 + 
                            (
                                (unsigned(w(i + 1)) srl 7) xor
                                (unsigned(w(i + 1)) srl 18) xor
                                (unsigned(w(i + 1)) srl 3)
                            ) + 
                            --w[i-7] + 
                            unsigned( w(i + 9) ) + 
                            -- s1
                            (
                                (unsigned(w(i + 14)) srl 17) xor
                                (unsigned(w(i + 14)) srl 19) xor
                                (unsigned(w(i + 14)) srl 10)
                            )
                        );
                        
                        -- calculate a, b, ... h
                        
                        --                   S1 := (e rotacionarparadireita 6) xor (e rotacionarparadireita 11) xor (e rotacionarparadireita 25)
                        --                   ch := (e e f) xor ((não e) e g)
                        --                   temp1 := h + S1 + ch + k[i] + w[i]
                        --                   S0 := (a rotacionarparadireita 2) xor (a rotacionarparadireita 13) xor (a rotacionarparadireita 22)
                        --                   mai + 16 := (a e b) xor (a e c) xor (b e c)
                        --                   temp2 := S0 + mai + 16
                        
                        
                        --                   S1 <= ((unsigned(s_e) srl 6) xor (unsigned(s_e) srl 11) xor (unsigned(s_e) srl 25));
                        --                   ch <= (unsigned(s_e and s_f) xor unsigned(not(s_e) and s_g));
                        --                   temp1 <=  unsigned(s_h) + S1 + ch + unsigned(k(i)) + unsigned(w(i));
                        --                   S0 <= ((unsigned(s_a) srl 2) xor (unsigned(s_a) srl 13) xor (unsigned(s_a) srl 22));
                        --                   mai + 16 <= (unsigned(s_a and s_b) xor unsigned(s_a and s_c) xor unsigned(s_b and s_c));
                        --                   temp2 <= S0 + mai + 16;
                        
                        
                        s_a <= s_g;
                        s_b <= s_f;
                        s_c <= s_e;
                        -- s_d + temp
                        s_d <= std_logic_vector( unsigned(s_d) + (unsigned(s_h) + ((unsigned(s_e) srl 6) xor (unsigned(s_e) srl 11) xor (unsigned(s_e) srl 25)) + (unsigned(s_e and s_f) xor unsigned(not(s_e) and s_g)) + unsigned(k(i)) + unsigned(w(i))) );
                        s_e <= s_c;
                        s_f <= s_b;
                        s_g <= s_a;
                        -- temp2 + temp1
                        s_h <= std_logic_vector((unsigned(s_h) + ((unsigned(s_e) srl 6) xor (unsigned(s_e) srl 11) xor (unsigned(s_e) srl 25)) + (unsigned(s_e and s_f) xor unsigned(not(s_e) and s_g)) + unsigned(k(i)) + unsigned(w(i))) + (((unsigned(s_a) srl 2) xor (unsigned(s_a) srl 13) xor (unsigned(s_a) srl 22)) + (unsigned(s_a and s_b) xor unsigned(s_a and s_c) xor unsigned(s_b and s_c))));
                        
                        
                        i <= i + 1;
	                end if;
	           
                elsif (s_state = ST_DONE) then
                    data_out <= s_a & s_b & s_c & s_d & s_e & s_f & s_g & s_h;
                    s_state <= ST_WAITING;
                    done <= '1';

	           
                end if;
	       
	       
	       end if;
	   end if;
	end process;
	
	i_out<= std_logic_vector(to_unsigned(i,6));
	

end Behavioral;
