function TerranSupplyWarnings()
	local low,critical;
	low=-1000;critical=-1000;
	if (Player.MaxSupply==10)then low=2;critical=0;end; 
	if (Player.MaxSupply>10)and(Player.MaxSupply<=18)then low=3;critical=1;end;
	if (Player.MaxSupply>18)and(Player.MaxSupply<=26)then low=4;critical=2;end;
	if (Player.MaxSupply>26)and(Player.MaxSupply<=34)then low=6;critical=3;end;
	if (Player.MaxSupply>34)and(Player.MaxSupply<200)then low=8;critical=4;end;

	if (Player.MaxSupply-Player.Supply<=low)and(Player.MaxSupply-Player.Supply>critical)then Sound('SupplyLow',10);end;
	if (Player.MaxSupply-Player.Supply<=critical)then Sound('SupplyCritical',10);end;
end;

function TerranMoreUnitWarnings()
	if (Player.MaxSupply-Player.Supply<=1)then return;end;
	if (Player.PopulationBuilding>0)then return;end;
	if (Player.Minerals>=200)and(Player.Supply<20)then Sound('MoreUnits',10);end;
	if (Player.Minerals>=200)and(Player.Supply<30)then Sound('MoreUnits',15);end;
	if (Player.Minerals>=400)and(Player.Vespine>=200)then Sound('MoreUnits',30);end;
end;

function DepotReadyNotification()
	if (LastPlayer.MaxSupply~=nil)and(Player.MaxSupply>LastPlayer.MaxSupply)then Sound('DepotReady');end;
end;

function TerranTimer()
	TerranSupplyWarnings();
	TerranMoreUnitWarnings(); 
	DepotReadyNotification();
end;