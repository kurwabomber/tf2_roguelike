public Action Menu_FrontPage(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_FrontPage);

		SetMenuTitle(menu, "Roguelike - Shop");
		
		char displayString[32];
		AddMenuItem(menu, "", "Powerup Selection");
		AddMenuItem(menu, "", "Ultimate Items Unlocked");
		AddMenuItem(menu, "", "Canteen Power Shop");
		AddMenuItem(menu, "", "Pre-Game Shop");

		for(int i = 1;i <= wavesCleared; ++i){
			Format(displayString, sizeof(displayString), "Wave #%i Shop", i);
			AddMenuItem(menu, "", displayString);
		}
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}

public Action Menu_CanteenShop(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_CanteenShop);
		char displayString[512];
		Format(displayString, sizeof(displayString), "Roguelike - Canteen Power Shop");
		SetMenuTitle(menu, displayString);

		for(int i = 0;i < MAX_ITEMS_PER_WAVE; ++i){
			if(generatedPlayerCanteenItems[client][i].id == ItemID_None)
				continue;

			Format(displayString, sizeof(displayString), "%s%s - $%i | %s\n %s", generatedPlayerCanteenItems[client][i].isBought ? "[x] " : "",
					generatedPlayerCanteenItems[client][i].name, generatedPlayerCanteenItems[client][i].cost, RarityToString(generatedPlayerCanteenItems[client][i].rarity),
					generatedPlayerCanteenItems[client][i].description);
			AddMenuItem(menu, "item", displayString);
		}
		SetMenuPagination(menu, 5);
		SetMenuExitBackButton(menu, true);
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action Menu_UltimateItems(client, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_UltimateItem);
		char displayString[512];
		Format(displayString, sizeof(displayString), "Roguelike - Ultimate Items Shop");
		SetMenuTitle(menu, displayString);

		int itemsShown = 0;
		for(int i = 0;i < MAX_ITEMS_PER_WAVE; ++i){
			if(generatedPlayerUltimateItems[client][i].id == ItemID_None)
				continue;

			Format(displayString, sizeof(displayString), "%s%s - $%i | %s\n %s", generatedPlayerUltimateItems[client][i].isBought ? "[x] " : "",
					generatedPlayerUltimateItems[client][i].name, generatedPlayerUltimateItems[client][i].cost, RarityToString(generatedPlayerUltimateItems[client][i].rarity),
					generatedPlayerUltimateItems[client][i].description);
			AddMenuItem(menu, "item", displayString);
			++itemsShown;
		}

		if(!itemsShown){
			PrintToChat(client, "Looks like there aren't any ultimate items you've discovered.");
		}
		SetMenuPagination(menu, 5);
		SetMenuExitBackButton(menu, true);
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
	}
	return Plugin_Handled;
}

public Action Menu_WaveShop(client, wave, item){
	if(IsValidClient(client) && IsPlayerAlive(client)){
		Handle menu = CreateMenu(MenuHandler_WaveShop);
		char displayString[512];
		Format(displayString, sizeof(displayString), "Roguelike - Wave #%i Rewards Shop", wave);
		SetMenuTitle(menu, displayString);

		for(int i = 0;i < MAX_ITEMS_PER_WAVE; ++i){
			if(generatedPlayerItems[client][wave][i].id == ItemID_None)
				continue;

			Format(displayString, sizeof(displayString), "%s%s - $%i | %s\n %s", generatedPlayerItems[client][wave][i].isBought ? "[x] " : "",
					generatedPlayerItems[client][wave][i].name, generatedPlayerItems[client][wave][i].cost, RarityToString(generatedPlayerItems[client][wave][i].rarity),
					generatedPlayerItems[client][wave][i].description);
			AddMenuItem(menu, "item", displayString);
		}
		SetMenuPagination(menu, 5);
		SetMenuExitBackButton(menu, true);
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER);
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
		SetMenuExitBackButton(menu, true);
		DisplayMenuAtItem(menu, client, item, MENU_TIME_FOREVER)
	}
	return Plugin_Handled;
}