public Event_WaveComplete(Handle event, const char[] name, bool dontBroadcast){
	wavesCleared++;

	//todo: scale it based off max wave
	int itemsToGive = 7+(7*wavesCleared/totalWaveCount);
	ItemRarity highest = view_as<ItemRarity>(7*wavesCleared/totalWaveCount);
	ItemRarity lowest = view_as<ItemRarity>(4*wavesCleared/totalWaveCount);

	for(int client = 1;client<MaxClients;++client){
		ChooseGeneratedItems(client, wavesCleared, itemsToGive, lowest, highest);
		canteenCount[client] = amountOfItem[client][ItemID_Canteen];
		ChooseUltimateItems(client);
		savedCash[client] = GetEntProp(client, Prop_Send, "m_nCurrency");
	}
	isGameInPlay = false;
}
public Event_WaveBegin(Handle event, const char[] name, bool dontBroadcast){
	for(int client=1;client<MaxClients;++client){
		for(int i = 0; i<MAX_HELD_ITEMS;++i){
			savedPlayerItems[client][i] = playerItems[client][i];
		}
		for(int i =0; i<=loadedItems;++i){
			savedAmountOfItem[client][i] = amountOfItem[client][i];
		}
		canteenCount[client] = amountOfItem[client][ItemID_Canteen];
		savedCash[client] = GetEntProp(client, Prop_Send, "m_nCurrency");
	}
	isGameInPlay = true;
}
public Event_WaveFailed(Handle event, const char[] name, bool dontBroadcast){
	for(int client=1;client<MaxClients;++client){
		for(int i = 0; i<MAX_HELD_ITEMS;++i){
			playerItems[client][i] = savedPlayerItems[client][i];
		}
		for(int i =0; i<=loadedItems;++i){
			amountOfItem[client][i] = savedAmountOfItem[client][i];
		}
		canteenCount[client] = amountOfItem[client][ItemID_Canteen];
		if(savedCash[client])
			SetEntProp(client, Prop_Send, "m_nCurrency", savedCash[client]);
	}
	isGameInPlay = false;
}
public Event_ResetStats(Handle event, const char[] name, bool dontBroadcast){
	wavesCleared = 0;
	for(int client=1;client<MaxClients;++client){
		for(int i = 0; i<MAX_HELD_ITEMS;++i){
			playerItems[client][i].clear();
			savedPlayerItems[client][i].clear();
		}
		for(int i = 0; i<=loadedItems;++i){
			amountOfItem[client][i] = 0;
			timesItemGenerated[client][i] = 0;
		}
		canteenCount[client] = 0;
		canteenCooldown[client] = 0.0;
		amountHits[client] = 0;
		savedCash[client] = 0;
	}

	int logic = FindEntityByClassname(-1, "tf_objective_resource");
	if(IsValidEntity(logic))
		totalWaveCount = GetEntProp(logic, Prop_Send, "m_nMannVsMachineMaxWaveCount");

	isGameInPlay = false;
}

public Event_ChangeMission(Handle event, const char[] name, bool dontBroadcast){
	int logic = FindEntityByClassname(-1, "tf_objective_resource");
	if(IsValidEntity(logic))
		totalWaveCount = GetEntProp(logic, Prop_Send, "m_nMannVsMachineMaxWaveCount");
}

public Event_ChangeClass(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return;

	for(int i = 0; i<MAX_HELD_ITEMS;++i){
		if(playerItems[client][i].id == ItemID_None)
			continue;

		SetEntProp(client, Prop_Send, "m_nCurrency", GetEntProp(client, Prop_Send, "m_nCurrency") + playerItems[client][i].cost);
		--amountOfItem[client][playerItems[client][i].id];
		playerItems[client][i].clear();
		savedPlayerItems[client][i].clear();
	}
	for(int i = 0; i<MAX_WAVES;++i){
		for(int j = 0;j<MAX_ITEMS_PER_WAVE;++j){
			generatedPlayerItems[client][i][j].isBought = false;
		}
	}
	for(int j = 0;j<MAX_ITEMS_PER_WAVE;++j){
		generatedPlayerCanteenItems[client][j].isBought = false;
	}
	for(int i = 0;i<7;++i){
		--timesItemGenerated[client][generatedPlayerItems[client][0][i].id];
	}
	CancelClientMenu(client);

	CreateTimer(0.2, Timer_ChooseBeginnerItems, EntIndexToEntRef(client));
}

public Event_PlayerRespawn(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return;

	for(int buff = 0;buff < MAXBUFFS; ++buff){
		playerBuffs[client][buff].clear();
	}
	buffChange[client] = true;
	canteenCount[client] = amountOfItem[client][ItemID_Canteen];
	compoundInterestDuration[client] = 0.0;
	compoundInterestDamageTime[client] = 0.0;
	switchMedicalTargetTime[client] = 0.0;
	absorptionAmount[client] = 0.0;
	isExecuted[client] = false;
	for(int i = 1 ; i <= MaxClients; ++i){
		compoundInterestStacks[client][i] = 0;
	}

	if(IsFakeClient(client)){
		powerupSelected[client] = -1;
		float chance = float(wavesCleared+1)/totalWaveCount;
		if(GetRandomFloat() <= chance)
			powerupSelected[client] = GetRandomInt(Powerup_Strength, Powerup_Plague);
	}else{
		CreateTimer(0.2, Timer_GiveFullHealth, EntIndexToEntRef(client));
	}
	CancelClientMenu(client);

	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.5);
}

public Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast){
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(victim) || !IsPlayerAlive(victim))
		return;

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(attacker))
		return;

	int damage = GetEventInt(event, "damageamount");

	if(isKurwabombered[attacker][victim]){
		isKurwabombered[attacker][victim] = false;
		SDKHooks_TakeDamage(victim, attacker, attacker, 300.0, DMG_BLAST);
		if(attacker == victim){
			EmitSoundToAll(LARGE_EXPLOSION_SOUND, attacker, -1, 150, 0, 1.0);
		}
	}
	if(amountOfItem[attacker][ItemID_FlyingGuillotine] && !isExecuted[victim]){
		float pct = float(GetClientHealth(victim))/TF2Util_GetEntityMaxHealth(victim);
		if(pct > 0.0 && pct <= 0.2*amountOfItem[attacker][ItemID_FlyingGuillotine]){
			isExecuted[victim] = true;
			SDKHooks_TakeDamage(victim, attacker, attacker, 10.0*TF2Util_GetEntityMaxHealth(victim), DMG_GENERIC);
		}
	}
	if(amountOfItem[victim][ItemID_Martyr]){
		for(int i = 1; i <= MaxClients; ++i){
			if(!IsValidClient(i))
				continue;
			if(IsOnDifferentTeams(victim,i)) 
				continue;
			TF2_AddCondition(i, TFCond_RadiusHealOnDamage, 1.5, victim);
		}
	}
	float lifestealPct = 0.0;
	if(amountOfItem[attacker][ItemID_Leeches])
		lifestealPct += amountOfItem[attacker][ItemID_Leeches] * 0.1;
	if(amountOfItem[attacker][ItemID_CombatMedic])
		lifestealPct += amountOfItem[attacker][ItemID_CombatMedic] * 0.4;

	if(lifestealPct){
		AddPlayerHealth(attacker, RoundToCeil(damage*lifestealPct), 1.5, true, attacker);
		if(amountOfItem[attacker][ItemID_CombatMedic]){
			for(int i = 1;i <= MaxClients; ++i){
				if(!IsValidClient(i) || i == attacker)
					continue;
				if(!IsPlayerAlive(i))
					continue;
				if(IsOnDifferentTeams(attacker,i))
					continue;

				AddPlayerHealth(i, RoundToCeil(damage*lifestealPct), 1.5, true, attacker);
			}
		}
	}

	++amountHits[attacker];
}

public Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast){
	if(GetEventInt(event, "death_flags") & 32)
		return;

	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(victim))
		return;

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(attacker))
		return;

	if(amountOfItem[attacker][ItemID_Scavenger]) {
		TFClassType class = TF2_GetPlayerClass(attacker);
		for(int slot = 0; slot<3; slot++){
			int id = TF2Util_GetPlayerLoadoutEntity(attacker, slot);
			if(!IsValidWeapon(id))
				continue;
			if(!HasEntProp(id, Prop_Send, "m_iPrimaryAmmoType"))
				continue;
				
			int type = GetEntProp(id, Prop_Send, "m_iPrimaryAmmoType"); 
			if (type < 0 || type > 31)
				continue;
			
			int nextAmmo = GetEntProp(attacker, Prop_Send, "m_iAmmo", _, type) + RoundToCeil(0.03*TF2Util_GetPlayerMaxAmmo(attacker,type,class)*amountOfItem[attacker][ItemID_Scavenger]);
			if(nextAmmo > TF2Util_GetPlayerMaxAmmo(attacker,type,class))
				nextAmmo = TF2Util_GetPlayerMaxAmmo(attacker,type,class);

			SetEntProp(attacker, Prop_Send, "m_iAmmo", nextAmmo, _, type); 
		}
	}
	if(amountOfItem[attacker][ItemID_Absorption] && GetEntProp(victim, Prop_Send, "m_bIsMiniBoss"))
		addAbsorption(attacker, 0.2*TF2Util_GetEntityMaxHealth(attacker));

	if(!IsFakeClient(victim))
		CancelClientMenu(victim);
}

public Event_DeployBuff(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "buff_owner"));
	if(!IsValidClient(client))
		return;

	if(amountOfItem[client][ItemID_TeamTactics])
		++teamTacticsStacks[client];
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool& result){
	if(IsValidClient(client)){
		lastActivelyFiredTime[client] = currentGameTime;

		if(amountOfItem[client][ItemID_DecentlyBalanced])
			if(0.1 * amountOfItem[client][ItemID_DecentlyBalanced] >= GetRandomFloat(0.0,1.0))
				result = true;
		
		switch(TF2Attrib_HookValueInt(0, "override_projectile_type", weapon)){
			case TF_PROJECTILE_METEORSHOWER:{
				int iEntity = CreateEntityByName("tf_projectile_spellmeteorshower");
				if (IsValidEdict(iEntity)){
					int iTeam = GetClientTeam(client);
					float fAngles[3],fOrigin[3],vBuffer[3],fVelocity[3],fwd[3]
					SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
					SetEntProp(iEntity, Prop_Send, "m_iTeamNum", iTeam);
					GetClientEyeAngles(client, fAngles);
					GetClientEyePosition(client, fOrigin);
					GetAngleVectors(fAngles,fwd, NULL_VECTOR, NULL_VECTOR);
					ScaleVector(fwd, 30.0);
					AddVectors(fOrigin, fwd, fOrigin);
					GetAngleVectors(fAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
					
					float velocity = 1500.0;
					fVelocity[0] = vBuffer[0]*velocity;
					fVelocity[1] = vBuffer[1]*velocity;
					fVelocity[2] = vBuffer[2]*velocity;

					TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
					DispatchSpawn(iEntity);
					Phys_SetVelocity(iEntity, fVelocity, NULL_VECTOR, true);
				}
			}
		}
	}
	return Plugin_Changed;
}

public TF2_OnConditionAdded(int client, TFCond condition){
	if(IsValidClient(client)){
		switch(condition){
			case TFCond_Cloaked,TFCond_Disguised:{
				if(hasBuffIndex(client, Buff_IlluminatedDebuff))
					TF2_RemoveCondition(client, condition);
			}
		}
	}
}
public OnEntityCreated(entity, const char[] classname)
{
	if(!IsValidEdict(entity) || entity < 0 || entity > 2048)
		return;
	int reference = EntIndexToEntRef(entity);

	if(StrEqual(classname, "item_powerup_rune"))
		RemoveEntity(entity);
	if(StrEqual(classname, "tank_boss")){
		SDKHook(entity, SDKHook_OnTakeDamage, Tank_OnTakeDamage);
		RequestFrame(ApplyTankEffects, reference);
	}

	if(StrContains(classname, "obj_") == 0)
		SDKHook(entity, SDKHook_OnTakeDamage, Building_OnTakeDamage);

	if(StrContains(classname, "tf_projectile_") != -1){
		projectileBounces[entity] = 0;
		SDKHook(entity, SDKHook_StartTouch, OnStartBounceTouch);
	}
}