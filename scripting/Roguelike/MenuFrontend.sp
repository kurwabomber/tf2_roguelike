public Action Menu_FrontPage(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_FrontPage);

		SetMenuTitle(menu, "Roguelike - Wave View");
		
		char displayString[32];
		AddMenuItem(menu, "", "Powerup Selection");
		AddMenuItem(menu, "", "Pre-Game Shop");

		for(int i = 1;i <= wavesCleared; ++i){
			Format(displayString, sizeof(displayString), "Wave #%i Shop", i);
			AddMenuItem(menu, "", displayString);
		}
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}

public Action Menu_WaveShop(client, wave, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_WaveShop);
		char displayString[64];
		Format(displayString, sizeof(displayString), "Roguelike - Wave #%i Rewards Shop", wave);
		SetMenuTitle(menu, displayString);
		
		for(int i = 0;i < 5; ++i){
			Format(displayString, sizeof(displayString), "randomShit");
			AddMenuItem(menu, "", displayString);
		}

		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}

public Action Menu_PowerupSelection(client){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_PowerupSelection);
		char displayString[64];
		SetMenuTitle(menu, "Roguelike - Select Starting Powerup");
		
		for(int i = 0;i < 5; ++i){
			Format(displayString, sizeof(displayString), "randomShit");
			AddMenuItem(menu, "", displayString);
		}

		DisplayMenuAtItem(menu, client, 0, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}