--------------------------------------------------------------------
-- Name:	Chris Coulston
-- Date:	Feb 3, 2015
-- Modified:	Sept 2022
-- File:	lab2_datapath.vhdl
-- HW:	Lab 2
--	Crs:	ECE 383 and EENG 498
--
-- Purp: The datapath for the audio O'scope
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
use work.signalAcquire_Package.all;			-- include the basic building block library

entity signalAcquire_Datapath is
    PORT ( clk : in  STD_LOGIC;
           resetn : in  STD_LOGIC;
		   cw : in STD_LOGIC_VECTOR(CW_WIDTH - 1 downto 0);
		   sw : out STD_LOGIC_VECTOR(DATAPATH_SW_WIDTH - 1 downto 0);
		   an7606data: in STD_LOGIC_VECTOR(15 downto 0);
		   rfAddr: in STD_LOGIC_VECTOR(2 downto 0);
		   rfData: out STD_LOGIC_VECTOR(15 downto 0) );
end signalAcquire_Datapath;

architecture behavior of signalAcquire_Datapath is
    
    signal ALL_CHANNELS_HAVE_BEEN_READ_SW, SHORT_DELAY_DONE_SW, LONG_DELAY_DONE_SW: STD_LOGIC;
    signal SHORT_DELAY_COUNTER_CW, LONG_DELAY_COUNTER_CW, REG_FILE_COUNTER_CW: STD_LOGIC_VECTOR(1 downto 0);
    signal regFileNum: STD_LOGIC_VECTOR (3 downto 0);
    signal shortCount: STD_LOGIC_VECTOR (7 downto 0);
    signal longCount: STD_LOGIC_VECTOR (23 downto 0);
    
begin
    REG_FILE_COUNTER_CW <= cw[REG_FILE_COUNTER_CW_INDEX + 1 downto REG_FILE_COUNTER_CW_INDEX];
    SHORT_DELAY_COUNTER_CW <= cw[SHORT_DELAY_COUNTER_CW + 1 downto SHORT_DELAY_COUNTER_CW];
    LONG_DELAY_COUNTER_CW <= cw[LONG_DELAY_COUNTER_CW + 1 downto LONG_DELAY_COUNTER_CW];
    
    sw <= ALL_CHANNELS_HAVE_BEEN_READ_SW & SHORT_DELAY_DONE_SW & LONG_DELAY_DONE_SW;
    
end behavior;
