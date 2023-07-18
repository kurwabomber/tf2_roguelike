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
		if(playerBuffs[i][buff].id == Buff_Empty)
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


	if(amountOfItem[i][ItemID_MoreGun]){
		multiplicativeDamageBuff *= Pow(1.25, float(amountOfItem[i][ItemID_MoreGun]));
	}
	if(amountOfItem[i][ItemID_FireRate]){
		multiplicativeAttackSpeedMultBuff *= Pow(1.25, float(amountOfItem[i][ItemID_FireRate]));
	}

	if(amountOfItem[i][ItemID_HeavyWeapons]){
		multiplicativeDamageBuff *= multiplicativeAttackSpeedMultBuff;
		multiplicativeAttackSpeedMultBuff = 1.0;
	}

	if(buffChange[i])
	{
		TF2Attrib_RemoveAll(i);

		TF2Attrib_SetByName(i, "additive damage bonus", additiveDamageRawBuff);
		TF2Attrib_SetByName(i, "damage bonus", additiveDamageMultBuff*multiplicativeDamageBuff);
		TF2Attrib_SetByName(i, "firerate player buff", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "recharge rate player buff", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "mult_item_meter_charge_rate", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "Reload time decreased", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "mult smack time", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		TF2Attrib_SetByName(i, "movespeed player buff", additiveMoveSpeedMultBuff);
		TF2Attrib_SetByName(i, "damage taken mult 4", additiveDamageTakenBuff*multiplicativeDamageTakenBuff);

		if(amountOfItem[i][ItemID_RocketSpecialist]){
			TF2Attrib_SetByName(i, "rocket specialist", 1.0*amountOfItem[i][ItemID_RocketSpecialist]);
		}
		if(amountOfItem[i][ItemID_ExtendedMagazine]){
			TF2Attrib_SetByName(i, "clip size bonus", Pow(1.5,1.0*amountOfItem[i][ItemID_ExtendedMagazine]));
		}
		if(amountOfItem[i][ItemID_PlayingWithDanger]){
			TF2Attrib_SetByName(i, "Blast radius increased", 1.0 + 0.4*amountOfItem[i][ItemID_PlayingWithDanger]);
		}
		if(amountOfItem[i][ItemID_ExplosiveSpecialist]){
			TF2Attrib_SetByName(i, "dmg falloff decreased", 0.5);
		}
		if(amountOfItem[i][ItemID_TheQuickestFix]){
			TF2Attrib_SetByName(i, "healing mastery", 1.0*amountOfItem[i][ItemID_TheQuickestFix]);
		}
		if(amountOfItem[i][ItemID_TankBuster]){
			TF2Attrib_SetByName(i, "mult dmg vs tanks", Pow(1.5,1.0*amountOfItem[i][ItemID_TankBuster]));
		}
		if(amountOfItem[i][ItemID_ExtraMunitions]){
			TF2Attrib_SetByName(i, "hidden primary max ammo bonus", Pow(1.5,1.0*amountOfItem[i][ItemID_ExtraMunitions]));
			TF2Attrib_SetByName(i, "hidden secondary max ammo penalty", Pow(1.5,1.0*amountOfItem[i][ItemID_ExtraMunitions]));
		}
		if(amountOfItem[i][ItemID_PocketDispenser]){
			TF2Attrib_SetByName(i, "ammo regen", 0.05*amountOfItem[i][ItemID_PocketDispenser]);
		}
		if(amountOfItem[i][ItemID_BigBaboonHeart]){
			TF2Attrib_SetByName(i, "mult max health", Pow(1.25,1.0*amountOfItem[i][ItemID_BigBaboonHeart]));
			TF2Attrib_SetByName(i, "max health additive bonus", 10.0*amountOfItem[i][ItemID_BigBaboonHeart]);
		}
		if(amountOfItem[i][ItemID_ProjectileSpeed]){
			TF2Attrib_SetByName(i, "Projectile speed increased", 1.0 + 0.35*amountOfItem[i][ItemID_ProjectileSpeed]);
		}
		if(amountOfItem[i][ItemID_MoreBulletperBullet]){
			TF2Attrib_SetByName(i, "bullets per shot bonus", 1.0 + 0.65*amountOfItem[i][ItemID_MoreBulletperBullet]);
		}
		if(amountOfItem[i][ItemID_BiomechanicalEngineering]){
			TF2Attrib_SetByName(i, "medic machinery beam", 1.0*amountOfItem[i][ItemID_BiomechanicalEngineering]);
		}
		if(amountOfItem[i][ItemID_ArmorPenetration]){
			TF2Attrib_SetByName(i, "dmg pierces resists absorbs", 1.0);
		}
		if(amountOfItem[i][ItemID_TrenMaxxdoser]){
			TF2Attrib_SetByName(i, "max health additive penalty", 100.0 * amountOfItem[i][ItemID_TrenMaxxdoser]);
			TF2Attrib_SetByName(i, "increase buff duration", Pow(1.5,float(amountOfItem[i][ItemID_TrenMaxxdoser])));
		}
		if(amountOfItem[i][ItemID_SlowerThanaSpeedingBullet]){
			TF2Attrib_SetByName(i, "move speed bonus", 1.0 + 0.15 * amountOfItem[i][ItemID_SlowerThanaSpeedingBullet]);
		}
		if(amountOfItem[i][ItemID_ProjectilePenetration]){
			TF2Attrib_SetByName(i, "projectile penetration", float(amountOfItem[i][ItemID_ProjectilePenetration]));
		}
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
char[] GetPowerupName(int id){
	char output[16];
	switch(id){
		case 0:{
			output = "Strength";
		}
		case 1:{
			output = "Haste";
		}
		case 2:{
			output = "Regeneration";
		}
		case 3:{
			output = "Resistance";
		}
		case 4:{
			output = "Vampire";
		}
		case 5:{
			output = "Reflect";
		}
		case 6:{
			output = "Precision";
		}
		case 7:{
			output = "Agility";
		}
		case 8:{
			output = "Knockout";
		}
		case 9:{
			output = "King";
		}
		case 10:{
			output = "Plague";
		}
		case 11:{
			output = "Supernova";
		}
	}
	return output;
}
void ClearAllPowerups(int client){
	for(int i = 0; i<= POWERUPS_COUNT;++i){
		TFCond id = GetPowerupCondFromID(i);
		TF2_RemoveCondition(client, id)
	}
}
TFCond GetPowerupCondFromID(int id){
	switch(id){
		case 0:{
			return TFCond_RuneStrength;
		}
		case 1:{
			return TFCond_RuneHaste;
		}
		case 2:{
			return TFCond_RuneRegen;
		}
		case 3:{
			return TFCond_RuneResist;
		}
		case 4:{
			return TFCond_RuneVampire;
		}
		case 5:{
			return TFCond_RuneWarlock;
		}
		case 6:{
			return TFCond_RunePrecision;
		}
		case 7:{
			return TFCond_RuneAgility;
		}
		case 8:{
			return TFCond_RuneKnockout;
		}
		case 9:{
			return TFCond_KingRune;
		}
		case 10:{
			return TFCond_PlagueRune;
		}
		case 11:{
			return TFCond_SupernovaRune;
		}
	}
	return TFCond_RuneStrength;
}
void ManagePlayerItemHUD(int client){
	char textBuild[512] = "- Items -\n";
	int itemCount;
	bool counted[MAX_ITEMS];
	for(int i=0;i<MAX_HELD_ITEMS;++i){
		ItemID id = playerItems[client][i].id;
		if(id == ItemID_None || counted[id])
			continue;
		
		if(itemCount != 0 && itemCount % 3 == 0){
			Format(textBuild, sizeof(textBuild), "%s\n%s x%i | ",textBuild, playerItems[client][i].name, amountOfItem[client][id]);
		}else{
			Format(textBuild, sizeof(textBuild), "%s%s x%i | ",textBuild, playerItems[client][i].name, amountOfItem[client][id]);
		}
		counted[id] = true;
		++itemCount;
	}
	int lastBar = FindCharInString(textBuild, '|', true);
	if(lastBar != -1)
		textBuild[lastBar] = ' ';

	if(canteenCount[client] > 0){
		Format(textBuild, sizeof(textBuild), "%s\nCanteen: %i uses left", textBuild, canteenCount[client])
	}

	SetHudTextParams(0.02, 0.08, 0.2, 69, 245, 66, 255, 0, 0.0, 0.0, 0.0);
	ShowSyncHudText(client, itemDisplayHUD, textBuild);
}
void ParseAllItems(){
	Handle keyvalue = CreateKeyValues("items")
	FileToKeyValues(keyvalue, "addons/sourcemod/configs/roguelike_items.txt");
	if(!KvGotoFirstSubKey(keyvalue))
		return;
	
	ParseItemConfig(keyvalue);

	delete keyvalue;
}
void ParseItemConfig(Handle keyvalue){
	char buffer[128];
	do{
		if (KvGotoFirstSubKey(keyvalue, false)){
			ParseItemConfig(keyvalue);
			KvGoBack(keyvalue);

			KvGetSectionName(keyvalue, buffer, sizeof(buffer));
			strcopy(availableItems[loadedItems].name, 32, buffer);
			availableItems[loadedItems].id = view_as<ItemID>(loadedItems+1);

			loadedItems++;
		}
		else{
			if (KvGetDataType(keyvalue, NULL_STRING) != KvData_None){
				KvGetSectionName(keyvalue, buffer, sizeof(buffer));

				if(StrEqual(buffer, "description")){
					KvGetString(keyvalue, "", availableItems[loadedItems].description, 128);
					ReplaceString(availableItems[loadedItems].description, 128, "\\n", "\n");
				}
				else if(StrEqual(buffer, "tags")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					if(StrContains(buffer, "explosive", false) != -1)
						availableItems[loadedItems].tagInfo.reqExplosive = true;
					if(StrContains(buffer, "projectile", false) != -1)
						availableItems[loadedItems].tagInfo.reqProjectile = true;
					if(StrContains(buffer, "bullet", false) != -1)
						availableItems[loadedItems].tagInfo.reqBullet = true;
					if(StrContains(buffer, "canteen", false) != -1)
						availableItems[loadedItems].tagInfo.reqCanteen = true;
					if(StrContains(buffer, "rocket", false) != -1)
						availableItems[loadedItems].tagInfo.reqRocket = true;

					if(StrContains(buffer, "scout", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_SCOUT;
					if(StrContains(buffer, "soldier", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_SOLDIER;
					if(StrContains(buffer, "pyro", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_PYRO;
					if(StrContains(buffer, "demo", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_DEMO;
					if(StrContains(buffer, "heavy", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_HEAVY;
					if(StrContains(buffer, "engineer", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_ENGINEER;
					if(StrContains(buffer, "medic", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_MEDIC;
					if(StrContains(buffer, "sniper", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_SNIPER;
					if(StrContains(buffer, "spy", false) != -1)
						availableItems[loadedItems].tagInfo.classReq |= BIT_SPY;
				}
				else if(StrEqual(buffer, "weight")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					availableItems[loadedItems].weight = StringToInt(buffer);
				}
				else if(StrEqual(buffer, "rarity")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					availableItems[loadedItems].rarity = view_as<ItemRarity>(StringToInt(buffer));
				}
				else if(StrEqual(buffer, "cost")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					availableItems[loadedItems].cost = StringToInt(buffer);
				}
				else if(StrEqual(buffer, "max")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					availableItems[loadedItems].tagInfo.maximum = StringToInt(buffer);
				}
			}
		}
	}
	while (KvGotoNextKey(keyvalue, false));
}
int getFirstEmptyItemSlot(int client){
	for(int i=0;i<MAX_HELD_ITEMS;++i){
		if(playerItems[client][i].id == ItemID_None)
			return i;
	}
	return 0;
}
int getFirstIDItemSlot(int client, ItemID id){
	for(int i=0;i<MAX_HELD_ITEMS;++i){
		if(playerItems[client][i].id == id)
			return i;
	}
	return 0;
}
int ChooseWeighted(int[] weights, int size){
	int total = 0;
	for(int i=0;i<size;++i){
		total+=weights[i];
	}
	int chosen = GetRandomInt(0, total);
	int runningsum = 0;

	for(int i=0;i<size;++i){
		runningsum+=weights[i];
		if(chosen<runningsum)
			return i;
	}
	return 0;
}
char[] RarityToString(ItemRarity rarity){
	char buffer[32];
	switch(rarity){
		case ItemRarity_Normal:{
			buffer = "Normal";	
		}
		case ItemRarity_Unique:{
			buffer = "Unique";	
		}
		case ItemRarity_Strange:{
			buffer = "Strange";	
		}
		case ItemRarity_Genuine:{
			buffer = "Genuine";	
		}
		case ItemRarity_Collectors:{
			buffer = "Collectors";	
		}
		case ItemRarity_Unusual:{
			buffer = "Unusual";	
		}
		case ItemRarity_SelfMade:{
			buffer = "Self-Made";	
		}
		case ItemRarity_Valve:{
			buffer = "Valve";	
		}
	}
	return buffer;
}
void ChooseGeneratedItems(int client, int wave, int amount, ItemRarity minRarity = ItemRarity_Normal, ItemRarity maxRarity = ItemRarity_Valve){
	//Tagging time!
	bool hasExplosive, hasProjectile, hasBullet, hasRocket;
	int classBit = IsValidClient(client) ? (1 << _:TF2_GetPlayerClass(client)-1) : 0;
	if(IsValidClient(client)){
		for(int slot = 0;slot<3;++slot){
			int weapon = TF2Util_GetPlayerLoadoutEntity(client, slot);
			if(!IsValidWeapon(weapon) || TF2Util_IsEntityWearable(weapon))
				continue;
			
			int projectile = SDKCall(SDKCall_GetWeaponProjectile, weapon);
			int override = TF2Attrib_HookValueInt(-1, "override_projectile_type", weapon);
			if(override != -1)
				projectile = override;

			switch(projectile){
				case 2,3,4,12,14,16,17,27:{hasExplosive=true;}
			}
			if(projectile != 1 && projectile != 0)
				hasProjectile = true;
			if(projectile == 1)
				hasBullet = true;
			if(projectile == 2)
				hasRocket = true;
		}
	}
	int weights[MAX_ITEMS];

	for(int i = 0;i<=loadedItems;++i){
		if(availableItems[i].rarity < minRarity || availableItems[i].rarity > maxRarity)
			continue;

		if(availableItems[i].tagInfo.classReq != 0){
			if(!(availableItems[i].tagInfo.classReq & classBit))
				continue;
		}
		
		if(availableItems[i].tagInfo.maximum && timesItemGenerated[client][i] >= availableItems[i].tagInfo.maximum)
			continue;
		if(availableItems[i].tagInfo.reqExplosive && !hasExplosive)
			continue;
		if(availableItems[i].tagInfo.reqProjectile && !hasProjectile)
			continue;
		if(availableItems[i].tagInfo.reqBullet && !hasBullet)
			continue;
		if(availableItems[i].tagInfo.reqCanteen && !amountOfItem[client][ItemID_Canteen])
			continue;
		if(availableItems[i].tagInfo.reqRocket && !hasRocket)
			continue;

		weights[i] = availableItems[i].weight;
	}

	for(int i = 0;i < amount; ++i){
		int element = ChooseWeighted(weights, loadedItems);
		generatedPlayerItems[client][wave][i] = availableItems[element];
		++timesItemGenerated[client][element];
		if(availableItems[element].tagInfo.maximum && timesItemGenerated[client][element] >= availableItems[element].tagInfo.maximum){
			weights[element] = 0;
		}
	}
}