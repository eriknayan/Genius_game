-- C�digo Principal do Projeto Aplicativo de Microeletr�nica - Jogo Genius
-- Prof: Dr. Sibilla Batista da Luz Fran�a
-- Alunos: Erik Nayan e Diego Molina
-- Vers�o final: 29/11/2016

library ieee;
use ieee.std_logic_1164.all;
use work.global_pack.all;

entity Genius is
	
	generic ( d: integer := 5000000; -- Tempo de 100 ms 
				 p: integer := 500000; -- Tempo de 10 ms
				 e: integer := 50000000; -- Tempo de 1 s
				 m: integer := 25000000; -- Tempo de 500 ms
				 h: integer := 10000000; -- Tempo de 200 ms
				 T: integer := 250000000); -- Tempo de 5 s
	port ( clk, start, reset: in std_logic; -- Clock, Start e Reset
			 diff: in std_logic_vector (1 downto 0); -- Chaves seletoras de dificuldade
			 button: in std_logic_vector (3 downto 0); -- Push-buttons do jogo
			 display: out std_logic_vector (6 downto 0); -- Segmentos dos displays
			 anode: out std_logic_vector (3 downto 0); -- Anodos dos displays
			 leds: out std_logic_vector (3 downto 0); -- Leds de visualiza��o
			 h_sync: out std_logic; -- Sinal de sincroniza��o horizontal
			 v_sync: out std_logic; -- Sinal de sincroniza��o vertical
			 red: out std_logic_vector (2 downto 0); -- Bits vermelho do VGA
			 green: out std_logic_vector (2 downto 0); -- Bits verde do VGA
			 blue: out std_logic_vector (1 downto 0) ); -- Bits azul do VGA
			 
end Genius;

architecture Behavioral of Genius is

	signal key_delay: integer range 0 to T := T; -- Delay m�ximo entre bot�es
	signal dly_delay: integer range 0 to d := d; -- Delay entre impress�o de cores
	signal swt_delay: integer range 0 to p := p; -- Tempo de debouncing para os push-buttons
	signal seq_delay: integer range 0 to e := e; -- Tempo de impress�o de cada cor
	signal r: integer range 0 to 9:= 0; -- Ponteiro da matriz de sequ�ncias
	signal s: integer range 1 to 14 := 1; -- Ponteiro de espera de bot�es
	signal n: integer range 0 to 14 := 0; -- Ponteiro de impressao de sequ�ncia
	signal lvl: integer range 1 to 14 := 1; -- N�vel atual do jogo
	signal nibble: std_logic_vector (3 downto 0) := "0000"; -- Repassa o estado dos leds
	signal try: std_logic_vector (3 downto 0) := "0000"; -- Armazena a tentativa do jogador
	signal pr_state: states := idle; -- Estado da m�quina

	-- Declara��o do componente Decoder que controla os displays de 7 segmentos
	component Decoder is
		port ( clk, reset: in std_logic;
				display: out std_logic_vector (6 downto 0);
				anode: out std_logic_vector (3 downto 0);
				pr_state: in states;
				lvl: in integer range 1 to 14);
	end component;
	
	-- Declara��o do componente VGA que controla a exibi��o no monitor
	component VGA is
		port(	clk: in std_logic;  
				reset: in std_logic;
				nibble: in std_logic_vector (3 downto 0);
				lvl: in integer range 1 to 14;
				pr_state: in states;
				h_sync: out std_logic;  
				v_sync: out std_logic; 
				red: out std_logic_vector (2 downto 0);
				green: out std_logic_vector (2 downto 0);
				blue: out std_logic_vector (1 downto 0));	
	end component;
		
begin

	-- Processo que implementa a l�gica de estados do jogo
	process(clk, pr_state, reset, start, seq_delay, diff)
	begin
	
	if (reset = '1') then
	
		pr_state<=idle; -- Estado inicial em espera do jogo
		
	elsif (rising_edge(clk)) then
	
		-- Verifica��o da posi��o das chaves de dificuldade e atribui��o ao sinal
		if ( diff="00" ) then
			seq_delay<=e;
		elsif ( diff="01" ) then
			seq_delay<=m;
		elsif ( diff="10" ) then
			seq_delay<=h;
		else
			seq_delay<=e;
		end if;

		-- Case dos estados da m�quina 
		case pr_state is
		
		-- Estado inicial de espera da m�quina
		when idle => leds<="1111";
						 nibble<="1111";
						 lvl<=1;
						 n<=0;	
						 s<=1;
						 r<=0;
						 
						 if ( start='1' ) then
							pr_state<=print;
						 end if;
						 
		-- Estado que imprime as posi��es das sequ�ncias pr�-definidas				 
	   when print => leds<=sequences(r)(n);
						  nibble<=sequences(r)(n);
						  dly_delay<=d;
						  try<="0000";
						  
						  if ( seq_delay>0 ) then
								seq_delay<=seq_delay-1;
						  else
								pr_state<=dly;	
						  end if;
						  
		-- Estado de delay entre a impress�o de cada cor
		when dly => leds<="0000";
						nibble<="0000";
						
						if ( dly_delay>0 ) then
							dly_delay<=dly_delay-1;
						else
							if ( n=lvl ) then
								pr_state<=waiting;
							else
								pr_state<=print;
								n<=n+1;
							end if;
						end if;
						
		-- Estado que aguarda que o jogador pressione um bot�o						
		when waiting => leds<="0000";
						    nibble<="0000";
							 swt_delay<=p;
							 
							 if ( key_delay>0 ) then
								key_delay<=key_delay-1;
							 else 
								pr_state<=ff;
							 end if;
							 
							 if ( button/="0000" ) then
								try<=button;
								pr_state<=upack;
							 end if;
							 
		-- Estado de debouncing para o reconhecimento da subida do bot�o					 
		when upack => leds<=button;
						  nibble<=button;

						  if ( swt_delay>0 ) then
								swt_delay<=swt_delay-1;
						  else
								pr_state<=dbc;
						  end if;	
 
		-- Estado que aguarda que o jogador solte o bot�o pressionado
		when dbc => leds<=button;
						nibble<=button;
						swt_delay<=p;
						
						if ( key_delay>0 ) then
							key_delay<=key_delay-1;
						else 
							pr_state<=ff;
						end if;
						
						if ( button="0000" ) then
							pr_state<=downack;
						end if;
						
		-- Estado de debouncing para o reconhecimento da descida do bot�o
		-- Este estado tamb�m verifica se o bot�o correto foi pressionado
		when downack => leds<="0000";
							 nibble<="0000";
							 
							 if ( swt_delay>0 ) then
								swt_delay<=swt_delay-1;
							 else
								key_delay<=T;
								if ( try=sequences(r)(s) ) then
									if ( s=lvl ) then
										pr_state<=nextlvl;
									else
										s<=s+1;
										pr_state<=waiting;
									end if;
								else
									pr_state<=ff;
								end if;
							 end if;			
							 
		-- Estado que incrementa o n�vel atual do jogo				
		when nextlvl => leds<="0000";
							 nibble<="0000";
		
							 if ( lvl=14 ) then
								pr_state<=gg;
							 else
								pr_state<=print;
								lvl<=lvl+1;
								n<=0;
								s<=1;
							 end if;
							 
		-- Estado final de vit�ria				
		when gg => leds<="1111";
					  nibble<="1111";
		
						if ( start='1' ) then
							pr_state<=print;
							key_delay<=T;
							lvl<=1;
							n<=0;
							s<=1;
							r<=r+1;
							if (r=9) then
								r<=0;
							end if;
						end if;
						
		-- Estado final de derrota
		when ff => leds<=try;
					  nibble<=try;
		
						 if ( start='1' ) then
							pr_state<=print;
							key_delay<=T;
							lvl<=1;
							n<=0;
							s<=1;
							r<=r+1;
							if (r=9) then
								r<=0;
							end if;
						 end if;					

		end case;	
		
	end if;
		
	end process;

	-- Associa��o dos componentes com os respectivos E/S e sinais internos
	disp: Decoder port map(clk, reset, display, anode, pr_state, lvl);
	monitor: VGA port map (clk, reset, nibble, lvl, pr_state, h_sync, v_sync, red, green, blue);

end Behavioral;