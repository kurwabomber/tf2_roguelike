public Event_WaveComplete(Handle event, const char[] name, bool dontBroadcast){
    wavesCleared++;

	for(int client = 1;client<MaxClients;++client){
		ChooseGeneratedItems(client, wavesCleared, 4+wavesCleared);
	}
}
public Event_WaveBegin(Handle event, const char[] name, bool dontBroadcast){
	for(int client=1;client<MaxClients;++client){
		for(int i = 0; i<MAX_HELD_ITEMS;++i){
			savedPlayerItems[client][i] = playerItems[client][i];
		}
	}
}
public Event_ResetStats(Handle event, const char[] name, bool dontBroadcast){
    wavesCleared = 0;
	for(int client=1;client<MaxClients;++client){
		for(int i = 0; i<MAX_HELD_ITEMS;++i){
			playerItems[client][i].clear();
			savedPlayerItems[client][i].clear();
		}
	}
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
	for(int i = 0;i<7;++i){
		--timesItemGenerated[client][generatedPlayerItems[client][0][i].id];
	}

	//Choose 7 items before game start. Make sure this runs after all loadout changes.
	CreateTimer(0.1, Timer_ChooseBeginnerItems, EntIndexToEntRef(client));
}

public Event_PlayerRespawn(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(client))
		return;

	for(int buff = 0;buff < MAXBUFFS; ++buff){
		playerBuffs[client][buff].clear();
	}
	buffChange[client] = true;
}

public Event_PlayerHurt(Handle event, const char[] name, bool dontBroadcast){
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(victim))
		return;

	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!IsValidClient(attacker))
		return;

	if(isKurwabombered[attacker][victim]){
		isKurwabombered[attacker][victim] = false;
		SDKHooks_TakeDamage(victim, attacker, attacker, 1500.0, DMG_BLAST);
	}
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

	for(int item=0;item<=loadedItems;++item){
		if(amountOfItem[attacker][item] <= 0)
			continue;
		
		switch(item){
			case (_:ItemID_Scavenger):{
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
					
					int nextAmmo = GetEntProp(attacker, Prop_Send, "m_iAmmo", _, type) + 1 + RoundToCeil(0.05*TF2Util_GetPlayerMaxAmmo(attacker,type,class)*amountOfItem[attacker][item]);
					if(nextAmmo > TF2Util_GetPlayerMaxAmmo(attacker,type,class))
						nextAmmo = TF2Util_GetPlayerMaxAmmo(attacker,type,class);

					SetEntProp(attacker, Prop_Send, "m_iAmmo", nextAmmo, _, type); 
				}
			}
		}
	}
}

public OnEntityCreated(entity, const char[] classname)
{
	if(!IsValidEdict(entity) || entity < 0 || entity > 2048)
		return;

    if(StrEqual(classname, "item_powerup_rune", false))
		RemoveEntity(entity);
}