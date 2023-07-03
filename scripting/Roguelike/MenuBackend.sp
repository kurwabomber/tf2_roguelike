public MenuHandler_FrontPage(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		if(param2 == 0){
			Menu_PowerupSelection(client, 0);
		}else{
		Menu_WaveShop(client, param2-1, 0);
		}
	}
    if (action == MenuAction_End)
        CloseHandle(menu);
}

public MenuHandler_WaveShop(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){

	}
    if (action == MenuAction_End)
        CloseHandle(menu);
}

public MenuHandler_PowerupSelection(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		if(param2 == powerupSelected[client]){
			powerupSelected[client] = -1;
			ClearAllPowerups(client);
		}else{
			powerupSelected[client] = param2;
			ClearAllPowerups(client);
			TF2_AddCondition(client, GetPowerupCondFromID(param2), TFCondDuration_Infinite);
		}
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01); //Refreshes speed calc
		Menu_PowerupSelection(client, GetMenuPagination(menu)*(param2/GetMenuPagination(menu)));
	}
    if (action == MenuAction_End)
        CloseHandle(menu);
}