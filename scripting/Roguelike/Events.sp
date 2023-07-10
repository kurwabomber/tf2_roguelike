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
		SetEntProp(client, Prop_Send, "m_nCurrency", GetEntProp(client, Prop_Send, "m_nCurrency") + playerItems[client][i].cost);
		playerItems[client][i].clear();
		savedPlayerItems[client][i].clear();
	}
	for(int i = 0; i<MAX_WAVES;++i){
		for(int j = 0;j<MAX_ITEMS_PER_WAVE;++j){
			generatedPlayerItems[client][i][j].isBought = false;
		}
	}

	//Choose 7 items before game start.
	ChooseGeneratedItems(client, 0, 7);
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

public OnEntityCreated(entity, const char[] classname)
{
	if(!IsValidEdict(entity) || entity < 0 || entity > 2048)
		return;

    if(StrEqual(classname, "item_powerup_rune", false))
		RemoveEntity(entity);
}