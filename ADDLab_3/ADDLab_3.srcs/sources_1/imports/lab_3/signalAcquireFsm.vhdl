--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015 
-- Modified:	Fall 2022
-- File:	lab2_fsm.vhdl
-- HW:	Lab2
--	Crs:	ECE 383
--
-- Purp: The control unit for the audio O'scope
--
-- Documentation:	No help, though I used an example from my Digital
--						Design text book.
--
-- Academic Integrity Statement: I certify that, while others may have 
-- assisted me in brain storming, debugging and validating this program, 
-- the program itself is my own work. I understand that submitting code 
-- which is the work of other individuals is a violation of the honor   
-- code.  I also understand that if I knowingly give my original work to 
-- another individual is also a violation of the honor code. 
------------------------------------------------------------------------- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.signalAcquire_Package.all;			-- include your library here with added components ac97, ac97cmd

entity signalAcquire_Fsm is
    PORT (  clk : in  STD_LOGIC;
            resetn : in  STD_LOGIC;
            sw: in STD_LOGIC_VECTOR(SW_WIDTH - 1 downto 0);
            cw: out STD_LOGIC_VECTOR (CW_WIDTH - 1 downto 0));
end signalAcquire_Fsm;

architecture Behavioral of signalAcquire_Fsm is

	signal state: state_type;
	
	signal ALL_CHANNELS_HAVE_BEEN_READ_SW, SHORT_DELAY_DONE_SW, LONG_DELAY_DONE_SW: STD_LOGIC;
    signal BUSY_SW: STD_LOGIC;
    signal BTN_PREV, BTN_CURR, BTN_CHANGE: STD_LOGIC;
begin

    -- defining intuitive names for the status word bits to make interperting the
    -- logic in the state_process much easier and thus, you'll make fewer errors.
    ALL_CHANNELS_HAVE_BEEN_READ_SW <= sw(ALL_CHANNELS_HAVE_BEEN_READ_SW_BIT_INDEX);
    SHORT_DELAY_DONE_SW <= sw(SHORT_DELAY_DONE_SW_BIT_INDEX);
    LONG_DELAY_DONE_SW <= sw(LONG_DELAY_DONE_SW_BIT_INDEX);
    BUSY_SW <= sw(BUSY_SW_BIT_INDEX);
    BTN_CHANGE <= BTN_PREV xor BTN_CURR; --If state has change

    
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	state_process: process(clk)  
	begin
		if (rising_edge(clk)) then
			if (resetn = '0') then 
				state <= RESET_STATE;
			else 
				case state is
				    
				    when RESET_STATE =>
				        state <= LONG_DELAY_STATE;
				        
				    when LONG_DELAY_STATE => --Switch when long delay is done
				        if (LONG_DELAY_DONE_SW = '1') then
				            state <= RESET_AD7606_STATE;
				        end if;
				        
				    when RESET_AD7606_STATE =>
				        if (SHORT_DELAY_DONE_SW = '1') then
				            state <= WAIT_TRIGGER_STATE;
				        end if;
				        
				    when WAIT_TRIGGER_STATE =>
				        if (BTN_CHANGE = '1') then
				            state <= WAIT_BUTTON_STATE;
				        end if;
				        
				    when WAIT_BUTTON_STATE =>
				        if (BTN_CHANGE = '1') then
				            state <= ASSERT_CONVSTART_STATE;
				        end if;
				        
				    when ASSERT_CONVSTART_STATE =>
				        if (SHORT_DELAY_DONE_SW = '1') then
				            state <= WAIT_BUSY0_STATE;
				        end if;
				        
				    when WAIT_BUSY0_STATE =>
				        if (BUSY_SW = '1') then
				            state <= WAIT_BUSY1_STATE;
				        end if;
				        
				    when WAIT_BUSY1_STATE =>
				        if (BUSY_SW = '0') then
				            state <= WAIT_VALID_DATA_STATE;
				        end if;
				        
				    when WAIT_VALID_DATA_STATE =>
				        if (ALL_CHANNELS_HAVE_BEEN_READ_SW = '1') then
				            state <= WAIT_TRIGGER_STATE;
				        elsif (SHORT_DELAY_DONE_SW = '1') then
				            state <= LATCH_STATE;
				        end if;
				        
				    when LATCH_STATE =>
				        state <= PAUSE_BETWEEN_CHANNELS_STATE;
				        
				    when PAUSE_BETWEEN_CHANNELS_STATE =>
				        if (SHORT_DELAY_DONE_SW = '1') then
				            state <= CLEAR_SHORT_COUNTER_STATE;
				        end if;
				        
				    when CLEAR_SHORT_COUNTER_STATE =>
				        state <= WAIT_VALID_DATA_STATE;
				        
				end case;
			end if;
			BTN_PREV <= BTN_CURR; --Update previous state
		end if;
	end process;

    -------------------------------------------------------------------------------
    -- LPT: List all the bits of your control word and define their purpose.
    --      cw              Purpose
    --
    -- LPT: Add the truth table for any BBB which are used in the datapath
    --  counter control     Function
    --  c   Function
    --  00  Hold
    --  01  load
    --  10  inc
    --  11  reset
    -------------------------------------------------------------------------------
	output_process: process (state)
	begin
	    case state is
            when RESET_STATE => 
                cw(CONVST_CW_BIT_INDEX) <= '1';
                cw(RD_CW_BIT_INDEX) <= '1';
                cw[CS_CW_BIT_INDEX] <= 1;
                cw[RESET_AD7606_CW_BIT_INDEX] <= 1; --active high
                cw[REG_FILE_WRITE_CW_BIT_INDEX] <= 0;
                cw[REG_FILE_COUNTER_CW_INDEX + 1 downto REG_FILE_COUNTER_CW_INDEX] <= "11";
                cw[SHORT_DELAY_COUNTER_CW_INDEX + 1 downto SHORT_DELAY_COUNTER_CW_INDEX] <= "11";
                cw[LONG_DELAY_COUNTER_CW_INDEX + 1 downto LONG_DELAY_COUNTER_CW_INDEX] <= "11";
                    

 		<complete>

		end case;
	end process;

end Behavioral;



