public OnGameFrame()
{
	currentGameTime = GetGameTime();
	for(int client=1; client<=MaxClients; ++client)
	{
		if(!IsValidClient(client))
			continue;
		if(!IsPlayerAlive(client))
			continue;

		if(compoundInterestDuration[client] >= currentGameTime){
			if(compoundInterestDamageTime[client] <= currentGameTime){
				for(int i = 1; i <= MaxClients; ++i){
					if(compoundInterestStacks[client][i] > 0)
						SDKHooks_TakeDamage(client, i, i, 2.0*compoundInterestStacks[client][i] * Pow(2.0, float(amountOfItem[i][ItemID_DeadlierDecay])), DMG_SLASH);
				}
				compoundInterestDamageTime[client] = currentGameTime+0.5;
			}
		}else if(compoundInterestDamageTime[client]){
			compoundInterestDamageTime[client] = 0.0;
			for(int i = 1; i <= MaxClients; ++i){
				compoundInterestStacks[client][i] = 0
			}
		}
		//Passive Weapons!
		if(lastActivelyFiredTime[client]+1.0 >= currentGameTime && storedButtons[client] & IN_ATTACK){
			if(amountOfItem[client][ItemID_DeathSpiral] && itemTimer[client][ItemID_DeathSpiral] < currentGameTime){
				float vBuffer[3], fOrigin[3], fAngles[3], fVelocity[3], impulse[3];
				GetClientEyePosition(client, fOrigin);
				fAngles[1] = -180.0;
				GetCleaverAngularImpulse(impulse);
				int iTeam = GetClientTeam(client);
				for(int i = 0;i<16;++i){
					fAngles[2] = 0.0;
					int iEntity = CreateEntityByName("tf_projectile_cleaver");
					if (IsValidEdict(iEntity)) 
					{
						SetEntProp(iEntity, Prop_Send, "m_iTeamNum", iTeam);
						GetAngleVectors(fAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
						fAngles[2] = 90.0;
						fVelocity[0] = vBuffer[0]*500.0;
						fVelocity[1] = vBuffer[1]*500.0;
						fVelocity[2] = vBuffer[2]*500.0;

						ScaleVector(vBuffer, 30.0);
						AddVectors(fOrigin, vBuffer, fOrigin);

						SetEntPropEnt(iEntity, Prop_Send, "m_hOriginalLauncher", client);
						SetEntProp(iEntity, Prop_Data, "m_bIsLive", true);
						SetEntProp(iEntity, Prop_Send, "m_bCritical", 1);

						TeleportEntity(iEntity, fOrigin, fAngles, NULL_VECTOR);
						DispatchSpawn(iEntity);
						SDKCall(SDKCall_InitGrenade, iEntity, fVelocity, impulse, client, 0, 5.0);
						Phys_SetVelocity(iEntity, fVelocity, impulse, true);
						Phys_EnableGravity(iEntity, false);
						Phys_EnableDrag(iEntity, false);

						ScaleVector(vBuffer, -1.0);
						AddVectors(fOrigin, vBuffer, fOrigin);
						
						SetEntityModel(iEntity, "models/weapons/c_models/c_croc_knife/c_croc_knife.mdl");
					}
					fAngles[1] += 22.5;
				}
				itemTimer[client][ItemID_DeathSpiral] = currentGameTime+0.7;
			}
		}
	}
}
public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2]){
	storedButtons[client] = buttons;
	return Plugin_Continue;
}
public Action Timer_100MS(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++){
		if(!IsValidClient(i))
			continue;
		if(!IsPlayerAlive(i))
			continue;
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
		
		ManagePlayerBuffs(i);
		DoWeaverEffect(i);

		if(IsFakeClient(i))
			continue;
			
		ManagePlayerItemHUD(i);

		if(amountOfItem[i][ItemID_MedicalAssistance]){
			int shouldNotHeal = 0;
			int healing = 0;
			int uberType = 0;
			int medigun = TF2Util_GetPlayerLoadoutEntity(i, 1);
			if(IsValidWeapon(medigun) && HasEntProp(medigun, Prop_Send, "m_hHealingTarget")){
				shouldNotHeal = GetEntPropEnt(medigun, Prop_Send, "m_hHealingTarget");
				if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease")){
					uberType = TF2Attrib_HookValueInt(1, "set_charge_type", medigun);
				}
			}
			if(switchMedicalTargetTime[i] <= currentGameTime){
				float pctHealths[MAXPLAYERS+1];
				for(int k = 1; k <= MaxClients; ++k){
					if(!IsValidClient(k))
						continue;
					if(!IsPlayerAlive(k))
						continue;
					if(IsOnDifferentTeams(i,k))
						continue;
					pctHealths[k] = float(GetClientHealth(k))/TF2Util_GetEntityMaxHealth(k);
				}
				bool added[MAXPLAYERS+1];
				int targets = 0;
				for(int k = 1; k <= MaxClients; ++k){
					if(!pctHealths[k] || added[k])
						continue;
					float lowest = 1.0;
					int latest = 0;
					for(int j = 1; j <= MaxClients; ++j){
						if(!pctHealths[j] || added[j])
							continue;
						if(pctHealths[j] <= lowest){
							lowest = pctHealths[j];
							latest = j;
						}
					}
					if(latest){
						added[latest] = true;
						priorityTargeting[i][targets] = latest;
					}
					
					++targets;
				}
				switchMedicalTargetTime[i] = currentGameTime+2.0;
			}
			for(int k = 0; k <= MaxClients && healing < amountOfItem[i][ItemID_MedicalAssistance]; ++k){
				if(priorityTargeting[i][k] == 0 || shouldNotHeal == priorityTargeting[i][k] || priorityTargeting[i][k] == i)
					continue;
				
				AddPlayerHealth(priorityTargeting[i][k], 2, 1.5, true, i);
				switch(uberType){
					case 1:{TF2_AddCondition(priorityTargeting[i][k], TFCond_Ubercharged, 0.3, i);}
					case 2:{TF2_AddCondition(priorityTargeting[i][k], TFCond_Kritzkrieged, 0.3, i);}
					case 3:{TF2_AddCondition(priorityTargeting[i][k], TFCond_MegaHeal, 0.3, i);}
					case 4:{TF2_AddCondition(priorityTargeting[i][k], TFCond_UberBulletResist, 0.3, i);}
				}
				++healing;
			}
		}
		if(!isGameInPlay){
			if(amountOfItem[i][ItemID_PregamePrep])
				TF2_AddCondition(i, TFCond_CritCanteen, 1.0);
			canteenCount[i] = amountOfItem[i][ItemID_Canteen];
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
					if(!HasEntProp(id, Prop_Send, "m_iPrimaryAmmoType"))
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
public Action Timer_GiveFullHealth(Handle timer, int client){
	client = EntRefToEntIndex(client);
	if(IsValidClient)
		SetEntityHealth(client, TF2Util_GetEntityMaxHealth(client));
	return Plugin_Stop;
}
public Action ReEnableBuilding(Handle timer, int entity)
{
	entity = EntRefToEntIndex(entity);
	if(IsValidEdict(entity))
		SetEntProp(entity, Prop_Send, "m_bDisabled", 0);
	
	return Plugin_Stop;
}

public Action Timer_ChooseBeginnerItems(Handle timer, int client){
	client = EntRefToEntIndex(client)
	int logic = FindEntityByClassname(-1, "tf_objective_resource");
	if(IsValidEntity(logic)){
		totalWaveCount = GetEntProp(logic, Prop_Send, "m_nMannVsMachineMaxWaveCount");
	}
	if(IsValidClient(client)){
		ItemRarity highest = view_as<ItemRarity>(3 + 4/totalWaveCount);
		ChooseGeneratedItems(client, 0, 5+2*(10/totalWaveCount), _, highest);
		ChooseUltimateItems(client, true);
	}
	return Plugin_Stop;
}
public Action SelfDestruct(Handle timer, any:ref) 
{ 
	int entity = EntRefToEntIndex(ref); 
	if(IsValidEdict(entity)) 
		RemoveEntity(entity);
	return Plugin_Stop;
}