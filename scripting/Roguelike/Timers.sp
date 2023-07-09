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

		switch(powerupSelected[i]){
			case Powerup_Regeneration:{
				if(GetClientHealth(i) < TF2Util_GetEntityMaxHealth(i)){
					TF2Util_TakeHealth(i, 3.0);
				}
			}
			case Powerup_Knockout:{
				TF2_AddCondition(i, TFCond_RestrictToMelee, 0.3);
				int melee = TF2Util_GetPlayerLoadoutEntity(i, 2);
				if(IsValidWeapon(melee))
					TF2Util_SetPlayerActiveWeapon(i, melee);
			}
		}
	}
	return Plugin_Continue;
}
public Action Timer_10S(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++){
		if(!IsValidClient(i))
			continue;

		if(!IsPlayerAlive(i))
			continue;

		switch(powerupSelected[i]){
			//Refill ammo for regeneration powerup
			case Powerup_Regeneration:{
				TFClassType class = TF2_GetPlayerClass(i);
				for(int slot = 0; slot<3; slot++){
					int id = TF2Util_GetPlayerLoadoutEntity(i, slot);
					if(!IsValidWeapon(id))
						continue;

					int type = GetEntProp(id, Prop_Send, "m_iPrimaryAmmoType"); 
					if (type < 0 || type > 31)
						continue;
					
					SetEntProp(i, Prop_Send, "m_iAmmo", TF2Util_GetPlayerMaxAmmo(i,type,class), _, type); 
				}
			}
		}
	}
	return Plugin_Continue;
}