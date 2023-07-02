//Replaces any old buff with same details, else inserts a new one.
public void insertBuff(int client, Buff newBuff){
	int replacementID = getNextBuff(client);

	for(int i = 0;i < MAXBUFFS;i++){
		if(playerBuffs[client][i].id == newBuff.id && playerBuffs[client][i].priority <= newBuff.priority)
			{replacementID = i;break;}
	}
	buffChange[client] = true;
	playerBuffs[client][replacementID] = newBuff;
	//PrintToServer("added %s to %N for %.2fs. ID = %i, index = %i", newBuff.name, client, newBuff.duration -GetGameTime(), newBuff.id, replacementID);
}
public bool hasBuffIndex(int client, int index){
	for(int i = 0; i < MAXBUFFS; i++){
		if(playerBuffs[client][i].id == index)
			return true;
	}
	return false;
}
public int getBuffInArray(int client, int index){
	for(int i = 0; i < MAXBUFFS; i++){
		if(playerBuffs[client][i].id == index)
			return i;
	}
	return -1;
}
public int getNextBuff(int client){
	for(int i = 0; i < MAXBUFFS; i++){
		if(playerBuffs[client][i].id == 0)
			return i;
	}
	return 0;
}
public void clearAllBuffs(int client){
	for(int i = 0; i < MAXBUFFS; i++){
		playerBuffs[client][i].clear();
	}
}
public void ManagePlayerBuffs(int i){
	float additiveDamageRawBuff;
	float additiveDamageMultBuff = 1.0;
	float multiplicativeDamageBuff = 1.0;
	float additiveAttackSpeedMultBuff = 1.0;
	float multiplicativeAttackSpeedMultBuff = 1.0;
	float additiveMoveSpeedMultBuff = 1.0;
	float additiveDamageTakenBuff = 1.0;
	float multiplicativeDamageTakenBuff = 1.0;
	float additiveArmorRechargeBuff = 1.0;

	char details[255] = "Statuses Active:"

	for(int buff = 0;buff < MAXBUFFS; buff++)
	{
		if(playerBuffs[i][buff].id == 0)
			continue;

		//Clear out any non-active buffs.
		if(playerBuffs[i][buff].duration != 0.0 && playerBuffs[i][buff].duration < currentGameTime)
			{playerBuffs[i][buff].clear();buffChange[i]=true;continue;}

		bool flag;
		
		for(int buffCheck = 0; buffCheck < MAXBUFFS; buffCheck++)
		{
			if(playerBuffs[i][buffCheck].duration == 0.0)
				continue;
			if(buffCheck == buff)
				continue;
			if(playerBuffs[i][buffCheck].id == playerBuffs[i][buff].id &&
				playerBuffs[i][buffCheck].priority > playerBuffs[i][buff].priority)
				{flag = true;break;}
		}

		if(flag)
			continue;

		additiveDamageRawBuff += playerBuffs[i][buff].additiveDamageRaw;
		additiveDamageMultBuff += playerBuffs[i][buff].additiveDamageMult;
		multiplicativeDamageBuff *= playerBuffs[i][buff].multiplicativeDamage;
		additiveAttackSpeedMultBuff += playerBuffs[i][buff].additiveAttackSpeedMult;
		multiplicativeAttackSpeedMultBuff *= playerBuffs[i][buff].multiplicativeAttackSpeedMult;
		additiveMoveSpeedMultBuff += playerBuffs[i][buff].additiveMoveSpeedMult;
		additiveDamageTakenBuff += playerBuffs[i][buff].additiveDamageTaken;
		multiplicativeDamageTakenBuff *= playerBuffs[i][buff].multiplicativeDamageTaken;
		additiveArmorRechargeBuff += playerBuffs[i][buff].additiveArmorRecharge;

		if(playerBuffs[i][buff].description[0] != '\0')
			Format(details, sizeof(details), "%s\n%s: - %.1fs\n  %s", details, playerBuffs[i][buff].name, playerBuffs[i][buff].duration - currentGameTime, playerBuffs[i][buff].description);
		else
			Format(details, sizeof(details), "%s\n%s - %.1fs", details, playerBuffs[i][buff].name, playerBuffs[i][buff].duration - currentGameTime);
	}

	if(TF2_IsPlayerInCondition(i, TFCond_AfterburnImmune))
		Format(details, sizeof(details), "%s\n%s - %.1fs", details, "Afterburn Immunity", TF2Util_GetPlayerConditionDuration(i, TFCond_AfterburnImmune));

	if(buffChange[i])
	{
		TF2Attrib_SetByName(i, "additive damage bonus", additiveDamageRawBuff);
		TF2Attrib_SetByName(i, "damage bonus", additiveDamageMultBuff*multiplicativeDamageBuff);
		TF2Attrib_SetByName(i, "firerate player buff", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "recharge rate player buff", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "Reload time decreased", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "movespeed player buff", additiveMoveSpeedMultBuff);
		TF2Attrib_SetByName(i, "damage taken mult 4", additiveDamageTakenBuff*multiplicativeDamageTakenBuff);
		buffChange[i] = false;
	}

	if(IsFakeClient(i))
		return;

	if(additiveDamageRawBuff != 0.0)
		Format(details, sizeof(details), "%s\n+%i Damage", details, RoundToNearest(additiveDamageRawBuff));
	
	if(additiveDamageMultBuff*multiplicativeDamageBuff != 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Damage", details, RoundToNearest(((additiveDamageMultBuff*multiplicativeDamageBuff)-1.0)*100.0) );

	if(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff != 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Fire Rate", details, RoundToNearest(((additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff)-1.0)*100.0) );

	if(additiveMoveSpeedMultBuff != 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Move Speed", details, RoundToNearest((additiveMoveSpeedMultBuff-1.0)*100.0) );

	if(additiveDamageTakenBuff*multiplicativeDamageTakenBuff > 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Damage Vulnerability", details, RoundToNearest(((additiveDamageTakenBuff*multiplicativeDamageTakenBuff)-1.0)*100.0) );
	else if (additiveDamageTakenBuff*multiplicativeDamageTakenBuff < 1.0)
		Format(details, sizeof(details), "%s\n-%ipct Damage Taken", details, RoundToNearest( (1.0-(additiveDamageTakenBuff*multiplicativeDamageTakenBuff)) *100.0) );

	if(additiveArmorRechargeBuff != 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Armor Recharge Rate", details, RoundToNearest((additiveArmorRechargeBuff-1.0)*100.0) );

	SendItemInfo(i, details);
}