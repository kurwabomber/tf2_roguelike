public Action Timer_100MS(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++){
		if(!IsValidClient(i))
			continue;

		ManagePlayerBuffs(i);
	}
	return Plugin_Continue;
}