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
			Buff illuminatedDebuff;
			illuminatedDebuff.init("Illuminated", "Cannot cloak/disguise", Buff_IlluminatedDebuff, 1, client, 30.0 * amountOfItem[client][ItemID_IlluminationCanteen]);
			for(int i = 1; i <= MaxClients; ++i){
				if(!IsValidClient(i))
					continue;
				if(!IsOnDifferentTeams(client, i))
					continue;

				TF2_RemoveCondition(i, TFCond_Cloaked);
				TF2_RemoveCondition(i, TFCond_Disguised);
				insertBuff(i, illuminatedDebuff);
				SetEntProp(i, Prop_Send, "m_bGlowEnabled", 1);
			}
		}

		if(amountOfItem[client][ItemID_WardingCanteen]){
			Buff defenseBonus;
			defenseBonus.init("Defense Bonus", "Prevents instantkills", Buff_DefenseBuff, 1, client, 16.0 * amountOfItem[client][ItemID_WardingCanteen]);
			defenseBonus.multiplicativeDamageTaken = 0.5;
			insertBuff(client, defenseBonus);
			TF2_AddCondition(client, TFCond_PreventDeath, 16.0 * amountOfItem[client][ItemID_WardingCanteen], client);
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
public MRESReturn OnBlastExplosion(int entity, Handle hReturn){
	if(!IsValidEntity(entity))
		return MRES_Ignored;

	int owner = getOwner(entity);
	if(!IsValidClient(owner))
		return MRES_Ignored;

	if(amountOfItem[owner][ItemID_FraggyExplosives]){
		for(int i = 0;i<3*amountOfItem[owner][ItemID_FraggyExplosives];++i)
		{
			int iEntity = CreateEntityByName("tf_projectile_syringe");
			if (!IsValidEdict(iEntity)) 
				continue;

			int iTeam = GetClientTeam(owner);
			float fAngles[3],fOrigin[3],vBuffer[3]
			float fVelocity[3]
			float fwd[3]
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", owner);
			SetEntProp(iEntity, Prop_Send, "m_iTeamNum", iTeam);
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", fOrigin);
			fAngles[0] = GetRandomFloat(0.0,-60.0)
			fAngles[1] = GetRandomFloat(-179.0,179.0)

			GetAngleVectors(fAngles,fwd, NULL_VECTOR, NULL_VECTOR);
			ScaleVector(fwd, 30.0);
			
			AddVectors(fOrigin, fwd, fOrigin);
			GetAngleVectors(fAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
			
			float velocity = 2000.0;
			fVelocity[0] = vBuffer[0]*velocity;
			fVelocity[1] = vBuffer[1]*velocity;
			fVelocity[2] = vBuffer[2]*velocity;
			
			TeleportEntity(iEntity, fOrigin, fAngles, fVelocity);
			DispatchSpawn(iEntity);
			SetEntityGravity(iEntity, 9.0);
			SDKHook(iEntity, SDKHook_Touch, CollisionFrag);
			SetEntPropFloat(iEntity, Prop_Send, "m_flModelScale", 1.8);

			float vecBossMin[3], vecBossMax[3];
			GetEntPropVector(iEntity, Prop_Send, "m_vecMins", vecBossMin);
			GetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", vecBossMax);
			
			float vecScaledBossMin[3], vecScaledBossMax[3];
			
			vecScaledBossMin = vecBossMin;
			vecScaledBossMax = vecBossMax;

			vecScaledBossMin[0] -= 3.0;
			vecScaledBossMax[0] += 3.0;
			vecScaledBossMin[1] -= 3.0;
			vecScaledBossMax[1] += 3.0;
			vecScaledBossMin[2] -= 3.0;
			vecScaledBossMax[2] += 3.0;
			
			
			SetEntPropVector(iEntity, Prop_Send, "m_vecMins", vecScaledBossMin);
			SetEntPropVector(iEntity, Prop_Send, "m_vecMaxs", vecScaledBossMax);

			CreateTimer(1.0,SelfDestruct,EntIndexToEntRef(iEntity));
		}
	}

	return MRES_Ignored;
}
public MRESReturn OnAddCurrency(int client, Handle hParams){
	if(!IsValidClient(client))
		return MRES_Ignored;

	int add = DHookGetParam(hParams, 1);
	int current = GetEntProp(client, Prop_Send, "m_nCurrency");
	if(amountOfItem[client][ItemID_AustraliumAlchemist] > 0)
		add = RoundToCeil(add*(1.0+0.15*amountOfItem[client][ItemID_AustraliumAlchemist]));
	SetEntProp(client, Prop_Send, "m_nCurrency", add+current);

	return MRES_Supercede;
}

public MRESReturn OnDamageModifyRules(Address pGameRules, Handle hReturn, Handle hParams) {
	int victim = DHookGetParam(hParams, 2);
	if(hasBuffIndex(victim,Buff_VulnerableDebuff))
		DHookSetParam(hParams, 3, true);
	return MRES_ChangedHandled;
}