library ieee;
use ieee.std_logic_1164.all;
use work.global_pack.all;

entity Genius is
	
	generic ( d: integer := 5000000;
				 p: integer := 5000000;
				 e: integer := 50000000;
				 m: integer := 25000000;
				 h: integer := 10000000;
				 T: integer := 250000000);
	port ( clk, start, reset: in std_logic;
			 diff: in std_logic_vector (1 downto 0);
			 switches: in std_logic_vector (3 downto 0);
			 display: out std_logic_vector (6 downto 0);
			 anode: out std_logic_vector (3 downto 0);
			 leds: out std_logic_vector (3 downto 0); 
			 h_sync: out std_logic;  
			 v_sync: out std_logic; 
			 red: out std_logic_vector (2 downto 0);
			 green: out std_logic_vector (2 downto 0);
			 blue: out std_logic_vector (1 downto 0) );
			 
end Genius;

architecture Behavioral of Genius is

	signal key_delay: integer range 0 to T := T;
	signal dly_delay: integer range 0 to d := d;
	signal swt_delay: integer range 0 to p := p;
	signal seq_delay: integer range 0 to e := 0;
	
	signal s: integer range 1 to 14 := 1;
	signal n: integer range 0 to 14 := 0;
	signal lvl: integer range 1 to 14 := 1;
		
	shared variable mode: integer range 0 to e := e;
	
	signal color: std_logic_vector (3 downto 0);
	signal try: std_logic_vector (3 downto 0) := "0000";
	
	signal pr_state: states := idle;
	shared variable nx_state: states := idle;

	component Decoder is
		port ( clk, reset: in std_logic;
				display: out std_logic_vector (6 downto 0);
				anode: out std_logic_vector (3 downto 0);
				pr_state: in states;
				lvl: in integer range 1 to 14);
	end component;
	
	component VGA is
		port(	clk: in std_logic;  
				reset:  in std_logic;
				color:  in std_logic_vector (3 downto 0);
				switches:  in std_logic_vector (3 downto 0);
				pr_state: in states;
				h_sync: out std_logic;  
				v_sync: out std_logic; 
				red: out std_logic_vector (2 downto 0);
				green: out std_logic_vector (2 downto 0);
				blue: out std_logic_vector (1 downto 0));	
	end component;
		
begin

	
	process(clk, pr_state, reset, start, seq_delay, diff)
	begin

	if (reset = '1') then
	
		nx_state:=idle;
		pr_state<=idle;
		
	elsif (rising_edge(clk)) then

		case pr_state is
		
		when idle => leds<="1111";
						 lvl<=1;
						 n<=0;	
						 s<=1;
						 try<="0000";
						 
						 if ( start='1' ) then
							if ( diff="00" ) then
								mode:=e;
							elsif ( diff="01" ) then
								mode:=m;
							elsif ( diff="10" ) then
								mode:=h;
							else
								mode:=e;
							end if;	
							nx_state:=print;
						 else
							nx_state:=idle;
						 end if;
						 
	   when print => leds<=seq(n);
						  color<=seq(n);
						  
						  if ( seq_delay=0 ) then
								nx_state:=dly;	
						  else
								nx_state:=print;
						  end if;
		
		when dly => leds<="0000";
		
						if ( dly_delay=0 ) then
							if ( n=lvl ) then
								nx_state:=waiting;
							else
								nx_state:=print;
								n<=n+1;
							end if;
						else
							nx_state:=dly;
						end if;
								
		when waiting => leds<="0000";
		
							 if ( switches/="0000" ) then
								nx_state:=upack;
							 elsif ( key_delay=0 ) then
								nx_state:=ff;
							 else
								nx_state:=waiting;
							 end if;
							 
		when upack => leds<=switches;
		
						  if ( swt_delay=0 ) then
								if ( switches/="0000" ) then
									try<=switches;
									nx_state:=dbc;
								else
									nx_state:=waiting;
								end if;
						  elsif ( key_delay=0 ) then
								nx_state:=ff;
						  else
								nx_state:=upack;
						  end if;
		
 
		when dbc => leds<=switches;
		
						if ( switches="0000" ) then
							nx_state:=downack;
						elsif ( key_delay=0 ) then
							nx_state:=ff;
						else
							nx_state:=dbc;
						end if;
						
		when downack => leds<="0000";
								
							 if ( swt_delay=0 ) then
								if ( try=seq(s) ) then
									if ( s=lvl ) then
										nx_state:=nextlvl;
									else
										s<=s+1;
										nx_state:=waiting;
									end if;
								else
									nx_state:=ff;
								end if;
							elsif ( key_delay=0 ) then
								nx_state:=ff;
							else
								nx_state:=downack;
							end if;
							 
						
		when nextlvl => leds<="0000";
		
							 if ( lvl=14 ) then
								nx_state:=gg;
							 else
								nx_state:=print;
								lvl<=lvl+1;
								n<=0;
								s<=1;
							 end if;
						
		when gg => leds<="0110";
		
						if ( start='1' ) then
							nx_state:=print;
							lvl<=1;
							n<=0;
							s<=1;
							if ( diff="00" ) then
								mode:=e;
							elsif ( diff="01" ) then
								mode:=m;
							elsif ( diff="10" ) then
								mode:=h;
							else
								mode:=e;
							end if;
						else 
							nx_state:=gg;
						end if;
	
		when ff => leds<=try;
		
						 if ( start='1' ) then
							nx_state:=print;
							lvl<=1;
							n<=0;
							s<=1;
							if ( diff="00" ) then
								mode:=e;
							elsif ( diff="01" ) then
								mode:=m;
							elsif ( diff="10" ) then
								mode:=h;
							else
								mode:=e;
							end if;
						 else 
							nx_state:=ff;
						 end if;					

		end case;	
		
		if (nx_state/=pr_state) then
			if (nx_state/=dbc and nx_state/=upack and nx_state/=downack) then
				seq_delay<=mode;
				swt_delay<=p;
				dly_delay<=d;
				key_delay<=T;
			end if;
			pr_state<=nx_state;
		else
			if ( pr_state=print ) then
				if ( seq_delay>0 ) then
					seq_delay<=seq_delay-1;
				end if;
			elsif ( pr_state=dly ) then
				if ( dly_delay>0 ) then
					dly_delay<=dly_delay-1;
				end if;
			elsif ( pr_state=waiting or pr_state=dbc) then
				if ( key_delay>0 ) then
					key_delay<=key_delay-1;
				end if;
			elsif ( pr_state=upack or pr_state=downack ) then
				if ( swt_delay>0 ) then
					swt_delay<=swt_delay-1;
				end if;
			end if;
		end if;
		
	end if;
		
	end process;

	disp: Decoder port map(clk, reset, display, anode, pr_state, lvl);
	
	monitor: VGA port map (clk, reset, color, switches, pr_state, h_sync, v_sync, red, green, blue);

end Behavioral;

