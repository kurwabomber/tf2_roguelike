public Action Menu_FrontPage(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_FrontPage);

		SetMenuTitle(menu, "Roguelike - Shop");
		
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

		for(int i = 0;i < MAX_ITEMS_PER_WAVE; ++i){
			if(generatedPlayerItems[client][wave][i].id == ItemID_None)
				continue;

			Format(displayString, sizeof(displayString), "%s%s - $%i\n\t%s", generatedPlayerItems[client][wave][i].isBought ? "[x] " : "",
					generatedPlayerItems[client][wave][i].name, generatedPlayerItems[client][wave][i].cost,
					generatedPlayerItems[client][wave][i].description);
			AddMenuItem(menu, "item", displayString);
		}

		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}

public Action Menu_PowerupSelection(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_PowerupSelection);
		char displayString[64];
		SetMenuTitle(menu, "Roguelike - Select Starting Powerup");
		
		for(int i = 0;i <= POWERUPS_COUNT; ++i){
			Format(displayString, sizeof(displayString), "%s%s Powerup", i == powerupSelected[client] ? "[X] " : "", GetPowerupName(i));
			AddMenuItem(menu, "", displayString);
		}

		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}