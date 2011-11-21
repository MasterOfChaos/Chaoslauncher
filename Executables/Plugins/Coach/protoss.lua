function ProtossPsyWarnings()
	local low,critical;
	low=-1000;critical=-1000;
	if (Player.MaxPsy==9)then low=2;critical=0;end; 
	if (Player.MaxPsy>9)and(Player.MaxPsy<=17)then low=3;critical=1;end;
	if (Player.MaxPsy>17)and(Player.MaxPsy<=25)then low=4;critical=2;end;
	if (Player.MaxPsy>25)and(Player.MaxPsy<=33)then low=6;critical=3;end;
	if (Player.MaxPsy>33)and(Player.MaxPsy<200)then low=8;critical=4;end;

	if (Player.MaxPsy-Player.Psy<=low)and(Player.MaxPsy-Player.Psy>critical)then Sound('SupplyLow',10);end;
	if (Player.MaxPsy-Player.Psy<=critical)then Sound('SupplyCritical',10);end;
end;

function ProtossMoreUnitWarnings()
	if (Player.MaxPsy-Player.Psy<=1)then return;end;
	if (Player.PopulationBuilding>0)then return;end;
	if (Player.Minerals>=200)and(Player.Psy<20)then Sound('MoreUnits',10);end;
	if (Player.Minerals>=200)and(Player.Psy<30)then Sound('MoreUnits',15);end;
	if (Player.Minerals>=400)and(Player.Vespine>=200)then Sound('MoreUnits',30);end;
end;

function PylonReadyNotification()
	if (LastPlayer.MaxPsy~=nil)and(Player.MaxPsy>LastPlayer.MaxPsy)then Sound('DepotReady');end;
end;

function ProtossTimer()
	ProtossPsyWarnings();
	ProtossMoreUnitWarnings();
	PylonReadyNotification();
end;