public OnClientPutInServer(int client){
    if(!isHooked[client]){
        isHooked[client] = true;
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    }
	for(int i = 0; i<MAX_HELD_ITEMS;++i){
		playerItems[client][i].clear();
		savedPlayerItems[client][i].clear();
	}
	for(int i = 0; i<=loadedItems;++i){
		timesItemGenerated[client][i] = 0;
	}
	canteenCount[client] = 0;
}
public OnClientDisconnect(client){
	if(isHooked[client]){
		isHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
	powerupSelected[client] = -1
}