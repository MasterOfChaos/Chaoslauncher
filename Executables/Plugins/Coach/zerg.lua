function ZergControlWarnings()
	local low,critical;
	low=-1000;critical=-1000;
	if (Player.MaxControl==9)then low=2;critical=0;end; 
	if (Player.MaxControl>9)and(Player.MaxControl<=17)then low=3;critical=1;end;
	if (Player.MaxControl>17)and(Player.MaxControl<=25)then low=4;critical=2;end;
	if (Player.MaxControl>25)and(Player.MaxControl<=33)then low=6;critical=3;end;
	if (Player.MaxControl>33)and(Player.MaxControl<200)then low=8;critical=4;end;

	if (Player.MaxControl-Player.Control<=low)and(Player.MaxControl-Player.Control>critical)then Sound('SupplyLow',10);end;
	if (Player.MaxControl-Player.Control<=critical)then Sound('SupplyCritical',10);end;
end;

function ZergMoreUnitWarnings()
	if (Player.MaxControl-Player.Control<=1)then return;end;
	if (Player.Larva==0)then return;end;
	if (Player.Minerals>=200)and(Player.Control<20)then Sound('MoreUnits',10);end;
	if (Player.Minerals>=200)and(Player.Control<30)then Sound('MoreUnits',15);end;
	if (Player.Minerals>=400)and(Player.Vespine>=200)then Sound('MoreUnits',30);end;
end;

function PylonReadyNotification()
	if (LastPlayer.MaxControl~=nil)and(Player.MaxControl>LastPlayer.MaxControl)then Sound('DepotReady');end;
end;

function ZergTimer()
	ZergControlWarnings();
	ZergMoreUnitWarnings();
	PylonReadyNotification();
end;