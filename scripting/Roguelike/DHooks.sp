public MRESReturn OnDropPowerup(int client, Handle hParams){
	if(!IsValidClient(client))
		return MRES_Ignored;

	if(!DHookGetParam(hParams, 1)){
		return MRES_Supercede;
	}
	return MRES_Ignored;
}

public MRESReturn OnUseCanteen(int canteen, Handle hReturn){
	if(!IsValidEntity(canteen))
		return MRES_Ignored;

	int client = getOwner(canteen);
	if(!IsValidClient(client) || !IsPlayerAlive(client))
		return MRES_Ignored;

	if(GetEntPropFloat(client, Prop_Send, "m_flRuneCharge") >= 100.0){
		EmitSoundToAll("items/powerup_pickup_supernova_activate.wav", client, -1, 150, 0, 1.0);
		
		int iTeam = GetClientTeam(client);
		CreateParticle(client, iTeam == 2 ? "powerup_supernova_explode_red" : "powerup_supernova_explode_blue", false, "", 1.0);
		float clientpos[3];
		GetClientEyePosition(client,clientpos);
		int i = -1;
		while ((i = FindEntityByClassname(i, "*")) != -1)
		{
			if(!IsValidForDamage(i))
				continue;
			if(!IsOnDifferentTeams(client,i))
				continue;
			
			float VictimPos[3];
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", VictimPos);
			VictimPos[2] += 30.0;
			float Distance = GetVectorDistance(clientpos,VictimPos);
			if(Distance > 800.0)
				continue;

			if(IsValidClient(i))
			{
				TF2_StunPlayer(i, 6.0, 1.0, TF_STUNFLAGS_NORMALBONK, client);
			}
			else if(HasEntProp(i,Prop_Send,"m_hBuilder"))
			{
				SetEntProp(i, Prop_Send, "m_bDisabled", 1);
				CreateTimer(10.0, ReEnableBuilding, EntIndexToEntRef(i));
			}
		}

		SetEntPropFloat(client, Prop_Send, "m_flRuneCharge", 0.0);
	}else if(canteenCooldown[client] <= GetGameTime()){
		//Canteens!
		if(canteenCount[client] <= 0)
			return MRES_Ignored;
		
		if(amountOfItem[client][ItemID_UberchargeCanteen])
			TF2_AddCondition(client, TFCond_UberchargedCanteen, 6.0 * amountOfItem[client][ItemID_UberchargeCanteen]);

		if(amountOfItem[client][ItemID_KritzCanteen])
			TF2_AddCondition(client, TFCond_CritCanteen, 6.0 * amountOfItem[client][ItemID_KritzCanteen]);

		if(amountOfItem[client][ItemID_IlluminationCanteen]){
			
		}

		if(amountOfItem[client][ItemID_WardingCanteen]){
			
		}

		if(amountOfItem[client][ItemID_CollectionCanteen]){
			int i = -1;
			float pos[3];
			GetClientAbsOrigin(client, pos);

			while ((i = FindEntityByClassname(i, "item_currencypack_custom")) != -1){
				TeleportEntity(i, pos);
			}
		}

		EmitSoundToAll("mvm/mvm_used_powerup.wav", client, -1, 150, 0, 1.0);

		--canteenCount[client];
		canteenCooldown[client] = GetGameTime()+6.0;
	}
						
	return MRES_Ignored;
}

public MRESReturn OnAddCurrency(int client, Handle hParams){
	if(!IsValidClient(client))
		return MRES_Ignored;

	int add = DHookGetParam(hParams, 1);
	int current = GetEntProp(client, Prop_Send, "m_nCurrency");
	SetEntProp(client, Prop_Send, "m_nCurrency", add+current);

	return MRES_Supercede;
}