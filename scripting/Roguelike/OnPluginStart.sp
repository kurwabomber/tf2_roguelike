public void OnPluginStart(){
    Handle hConf = LoadGameConfigFile("tf2.roguelike");

	Handle replaceUpgradeTouchHook = DHookCreateFromConf(hConf, "CUpgrades::UpgradeTouch()");
	
	if(!replaceUpgradeTouchHook)
		PrintToServer("Roguelike | Failed to get address for upgrade station hook.");
	DHookEnableDetour(replaceUpgradeTouchHook, false, OnEnterUpgradeStation);

	for (int i = 1; i <= MaxClients; ++i)
		if(IsValidClient(i))
			OnClientPutInServer(i);
}

//Do all of precaching in here
public void OnMapStart(){
	int entity = FindEntityByClassname(-1, "func_upgradestation");
	if (entity > -1)
		RemoveEntity(entity);
}

public OnPluginEnd(){
	for (int i = 1; i <= MaxClients; ++i)
		if(IsValidClient(i))
			OnClientDisconnect(i);
}