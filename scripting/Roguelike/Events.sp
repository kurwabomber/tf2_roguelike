public Event_WaveComplete(Handle event, const char[] name, bool dontBroadcast){
    wavesCleared++;

	for(int client = 1;client<MaxClients;++client){
		//Weights will be dependent on player (such as disabling items when unique)
		int weights[MAX_ITEMS];
		for(int i = 0;i<MAX_ITEMS;++i){
			weights[i] = availableItems[i].weight;
		}

		for(int i = 0;i < 4+wavesCleared; ++i){
			int element = ChooseWeighted(weights, sizeof(weights));
			generatedPlayerItems[client][wavesCleared][i] = availableItems[element];
		}
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
		savedPlayerItems[client][i].clear();
	}
	
	//Only generate on new join.
	if(generatedPlayerItems[client][0][0].id != ItemID_None)
		return;

	int weights[MAX_ITEMS];
	for(int i = 0;i<MAX_ITEMS;++i){
		weights[i] = availableItems[i].weight;
	}

	//7 items for when a player joins
	for(int i = 0;i < 7; ++i){
		int element = ChooseWeighted(weights, sizeof(weights));
		generatedPlayerItems[client][0][i] = availableItems[element];
	}
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