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
	signal s_a, s_b, s_c, s_d, s_e, s_f, s_g, s_h: unsigned(31 downto 0);
	
    constant h_0: unsigned(31 downto 0) := x"6a09e667";
    constant h_1: unsigned(31 downto 0) := x"bb67ae85";
    constant h_2: unsigned(31 downto 0) := x"3c6ef372";
    constant h_3: unsigned(31 downto 0) := x"a54ff53a";
    constant h_4: unsigned(31 downto 0) := x"510e527f";
    constant h_5: unsigned(31 downto 0) := x"9b05688c";
    constant h_6: unsigned(31 downto 0) := x"1f83d9ab";
    constant h_7: unsigned(31 downto 0) := x"5be0cd19";
   
    -- Iterators
	signal i : integer range 0 to 63;
	
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
                    

                    
--                    h0 := 0x6a09e667
--                    h1 := 0xbb67ae85
--                    h2 := 0x3c6ef372
--                    h3 := 0xa54ff53a
--                    h4 := 0x510e527f
--                    h5 := 0x9b05688c
--                    h6 := 0x1f83d9ab
--                    h7 := 0x5be0cd19
                    
                    w(0) <= unsigned(data_in(511 downto 480));
                    w(1) <= unsigned(data_in(479 downto 448));
                    w(2) <= unsigned(data_in(447 downto 416));
                    w(3) <= unsigned(data_in(415 downto 384));
                    w(4) <= unsigned(data_in(383 downto 352));
                    w(5) <= unsigned(data_in(351 downto 320));
                    w(6) <= unsigned(data_in(319 downto 288));
                    w(7) <= unsigned(data_in(287 downto 256));
                    w(8) <= unsigned(data_in(255 downto 224));
                    w(9) <= unsigned(data_in(223 downto 192));
                    w(10) <= unsigned(data_in(191 downto 160));
                    w(11) <= unsigned(data_in(159 downto 128));
                    w(12) <= unsigned(data_in(127 downto 96));
                    w(13) <= unsigned(data_in(95 downto 64));
                    w(14) <= unsigned(data_in(63 downto 32));
                    w(15) <= unsigned(data_in(31 downto 0));
                    
                    if (start = '1') then
                        s_state <= ST_HASHING;
                        s_a <= h_0;
                        s_b <= h_1;
                        s_c <= h_2;
                        s_d <= h_3;
                        s_e <= h_4;
                        s_f <= h_5;
                        s_g <= h_6;
                        s_h <= h_7;
                    end if;
	           
	           
                elsif (s_state = ST_HASHING) then

	               
                    if (i = 63) then
                        s_state <= ST_DONE;
                    end if;
                
                    -- calculate W
                    --s0 := (w[i-15] rotacionarparadireita 7) xor (w[i-15] rotacionarparadireita 18) xor (w[i-15] deslicarparadireita 3)
                    --s1 := (w[i-2] rotacionarparadireita 17) xor (w[i-2] rotacionarparadireita 19) xor (w[i-2] deslocarparadireita 10)
                    --w[i] := w[i-16] + s0 + w[i-7] + s1
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
                    
                    -- calculate a, b, ... h
                    
                    --                   S1 := (e rotacionarparadireita 6) xor (e rotacionarparadireita 11) xor (e rotacionarparadireita 25)
                    --                   ch := (e e f) xor ((não e) e g)
                    --                   temp1 := h + S1 + ch + k[i] + w[i]
                    --                   S0 := (a rotacionarparadireita 2) xor (a rotacionarparadireita 13) xor (a rotacionarparadireita 22)
                    --                   maj := (a e b) xor (a e c) xor (b e c)
                    --                   temp2 := S0 + maj
                    
                    
                    --                   S1 <= ((s_e ror 6) xor (s_e ror 11) xor (s_e ror 25));
                    --                   ch <= ((s_e and s_f) xor (not(s_e) and s_g));
                    --                   temp1 <=  s_h + S1 + ch + k(i) + w(i);
                    --                   S0 <= ((s_a ror 2) xor (s_a ror 13) xor (s_a ror 22));
                    --                   maj <= ((s_a and s_b) xor (s_a and s_c) xor (s_b and s_c));
                    --                   temp2 <= S0 + maj;
                    
                    
--                    h := g
--                    g := f
--                    f := e
--                    e := d + temp1
--                    d := c
--                    c := b
--                    b := a
--                    a := temp1 + temp2
                            
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
               
                elsif (s_state = ST_DONE) then
                    
                    data_out <= STD_LOGIC_VECTOR(h_0 + s_a) & 
                                STD_LOGIC_VECTOR(h_1 + s_b) &
                                STD_LOGIC_VECTOR(h_2 + s_c) &
                                STD_LOGIC_VECTOR(h_3 + s_d) &
                                STD_LOGIC_VECTOR(h_4 + s_e) &
                                STD_LOGIC_VECTOR(h_5 + s_f) &
                                STD_LOGIC_VECTOR(h_6 + s_g) &
                                STD_LOGIC_VECTOR(h_7 + s_h);
                    s_state <= ST_WAITING;
                    done <= '1';

	           
                end if;
	       
	       
	       end if;
	   end if;
	end process;
	
	i_out<= std_logic_vector(to_unsigned(i,6));
	

end Behavioral;
