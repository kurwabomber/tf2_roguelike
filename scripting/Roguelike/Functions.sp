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

	if(amountOfItem[i][ItemID_HeavyWeapons] || amountOfItem[i][ItemID_MeteorShower]){
		multiplicativeDamageBuff *= multiplicativeAttackSpeedMultBuff;
		multiplicativeAttackSpeedMultBuff = 1.0;
	}
	if(amountOfItem[i][ItemID_BiggerCaliber]){
		multiplicativeAttackSpeedMultBuff /= Pow(1.8, float(amountOfItem[i][ItemID_BiggerCaliber]));
		multiplicativeDamageBuff *= Pow(2.1, float(amountOfItem[i][ItemID_BiggerCaliber]));
	}

	if(amountOfItem[i][ItemID_Camouflage]){
		TF2_AddCondition(i, TFCond_StealthedUserBuffFade, 0.5, i);
	}

	if(buffChange[i])
	{
		if(!IsFakeClient(i))
			TF2Attrib_RemoveAll(i);
		
		TF2Attrib_SetByName(i, "ignores other projectiles", 1.0);
		TF2Attrib_SetByName(i, "penetrate teammates", 1.0);

		if(additiveDamageRawBuff != 0.0)
			TF2Attrib_SetByName(i, "additive damage bonus", additiveDamageRawBuff);
		
		if(additiveDamageMultBuff*multiplicativeDamageBuff != 1.0)
			TF2Attrib_SetByName(i, "overall damage bonus", additiveDamageMultBuff*multiplicativeDamageBuff);
		
		if(additiveMoveSpeedMultBuff != 1.0)
			TF2Attrib_SetByName(i, "move speed penalty", additiveMoveSpeedMultBuff);

		if(additiveDamageTakenBuff*multiplicativeDamageTakenBuff != 1.0)
			TF2Attrib_SetByName(i, "dmg taken increased", additiveDamageTakenBuff*multiplicativeDamageTakenBuff);

		if(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff != 1.0){
			TF2Attrib_SetByName(i, "fire rate bonus", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
			TF2Attrib_SetByName(i, "item_meter_charge_rate", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
			TF2Attrib_SetByName(i, "Reload time decreased", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
			if(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff > 1.0)
				TF2Attrib_SetByName(i, "mult smack time", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
			if(TF2_GetPlayerClass(i) == TFClass_Engineer)
				TF2Attrib_SetByName(i, "engy sentry fire rate increased", 1.0/(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff));
		}

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
			if(TF2_GetPlayerClass(i) == TFClass_Engineer){
				TF2Attrib_SetByName(i, "mvm sentry ammo", Pow(1.5,1.0*amountOfItem[i][ItemID_ExtraMunitions]));
				TF2Attrib_SetByName(i, "maxammo metal increased", Pow(1.5,1.0*amountOfItem[i][ItemID_ExtraMunitions]));
			}
		}
		if(amountOfItem[i][ItemID_PocketDispenser]){
			TF2Attrib_SetByName(i, "ammo regen", 0.05*amountOfItem[i][ItemID_PocketDispenser]);
			if(TF2_GetPlayerClass(i) == TFClass_Engineer){
				TF2Attrib_SetByName(i, "metal regen", 20.0 * amountOfItem[i][ItemID_PocketDispenser]);
			}
		}
		if(amountOfItem[i][ItemID_BigBaboonHeart]){
			TF2Attrib_SetByName(i, "mult max health", Pow(1.25,1.0*amountOfItem[i][ItemID_BigBaboonHeart]));
			TF2Attrib_SetByName(i, "max health additive bonus", 10.0*amountOfItem[i][ItemID_BigBaboonHeart]);
			if(TF2_GetPlayerClass(i) == TFClass_Engineer){
				TF2Attrib_SetByName(i, "engy building health bonus", 0.05*amountOfItem[i][ItemID_BigBaboonHeart] + Pow(1.25,1.0*amountOfItem[i][ItemID_BigBaboonHeart]));
			}
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
		if(amountOfItem[i][ItemID_PrecisionTargeting]){
			TF2Attrib_SetByName(i, "mult crit dmg", Pow(1.4, float(amountOfItem[i][ItemID_PrecisionTargeting])));
		}
		if(amountOfItem[i][ItemID_AustraliumAlchemist]){
			TF2Attrib_SetByName(i, "mult credit collect range", Pow(1.5, float(amountOfItem[i][ItemID_AustraliumAlchemist])));
		}
		if(amountOfItem[i][ItemID_GiantSlayer]){
			TF2Attrib_SetByName(i, "mult dmg vs giants", Pow(1.5, float(amountOfItem[i][ItemID_GiantSlayer])));
		}
		if(amountOfItem[i][ItemID_Autocollect]){
			TF2Attrib_SetByName(i, "collect currency on kill", float(amountOfItem[i][ItemID_Autocollect]));
		}
		if(amountOfItem[i][ItemID_Cleave]){
			TF2Attrib_SetByName(i, "melee cleave attack", float(amountOfItem[i][ItemID_Cleave]));
		}
		if(amountOfItem[i][ItemID_Multishot]){
			for(int slot = 0; slot<2; ++slot){
				int weapon = TF2Util_GetPlayerLoadoutEntity(i, slot, false);
				if(!IsValidWeapon(weapon) || TF2Util_IsEntityWearable(weapon))
					continue;

				int projectile = SDKCall(SDKCall_GetWeaponProjectile, weapon);
				int override = TF2Attrib_HookValueInt(0, "override_projectile_type", weapon);
				if(override != 0)
					projectile = override;

				switch(projectile){
					case TF_PROJECTILE_ROCKET,TF_PROJECTILE_PIPEBOMB,TF_PROJECTILE_FLARE,TF_PROJECTILE_ARROW,TF_PROJECTILE_HEALING_BOLT,
					TF_PROJECTILE_ENERGY_BALL,TF_PROJECTILE_ENERGY_RING,TF_PROJECTILE_CANNONBALL,TF_PROJECTILE_BUILDING_REPAIR_BOLT,
					TF_PROJECTILE_FESTIVE_ARROW,TF_PROJECTILE_FESTIVE_HEALING_BOLT:{
						TF2Attrib_SetByName(weapon, "mult projectile count", 1.0 + amountOfItem[i][ItemID_Multishot]);
						TF2Attrib_SetByName(weapon, "projectile spread angle penalty", float(amountOfItem[i][ItemID_Multishot]));
					}
				}
			}
		}
		if(amountOfItem[i][ItemID_LongerMelee]){
			TF2Attrib_SetByName(i, "melee range multiplier", Pow(2.0, float(amountOfItem[i][ItemID_LongerMelee])));
		}
		if(amountOfItem[i][ItemID_PrecisionNotAccuracy]){
			TF2Attrib_SetByName(i, "weapon spread bonus", Pow(0.66, float(amountOfItem[i][ItemID_PrecisionNotAccuracy])));
		}
		if(amountOfItem[i][ItemID_AcceleratedDegeneration]){
			TF2Attrib_SetByName(i, "mult bleeding delay", Pow(0.5, float(amountOfItem[i][ItemID_AcceleratedDegeneration])));
			TF2Attrib_SetByName(i, "mult afterburn delay", Pow(0.5, float(amountOfItem[i][ItemID_AcceleratedDegeneration])));
		}
		if(amountOfItem[i][ItemID_Bargain]){
			TF2Attrib_SetByName(i, "sniper charge per sec", Pow(1.5, float(amountOfItem[i][ItemID_Bargain])));
		}
		if(amountOfItem[i][ItemID_Snare]){
			TF2Attrib_SetByName(i, "slow enemy on hit major", 2.0*amountOfItem[i][ItemID_Snare]);
		}
		if(amountOfItem[i][ItemID_DumpsterDiver]){
			for(int slot = 0; slot<2; ++slot){
				int weapon = TF2Util_GetPlayerLoadoutEntity(i, slot, false);
				if(!IsValidWeapon(weapon) || TF2Util_IsEntityWearable(weapon))
					continue;

				int projectile = SDKCall(SDKCall_GetWeaponProjectile, weapon);
				int override = TF2Attrib_HookValueInt(0, "override_projectile_type", weapon);
				if(override != 0)
					projectile = override;
				
				if(!HasEntProp(weapon, Prop_Data, "m_iClip1") || GetEntProp(weapon,Prop_Data,"m_iClip1")  == -1)
					continue;

				switch(projectile){
					case TF_PROJECTILE_BULLET,TF_PROJECTILE_ROCKET,TF_PROJECTILE_PIPEBOMB,TF_PROJECTILE_SYRINGE,TF_PROJECTILE_FLARE,TF_PROJECTILE_ARROW,
					TF_PROJECTILE_HEALING_BOLT,TF_PROJECTILE_ENERGY_BALL,TF_PROJECTILE_ENERGY_RING,TF_PROJECTILE_BUILDING_REPAIR_BOLT,TF_PROJECTILE_FESTIVE_HEALING_BOLT:{
						TF2Attrib_SetByName(weapon, "fire rate bonus HIDDEN", 0.3);
						TF2Attrib_SetByName(weapon, "auto fires full clip", 1.0);
					}
				}
			}
		}
		if(amountOfItem[i][ItemID_MeteorShower]){
			int weapon = TF2Util_GetPlayerLoadoutEntity(i, 0);
			if(IsValidWeapon(weapon)){
				TF2Attrib_SetByName(weapon, "override projectile type", float(TF_PROJECTILE_METEORSHOWER));
				TF2Attrib_SetByName(weapon, "fire rate penalty HIDDEN", 2.0);
			}
		}
		if(amountOfItem[i][ItemID_Headshot]){
			TF2Attrib_SetByName(i, "can headshot", 1.0);
		}
		if(amountOfItem[i][ItemID_ProjectileInertia]){
			TF2Attrib_SetByName(i, "projectile no deflect", 1.0);
		}
		if(amountOfItem[i][ItemID_BossSlayer]){
			TF2Attrib_SetByName(i, "dmg current health", 0.002 * amountOfItem[i][ItemID_BossSlayer]);
		}
		if(amountOfItem[i][ItemID_Killstreak]){
			TF2Attrib_SetByName(i, "minicritboost on kill", 2.0 * amountOfItem[i][ItemID_Killstreak]);
		}
		if(amountOfItem[i][ItemID_Leeches]){
			TF2Attrib_SetByName(i, "damage returns as health", 0.1 * amountOfItem[i][ItemID_Leeches]);
		}
		if(amountOfItem[i][ItemID_PowerfulSwings]){
			int melee = TF2Util_GetPlayerLoadoutEntity(i, 2);
			if(IsValidWeapon(melee))
				TF2Attrib_SetByName(melee, "melee airblast", 1.0);
		}
		if(amountOfItem[i][ItemID_DeadlierDecay]){
			TF2Attrib_SetByName(i, "mult bleeding dmg", Pow(2.0, float(amountOfItem[i][ItemID_DeadlierDecay])));
			TF2Attrib_SetByName(i, "weapon burn dmg increased", Pow(2.0, float(amountOfItem[i][ItemID_DeadlierDecay])));
		}
		if(amountOfItem[i][ItemID_Inferno]){
			TF2Attrib_SetByName(i, "Set DamageType Ignite", 4.0);
		}
		if(amountOfItem[i][ItemID_Wounding]){
			TF2Attrib_SetByName(i, "bleeding duration", 4.0);
		}
		if(amountOfItem[i][ItemID_HealthRegeneration]){
			TF2Attrib_SetByName(i, "health regen", 10.0*amountOfItem[i][ItemID_HealthRegeneration]);
		}
		if(amountOfItem[i][ItemID_TheWeaver]){
			TF2Attrib_SetByName(i, "robo sapper", 3.0);
			TF2Attrib_SetByName(i, "maxammo grenades1 increased", 4.0);
			TF2Attrib_SetByName(i, "effect bar recharge rate increased", 0.2);
			TF2Attrib_SetByName(i, "not solid to players", 1.0);
		}
		buffChange[i] = false;
	}

	if(IsFakeClient(i))
		return;

	if(additiveDamageRawBuff > 0.0)
		Format(details, sizeof(details), "%s\n+%i Damage", details, RoundToNearest(additiveDamageRawBuff));
	else if(additiveDamageRawBuff < 0.0)
		 Format(details, sizeof(details), "%s\n%i Damage", details, RoundToNearest(additiveDamageRawBuff));
	
	if(additiveDamageMultBuff*multiplicativeDamageBuff > 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Damage", details, RoundToNearest(((additiveDamageMultBuff*multiplicativeDamageBuff)-1.0)*100.0) );
	else if(additiveDamageMultBuff*multiplicativeDamageBuff < 1.0)
		Format(details, sizeof(details), "%s\n%ipct Damage", details, RoundToNearest(((additiveDamageMultBuff*multiplicativeDamageBuff)-1.0)*100.0) );

	if(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff > 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Fire Rate", details, RoundToNearest(((additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff)-1.0)*100.0) );
	else if(additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff < 1.0)
		Format(details, sizeof(details), "%s\n%ipct Fire Rate", details, RoundToNearest(((additiveAttackSpeedMultBuff*multiplicativeAttackSpeedMultBuff)-1.0)*100.0) );

	if(additiveMoveSpeedMultBuff > 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Move Speed", details, RoundToNearest((additiveMoveSpeedMultBuff-1.0)*100.0) );
	else if(additiveMoveSpeedMultBuff < 1.0)
		Format(details, sizeof(details), "%s\n%ipct Move Speed", details, RoundToNearest((additiveMoveSpeedMultBuff-1.0)*100.0) );

	if(additiveDamageTakenBuff*multiplicativeDamageTakenBuff > 1.0)
		Format(details, sizeof(details), "%s\n+%ipct Damage Vulnerability", details, RoundToNearest(((additiveDamageTakenBuff*multiplicativeDamageTakenBuff)-1.0)*100.0) );
	else if (additiveDamageTakenBuff*multiplicativeDamageTakenBuff < 1.0)
		Format(details, sizeof(details), "%s\n-%ipct Damage Taken", details, RoundToNearest( (1.0-(additiveDamageTakenBuff*multiplicativeDamageTakenBuff)) *100.0) );

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
	if(absorptionAmount[client] > 0){
		Format(textBuild, sizeof(textBuild), "%s\nAbsorption: %.0f left", textBuild, absorptionAmount[client])
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

	PrintToServer("Roguelike | Loaded %i roguelike items", loadedItems);

	delete keyvalue;
}
void ParseItemConfig(Handle keyvalue){
	char buffer[512];
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
					KvGetString(keyvalue, "", availableItems[loadedItems].description, 512);
					ReplaceString(availableItems[loadedItems].description, 512, "\\n", "\n");
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
					
					if(StrContains(buffer, "ultimate", false) != -1)
						availableItems[loadedItems].tagInfo.isUltimate = true;

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
				else if(StrEqual(buffer, "itemRequirement")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					char buffers[128][32];
					ExplodeString(buffer,",", buffers, 32, 128);
					for(int i = 0;i<32;++i){
						if(buffers[i][0] != '\0')
							availableItems[loadedItems].tagInfo.allowedWeapons[i] = StringToInt(buffers[i]);
					}
				}
				else if(StrEqual(buffer, "classnameRequirement")){
					KvGetString(keyvalue, "", buffer, sizeof(buffer));
					strcopy(availableItems[loadedItems].tagInfo.requiredWeaponClassname, 64, buffer);
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
void ChooseUltimateItems(int client, bool clear=false){
	if(clear){
		for(int i = 0;i < MAX_ITEMS_PER_WAVE;++i){
			generatedPlayerUltimateItems[client][i].clear();
		}
	}

	bool hasExplosive, hasProjectile, hasBullet, hasRocket;
	char classnames[64][3];
	int itemIDs[3];
	int classBit = IsValidClient(client) ? (1 << _:TF2_GetPlayerClass(client)-1) : 0;
	if(IsValidClient(client)){
		for(int slot = 0;slot<3;++slot){
			int weapon = TF2Util_GetPlayerLoadoutEntity(client, slot);

			if(!IsValidWeapon(weapon))
				continue;
			
			GetEntityClassname(weapon, classnames[slot], 64);
			itemIDs[slot] = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");

			if(TF2Util_IsEntityWearable(weapon))
				continue;

			int projectile = SDKCall(SDKCall_GetWeaponProjectile, weapon);
			int override = TF2Attrib_HookValueInt(0, "override_projectile_type", weapon);
			if(override != 0)
				projectile = override;

			switch(projectile){
				case TF_PROJECTILE_ROCKET,TF_PROJECTILE_PIPEBOMB,TF_PROJECTILE_PIPEBOMB_REMOTE,
				TF_PROJECTILE_ENERGY_BALL,TF_PROJECTILE_CANNONBALL,TF_PROJECTILE_SENTRY_ROCKET:{hasExplosive=true;}
			}
			if(projectile != TF_PROJECTILE_BULLET && projectile != TF_PROJECTILE_NONE)
				hasProjectile = true;
			if(projectile == TF_PROJECTILE_BULLET)
				hasBullet = true;
			if(projectile == TF_PROJECTILE_ROCKET)
				hasRocket = true;
		}
	}

	int itemsGenerated = 0;
	for(int i = 0;i<=loadedItems;++i){
		if(!availableItems[i].tagInfo.isUltimate)
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
		if(availableItems[i].tagInfo.allowedWeapons[0]){
			bool flag = false;
			for(int id = 0;id < 32;++id){
				if(availableItems[i].tagInfo.allowedWeapons[id] != 0){
					for(int k = 0;k < 3;++k){
						if(itemIDs[k] == availableItems[i].tagInfo.allowedWeapons[id]){
							flag = true;
							break;
						}
					}
				}
			}
			if(!flag)
				continue;
		}
		if(availableItems[i].tagInfo.requiredWeaponClassname[0] != '\0'){
			bool flag = false;
			for(int k = 0;k < 3;++k){
				PrintToServer("%s",classnames[k]);
				if(StrEqual(classnames[k],availableItems[i].tagInfo.requiredWeaponClassname)){
					flag = true;
					break;
				}
			}
			if(!flag)
				continue;
		}

		generatedPlayerUltimateItems[client][itemsGenerated] = availableItems[i];
		++itemsGenerated;
	}
}
void ChooseGeneratedItems(int client, int wave, int amount, ItemRarity minRarity = ItemRarity_Normal, ItemRarity maxRarity = ItemRarity_Valve){
	//Tagging time!
	bool hasExplosive, hasProjectile, hasBullet, hasRocket;
	int classBit = IsValidClient(client) ? (1 << _:TF2_GetPlayerClass(client)-1) : 0;
	if(IsValidClient(client)){
		for(int slot = 0;slot<3;++slot){
			int weapon = TF2Util_GetPlayerLoadoutEntity(client, slot, false);
			if(!IsValidWeapon(weapon) || TF2Util_IsEntityWearable(weapon))
				continue;
			
			int projectile = SDKCall(SDKCall_GetWeaponProjectile, weapon);
			int override = TF2Attrib_HookValueInt(0, "override_projectile_type", weapon);
			if(override != 0)
				projectile = override;

			switch(projectile){
				case TF_PROJECTILE_ROCKET,TF_PROJECTILE_PIPEBOMB,TF_PROJECTILE_PIPEBOMB_REMOTE,
				TF_PROJECTILE_ENERGY_BALL,TF_PROJECTILE_CANNONBALL,TF_PROJECTILE_SENTRY_ROCKET:{hasExplosive=true;}
			}
			if(projectile != TF_PROJECTILE_BULLET && projectile != TF_PROJECTILE_NONE)
				hasProjectile = true;
			if(projectile == TF_PROJECTILE_BULLET)
				hasBullet = true;
			if(projectile == TF_PROJECTILE_ROCKET)
				hasRocket = true;
		}
	}
	int weights[MAX_ITEMS];

	for(int i = 0;i<=loadedItems;++i){
		if(availableItems[i].tagInfo.isUltimate)
			continue;
			
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
void ApplyTankEffects(int ref){
	int entity = EntRefToEntIndex(ref);
	if(IsValidEntity(entity)){
		for(int i = 1; i<= MaxClients; ++i){
			if(!IsValidClient(i))
				continue;

			if(amountOfItem[i][ItemID_TheWeaver]){
				SetEntPropFloat(entity, Prop_Data, "m_speed", GetEntPropFloat(entity, Prop_Data, "m_speed") * 0.7)
				break;
			}
		}
	}
}
void DoWeaverEffect(int client){
	float victimPos[3];
	GetClientAbsOrigin(client, victimPos);

	int inflictor = TF2Util_GetPlayerConditionProvider(client, TFCond_Sapped);
	if(IsValidClient(inflictor)){
		if(amountOfItem[inflictor][ItemID_TheWeaver]){
			TF2_AddCondition(client, TFCond_MarkedForDeath, 2.0);
			TF2_StunPlayer(client, 999.0, 0.3, TF_STUNFLAG_SLOWDOWN, inflictor);
			SDKHooks_TakeDamage(client, inflictor, inflictor, 3.0, DMG_GENERIC);
			for(int i = 1; i <= MaxClients; ++i){
				if(!IsValidClient(i) || !IsPlayerAlive(i))
					continue;

				if(IsOnDifferentTeams(client,i))
					continue;

				float teammatePos[3];
				GetClientAbsOrigin(i, teammatePos);
				if(GetVectorDistance(teammatePos, victimPos) > 300.0)
					continue;
				
				PushEntity(i, client, -100.0);
			}
		}
	}
}
char[] getRandomProjectileName(int input){
	char buffer[64];
	switch(input){
		case 0:{buffer = "tf_projectile_arrow";}
		case 1:{buffer = "tf_projectile_energy_ball";}
		case 2:{buffer = "tf_projectile_flare";}
		case 3:{buffer = "tf_projectile_healing_bolt";}
		case 4:{buffer = "tf_projectile_jar";}
		case 5:{buffer = "tf_projectile_jar_milk";}
		case 6:{buffer = "tf_projectile_jar_gas";}
		case 7:{buffer = "tf_projectile_lightningorb";}
		case 8:{buffer = "tf_projectile_pipe";}
		case 9:{buffer = "tf_projectile_rocket";}
		case 10:{buffer = "tf_projectile_sentryrocket";}
		case 11:{buffer = "tf_projectile_spellbats";}
		case 12:{buffer = "tf_projectile_spellfireball";}
		case 13:{buffer = "tf_projectile_spellmeteorshower";}
		case 14:{buffer = "tf_projectile_syringe";}
		case 15:{buffer = "tf_projectile_spellspawnboss";}
		case 16:{buffer = "tf_projectile_cleaver";}
		case 17:{buffer = "tf_projectile_stun_ball";}
		case 18:{buffer = "tf_projectile_pipe";}
	}
	return buffer;
}
void SpawnRandomProjectile(int client){
	int id = GetRandomInt(0,18);
	int iEntity = CreateEntityByName(getRandomProjectileName(id));
	if (IsValidEdict(iEntity)){
		int iTeam = GetClientTeam(client);
		float fAngles[3],fOrigin[3],vBuffer[3],fVelocity[3],fwd[3];

		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(iEntity, Prop_Send, "m_iTeamNum", iTeam);

		GetClientEyePosition(client, fOrigin);
		GetClientEyeAngles(client, fAngles);
		fAngles[0] += GetRandomFloat(-15.0,15.0);
		fAngles[1] += GetRandomFloat(-15.0,15.0);
		GetAngleVectors(fAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		GetAngleVectors(fAngles,fwd, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(fwd, GetRandomFloat(10.0, 100.0));
		AddVectors(fOrigin, fwd, fOrigin);
		
		if(HasEntProp(iEntity, Prop_Send, "m_hThrower"))
		{
			float vecAngImpulse[3];
			GetCleaverAngularImpulse(vecAngImpulse);
			fVelocity[0] = vBuffer[0]*2000.0;
			fVelocity[1] = vBuffer[1]*2000.0;
			fVelocity[2] = vBuffer[2]*2000.0;

			TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
			DispatchSpawn(iEntity);
			SDKCall(SDKCall_InitGrenade, iEntity, fVelocity, vecAngImpulse, client, 0, 5.0);
			Phys_SetVelocity(iEntity, fVelocity, vecAngImpulse, true);
		}
		else
		{
			fVelocity[0] = vBuffer[0]*1500.0;
			fVelocity[1] = vBuffer[1]*1500.0;
			fVelocity[2] = vBuffer[2]*1500.0;
			TeleportEntity(iEntity, fOrigin, fAngles, fVelocity);
			DispatchSpawn(iEntity);
		}
		if(HasEntProp(iEntity, Prop_Send, "m_hThrower"))
			SetEntPropEnt(iEntity, Prop_Send, "m_hThrower", client);
		if(HasEntProp(iEntity, Prop_Send, "m_hLauncher"))
			SetEntPropEnt(iEntity, Prop_Send, "m_hLauncher", client);
		if(HasEntProp(iEntity, Prop_Send, "m_hOriginalLauncher"))
			SetEntPropEnt(iEntity, Prop_Send, "m_hOriginalLauncher", client);
		if(HasEntProp(iEntity, Prop_Send, "m_flDamage"))
			SetEntPropFloat(iEntity, Prop_Send, "m_flDamage", 100.0);
		if(HasEntProp(iEntity, Prop_Send, "m_DmgRadius"))
			SetEntPropFloat(iEntity, Prop_Send, "m_DmgRadius", 144.0);
		if(HasEntProp(iEntity, Prop_Send, "m_bIsLive"))
			SetEntProp(iEntity, Prop_Send, "m_bIsLive", true);

		CreateTimer(3.0, SelfDestruct, EntIndexToEntRef(iEntity));
	}
}

void GetCleaverAngularImpulse(float vecAngImpulse[3]) {
	vecAngImpulse[0] = 0.0;
	vecAngImpulse[1] = 500.0;
	vecAngImpulse[2] = 0.0;
}

void addAbsorption(int client, float amount){
	absorptionAmount[client] += amount;
	if(absorptionAmount[client] > TF2Util_GetEntityMaxHealth(client)*2)
		absorptionAmount[client] = TF2Util_GetEntityMaxHealth(client)*2.0;
}