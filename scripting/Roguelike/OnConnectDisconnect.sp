public OnClientPutInServer(int client){
    if(!isHooked[client]){
        isHooked[client] = true;
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
    }
}
public OnClientDisconnect(client){
	if(isHooked[client]){
		isHooked[client] = false;
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKUnhook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	}
}