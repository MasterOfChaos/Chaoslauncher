-- ##### Variables #####
-- Player.Minerals
-- Player.Vespine
-- Player.Supply
-- Player.Psy
-- Player.Control - Can be *.5 when number of terrors/lings is odd
-- Player.MaxSupply
-- Player.MaxPsy
-- Player.MaxControl
-- Player.Population - Number of all Units
-- Player.PopulationBuilding - Number of Units building
-- Player.Larva - Number of Larva the player owns
-- Player.Race - "Z"=Zerg, "T"=Terran, "P"=Protoss
-- Game.Time - Time since gamestart in Frames
-- Game.SecondsFastest - Time since gamestart in seconds assuming fastest speed, can be fractional (SecondsFastest=Time*0.042)

-- ##### Functions #####
-- function Sound(Name) - Plays sound directly
-- function Sound(Name,Delay) - Play this sound only if Delay Seconds have passed since the last time
-- function TextOut(Text) - Not yet implemented
-- function MessageBox(Text)

-- ##### Entrypoints #####
-- function StartGame()
-- function Timer()
-- function EndGame()

include("terran");
include("protoss");
include("zerg");

function Timer()
	if Player.Race=="T" then TerranTimer();end;
	if Player.Race=="P" then ProtossTimer();end;
	if Player.Race=="Z" then ZergTimer();end;
	LastPlayer=Player;
	Player=nil;
end;

function StartGame()
	LastPlayer={};
	Sound('Init');
end;

function EndGame()
	Sound('Finish');
end;