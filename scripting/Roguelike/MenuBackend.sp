public MenuHandler_FrontPage(Handle menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		if(param2 == 0){
			Menu_PowerupSelection(client);
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
		
	}
    if (action == MenuAction_End)
        CloseHandle(menu);
}