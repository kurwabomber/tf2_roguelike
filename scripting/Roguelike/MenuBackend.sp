public MenuHandler_FrontPage(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		if(param2 == 0){
			Menu_PowerupSelection(client, 0);
		}else if(param2 == 1){
			Menu_UltimateItems(client, 0);
		}else if(param2 == 2){
			Menu_CanteenShop(client, 0);
		}else{
		Menu_WaveShop(client, param2-3, 0);
		currentWaveViewed[client] = param2-3;
		}
	}
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public MenuHandler_CanteenShop(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		int current = GetEntProp(client, Prop_Send, "m_nCurrency");
		if(generatedPlayerCanteenItems[client][param2].isBought){
			PrintToChat(client, "You sold %s for $%i.", generatedPlayerCanteenItems[client][param2].name, generatedPlayerCanteenItems[client][param2].cost);
			generatedPlayerCanteenItems[client][param2].isBought = false;
			playerItems[client][getFirstIDItemSlot(client, generatedPlayerCanteenItems[client][param2].id)].clear();
			SetEntProp(client, Prop_Send, "m_nCurrency", current+generatedPlayerCanteenItems[client][param2].cost);
			--amountOfItem[client][generatedPlayerCanteenItems[client][param2].id]; 
			buffChange[client] = true;
		}
		else if(current >= generatedPlayerCanteenItems[client][param2].cost){
			PrintToChat(client, "You bought %s for $%i.", generatedPlayerCanteenItems[client][param2].name, generatedPlayerCanteenItems[client][param2].cost);
			generatedPlayerCanteenItems[client][param2].isBought = true;
			playerItems[client][getFirstEmptyItemSlot(client)] = generatedPlayerCanteenItems[client][param2];
			SetEntProp(client, Prop_Send, "m_nCurrency", current-generatedPlayerCanteenItems[client][param2].cost);
			++amountOfItem[client][generatedPlayerCanteenItems[client][param2].id]; 
			buffChange[client] = true;
		}else{
			PrintToChat(client, "You cannot afford %s.", generatedPlayerCanteenItems[client][param2].name);
		}
		Menu_CanteenShop(client, GetMenuPagination(menu)*(param2/GetMenuPagination(menu)));
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		Menu_FrontPage(client, 0);
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public MenuHandler_UltimateItem(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		int current = GetEntProp(client, Prop_Send, "m_nCurrency");
		if(generatedPlayerUltimateItems[client][param2].isBought){
			PrintToChat(client, "You sold %s for $%i.", generatedPlayerUltimateItems[client][param2].name, generatedPlayerUltimateItems[client][param2].cost);
			generatedPlayerUltimateItems[client][param2].isBought = false;
			playerItems[client][getFirstIDItemSlot(client, generatedPlayerUltimateItems[client][param2].id)].clear();
			SetEntProp(client, Prop_Send, "m_nCurrency", current+generatedPlayerUltimateItems[client][param2].cost);
			--amountOfItem[client][generatedPlayerUltimateItems[client][param2].id]; 
			buffChange[client] = true;
		}
		else if(current >= generatedPlayerUltimateItems[client][param2].cost){
			PrintToChat(client, "You bought %s for $%i.", generatedPlayerUltimateItems[client][param2].name, generatedPlayerUltimateItems[client][param2].cost);
			generatedPlayerUltimateItems[client][param2].isBought = true;
			playerItems[client][getFirstEmptyItemSlot(client)] = generatedPlayerUltimateItems[client][param2];
			SetEntProp(client, Prop_Send, "m_nCurrency", current-generatedPlayerUltimateItems[client][param2].cost);
			++amountOfItem[client][generatedPlayerUltimateItems[client][param2].id]; 
			buffChange[client] = true;
		}else{
			PrintToChat(client, "You cannot afford %s.", generatedPlayerUltimateItems[client][param2].name);
		}
		Menu_UltimateItems(client, GetMenuPagination(menu)*(param2/GetMenuPagination(menu)));
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		Menu_FrontPage(client, 0);
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public MenuHandler_WaveShop(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		int current = GetEntProp(client, Prop_Send, "m_nCurrency");
		if(generatedPlayerItems[client][currentWaveViewed[client]][param2].isBought){
			PrintToChat(client, "You sold %s for $%i.", generatedPlayerItems[client][currentWaveViewed[client]][param2].name, generatedPlayerItems[client][currentWaveViewed[client]][param2].cost);
			generatedPlayerItems[client][currentWaveViewed[client]][param2].isBought = false;
			playerItems[client][getFirstIDItemSlot(client, generatedPlayerItems[client][currentWaveViewed[client]][param2].id)].clear();
			SetEntProp(client, Prop_Send, "m_nCurrency", current+generatedPlayerItems[client][currentWaveViewed[client]][param2].cost);
			--amountOfItem[client][generatedPlayerItems[client][currentWaveViewed[client]][param2].id]; 
			buffChange[client] = true;
		}
		else if(current >= generatedPlayerItems[client][currentWaveViewed[client]][param2].cost){
			PrintToChat(client, "You bought %s for $%i.", generatedPlayerItems[client][currentWaveViewed[client]][param2].name, generatedPlayerItems[client][currentWaveViewed[client]][param2].cost);
			generatedPlayerItems[client][currentWaveViewed[client]][param2].isBought = true;
			playerItems[client][getFirstEmptyItemSlot(client)] = generatedPlayerItems[client][currentWaveViewed[client]][param2];
			SetEntProp(client, Prop_Send, "m_nCurrency", current-generatedPlayerItems[client][currentWaveViewed[client]][param2].cost);
			++amountOfItem[client][generatedPlayerItems[client][currentWaveViewed[client]][param2].id]; 
			buffChange[client] = true;
		}else{
			PrintToChat(client, "You cannot afford %s.", generatedPlayerItems[client][currentWaveViewed[client]][param2].name);
		}
		Menu_WaveShop(client, currentWaveViewed[client], GetMenuPagination(menu)*(param2/GetMenuPagination(menu)));
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		Menu_FrontPage(client, 7*((currentWaveViewed[client]+3)/7) );
	if (action == MenuAction_End)
		CloseHandle(menu);
}

public MenuHandler_PowerupSelection(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		float hpRatio = float(GetClientHealth(client))/TF2Util_GetEntityMaxHealth(client);
		if(param2 == powerupSelected[client]){
			powerupSelected[client] = -1;
			ClearAllPowerups(client);
		}else{
			powerupSelected[client] = param2;
			ClearAllPowerups(client);
			TF2_AddCondition(client, GetPowerupCondFromID(param2), TFCondDuration_Infinite);
		}
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01); //Refreshes speed calc
		SetEntityHealth(client, RoundToNearest(hpRatio*TF2Util_GetEntityMaxHealth(client)));
		buffChange[client] = true;
		Menu_PowerupSelection(client, GetMenuPagination(menu)*(param2/GetMenuPagination(menu)));
	}
	else if(action == MenuAction_Cancel && param2 == MenuCancel_ExitBack)
		Menu_FrontPage(client, 0);
	if (action == MenuAction_End)
		CloseHandle(menu);
}