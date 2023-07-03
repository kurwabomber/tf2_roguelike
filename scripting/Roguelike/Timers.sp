public Action Timer_100MS(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++){
		if(!IsValidClient(i))
			continue;

		if(!IsPlayerAlive(i))
			continue;

		ManagePlayerBuffs(i);

		if(powerupSelected[i] != -1)
			TF2_AddCondition(i, GetPowerupCondFromID(powerupSelected[i]), 0.3);
	}
	return Plugin_Continue;
}