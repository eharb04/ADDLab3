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
use work.basicBuildingBlocks_package.ALL; -- Component entities

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
    signal REG_FILE_WRITE_CW: STD_LOGIC;
    signal regFileNum: STD_LOGIC_VECTOR (3 downto 0);
    signal shortCount: STD_LOGIC_VECTOR (7 downto 0);
    signal longCount: STD_LOGIC_VECTOR (23 downto 0);
    
begin
    REG_FILE_COUNTER_CW <= cw(REG_FILE_COUNTER_CW_INDEX + 1 downto REG_FILE_COUNTER_CW_INDEX);
    SHORT_DELAY_COUNTER_CW <= cw(SHORT_DELAY_COUNTER_CW_INDEX + 1 downto SHORT_DELAY_COUNTER_CW_INDEX);
    LONG_DELAY_COUNTER_CW <= cw(LONG_DELAY_COUNTER_CW_INDEX + 1 downto LONG_DELAY_COUNTER_CW_INDEX);
    REG_FILE_WRITE_CW <= cw(REG_FILE_WRITE_CW_BIT_INDEX);
    
    sw <= LONG_DELAY_DONE_SW & SHORT_DELAY_DONE_SW & ALL_CHANNELS_HAVE_BEEN_READ_SW;
    

    regFileNumCount: genericCounter
        GENERIC MAP(4)
        PORT MAP(clk => clk,
                 resetn => resetn,
                 c => REG_FILE_COUNTER_CW,
                 d => "00",
                 q => regFileNum
                 );

	regFileNumComp: genericCompare
        GENERIC MAP(4)
        PORT MAP(x => "0111",
                 y => regFileNum,
                 g => open,
                 l => open,
                 e => ALL_CHANNELS_HAVE_BEEN_READ_SW
                 );
                 
    shortCounter: genericCounter
        GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(clk => clk,
                 resetn => resetn,
                 c => SHORT_DELAY_COUNTER_CW,
                 d => "00",
                 q => shortCount
                 );

	shortComp: genericCompare
        GENERIC MAP(SHORT_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(x => shortCount,
                 y => SHORT_DELAY_50Mhz_COUNTS,
                 g => open,
                 l => open,
                 e => SHORT_DELAY_DONE_SW
                 );
                 
    longCounter: genericCounter
        GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(clk => clk,
                 resetn => resetn,
                 c => LONG_DELAY_COUNTER_CW,
                 d => "00",
                 q => longCount
                 );

	longComp: genericCompare
        GENERIC MAP(LONG_DELAY_50Mhz_CONST_WIDTH)
        PORT MAP(x => longCount,
                 y => LONG_DELAY_50Mhz_COUNTS,
                 g => open,
                 l => open,
                 e => LONG_DELAY_DONE_SW
                 );
                 
    regFile: generic8RegisterFile
        GENERIC MAP(16) --Data is 16 bits
        PORT MAP (clk => clk,
                  resetn => resetn,
                  write => REG_FILE_WRITE_CW,
                  wrAddr => regFileNum(2 downto 0),
                  rdAddr => rfAddr,
                  D => an7606data,
                  Q => rfData
                  );
                 
     

end behavior;
