public void OnPluginStart(){
	//Gamedata
    Handle hConf = LoadGameConfigFile("tf2.roguelike");

	Handle PowerupDropHook = DHookCreateFromConf(hConf, "CTFPlayer::DropRune()");
	if(!PowerupDropHook)
		PrintToServer("Roguelike | Error with \"CTFPlayer::DropRune()\" gamedata.");
	DHookEnableDetour(PowerupDropHook, false, OnDropPowerup);

	//Timers
	CreateTimer(0.1, Timer_100MS, _, TIMER_REPEAT);
	CreateTimer(10.0, Timer_10S, _, TIMER_REPEAT);

	//Event Hooks
	HookEvent("mvm_wave_complete", Event_WaveComplete);
	HookEvent("mvm_begin_wave", Event_WaveBegin);
	HookEvent("mvm_reset_stats", Event_ResetStats);

	//Refresh Players
	for (int i = 1; i <= MaxClients; ++i)
		if(IsValidClient(i))
			OnClientPutInServer(i);
}

//Do all of precaching in here
public void OnMapStart(){
	int entity = -1;
	while( (entity = FindEntityByClassname(entity, "func_upgradestation")) != -1){
		SDKHook(entity, SDKHook_StartTouch, OnCollideUpgrade);
		SDKHook(entity, SDKHook_EndTouch, OnStopCollideUpgrade);
		SDKHook(entity, SDKHook_Touch, FullStopCollision);
	}
}

public OnPluginEnd(){
	for (int i = 1; i <= MaxClients; ++i)
		if(IsValidClient(i))
			OnClientDisconnect(i);
}