#define BIT_SCOUT 1 << 0
#define BIT_SNIPER 1 << 1
#define BIT_SOLDIER 1 << 2
#define BIT_DEMO 1 << 3
#define BIT_MEDIC 1 << 4
#define BIT_HEAVY 1 << 5
#define BIT_PYRO 1 << 6
#define BIT_SPY 1 << 7
#define BIT_ENGINEER 1 << 8
#define ExplosionSound1 "weapons/explode1.wav"
#define ExplosionSound2 "weapons/explode2.wav"
#define ExplosionSound3 "weapons/explode3.wav"
#define SmallExplosionSound1 "weapons/airstrike_small_explosion_01.wav"
#define SmallExplosionSound2 "weapons/airstrike_small_explosion_02.wav"
#define SmallExplosionSound3 "weapons/airstrike_small_explosion_03.wav"
#define DetonatorExplosionSound "weapons/flare_detonator_explode.wav"
#define OrnamentExplosionSound "weapons/ball_buster_break_01.wav"

stock EntityExplosion(owner, float damage, float radius, float pos[3], soundType = 0, bool visual = true, entity = -1, float soundLevel = 0.65,damagetype = DMG_BLAST, weapon = -1, float falloff = 0.0, soundPriority = 100, bool ignition = false)
{
	if(entity == -1 || !IsValidEdict(entity))
		entity = owner;
	int i = -1;
	while ((i = FindEntityByClassname(i, "*")) != -1)
	{
		if(IsValidForDamage(i) && IsOnDifferentTeams(owner,i) && i != entity)
		{
			float targetvec[3];
			float distance;
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", targetvec);
			distance = GetVectorDistance(pos, targetvec, false)
			if(distance <= radius)
			{
				if(IsPointVisible(pos,targetvec))
				{
					if(falloff != 0.0)
					{
						float ratio = (1.0-(distance/radius)*falloff);
						if(ratio < 0.5)
							ratio = 0.5;
						if(ratio >= 0.95)
							ratio = 1.0;
						damage *= ratio
					}

					if(IsValidWeapon(weapon) && IsValidClient(i))
					{
						SDKHooks_TakeDamage(i,owner,owner,damage, damagetype,weapon,NULL_VECTOR,NULL_VECTOR)
						if(ignition)
							TF2Util_IgnitePlayer(i, owner, 7.0, weapon);
					}
					else
					{
						SDKHooks_TakeDamage(i,owner,owner,damage, damagetype,-1,NULL_VECTOR,NULL_VECTOR, false);
					}
				}
			}
		}
	}
	if(visual)
		CreateParticle(-1, "ExplosionCore_MidAir", false, "", 0.1, pos);
	
	int random = GetRandomInt(1,3)
	switch(soundType)
	{
		case 1:
		{
			if(random == 1){
				EmitSoundToAll(ExplosionSound1, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound1, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound1, entity,_,soundPriority,_,soundLevel);
			}else if(random == 2){
				EmitSoundToAll(ExplosionSound2, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound2, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound2, entity,_,soundPriority,_,soundLevel);
			}else if(random == 3){
				EmitSoundToAll(ExplosionSound3, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound3, entity,_,soundPriority,_,soundLevel);
				EmitSoundToAll(ExplosionSound3, entity,_,soundPriority,_,soundLevel);
			}
		}
		case 2:
		{
			EmitSoundToAll(DetonatorExplosionSound, entity, -1, soundPriority-20, 0, soundLevel-0.15);
		}
		case 3:
		{
			EmitSoundToAll(OrnamentExplosionSound, entity, -1, soundPriority, 0, soundLevel);
		}
		default:
		{
			if(random == 1){
				EmitSoundToAll(ExplosionSound1, entity,_,soundPriority,_,soundLevel);
			}else if(random == 2){
				EmitSoundToAll(ExplosionSound2, entity,_,soundPriority,_,soundLevel);
			}else if(random == 3){
				EmitSoundToAll(ExplosionSound3, entity,_,soundPriority,_,soundLevel);
			}
		}
	}
}
stock bool IsPointVisible(const float start[3], const float end[3])
{
    TR_TraceRayFilter(start, end, MASK_SOLID, RayType_EndPoint, Filter_WorldOnly);
    return TR_GetFraction() == 1.0;
}
stock bool Filter_WorldOnly(int entity,int mask)
{
    return false;
}
stock void SendItemInfo(int client, const char[] text)
{
	Handle hBuffer = StartMessageOne("KeyHintText", client);
	BfWriteByte(hBuffer, 1);
	BfWriteString(hBuffer, text);
	EndMessage();
}
stock float GetAttribute(int entity, const char[] attrName, float defaultValue = 1.0)
{
	Address attribute_address = TF2Attrib_GetByName(entity, attrName);
	if(attribute_address != Address_Null)
		return TF2Attrib_GetValue(attribute_address);
	else
		return defaultValue;
}
stock bool IsOnDifferentTeams(entity1,entity2)
{
	int ent1Team = -10;
	if(HasEntProp(entity1, Prop_Send, "m_iTeamNum"))
		ent1Team = GetEntProp(entity1, Prop_Send, "m_iTeamNum");
	
	int ent2Team = -10;
	if(HasEntProp(entity2, Prop_Send, "m_iTeamNum"))
		ent2Team = GetEntProp(entity2, Prop_Send, "m_iTeamNum");
	
	if(ent2Team != -10){
		if(!(ent2Team == 2 || ent2Team == 3)){//They have a valid team, but it's not on red or blue.
			if(IsValidClient(entity2) && IsClientObserver(entity2)){
				return false;
			}
			return true;
		}
	}
	if(ent2Team != ent1Team)
	{
		return true;
	}
	
    return false; 
}
stock bool IsValidClient(client)
{
    if(client <= 0 || client > MaxClients) return false; 
	if(!IsClientInGame(client)) return false;
    return true; 
}
stock bool IsValidForDamage(entity)
{
    if(!IsValidEdict(entity)) return false; 
	if(IsValidClient(entity) && (!IsPlayerAlive(entity) || IsClientObserver(entity))) return false;	
	if(HasEntProp(entity, Prop_Data, "m_hActiveWeapon")) return true;
	if(GetEntProp(entity, Prop_Data, "m_takedamage") == 0) return false;
    return false; 
}
stock bool IsValidWeapon(int entity)
{
	return (entity > 0 && IsValidEdict(entity) && HasEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"));
}
stock int getOwner(int entity)
{
	return HasEntProp(entity, Prop_Data, "m_hOwnerEntity") ? GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity") : -1;
}
stock int getWeaponSlot(int client, int entity)
{
	return TF2Econ_GetItemLoadoutSlot(GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex"),TF2_GetPlayerClass(client));
}
stock CreateParticle(iEntity, char[] strParticle, bool bAttach = false, char[] strAttachmentPoint="", float time = 2.0,float fOffset[3]={0.0, 0.0, 0.0}, bool parentAngle = false, attachType = 0)
{
	if(attachType == 0)
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEdict(iParticle))
		{
			float fPosition[3], fAngles[3];
			
			if(IsValidEdict(iEntity))
			{
				GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fPosition);
			}
			if(parentAngle == true)
			{
				GetEntPropVector(iEntity, Prop_Data, "m_angRotation", fAngles); 
				TeleportEntity(iParticle, NULL_VECTOR, fAngles, NULL_VECTOR);
			}
			fPosition[0] += fOffset[0];
			fPosition[1] += fOffset[1];
			fPosition[2] += fOffset[2];
			
			TeleportEntity(iParticle, fPosition, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(iParticle, "effect_name", strParticle);
			
			if (bAttach == true)
			{
				SetVariantString("!activator");
				AcceptEntityInput(iParticle, "SetParent", iEntity, iParticle, 0);            
				
				if (StrEqual(strAttachmentPoint, "") == false)
				{
					SetVariantString(strAttachmentPoint);
					AcceptEntityInput(iParticle, "SetParentAttachmentMaintainOffset", iEntity, iParticle, 0);                
				}
			}
			// Spawn and start
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Start");
			
			if(time > 0.0){
				CreateTimer(time, Timer_KillParticle, EntIndexToEntRef(iParticle));
			}
		}
		return iParticle
	}
	else if (attachType == 1)
	{
	   static int table = INVALID_STRING_TABLE;
		if (table == INVALID_STRING_TABLE)
			table = FindStringTable("ParticleEffectNames");

		TE_Start("TFParticleEffect");
		TE_WriteNum("entindex", iEntity);
		TE_WriteNum("m_iParticleSystemIndex", FindStringIndex(table, strParticle));
		TE_WriteNum("m_iAttachType", 1); // Create at absorigin, and update to follow the entity
		
		if(time > 0.0){
			Handle pack;
			CreateDataTimer(time, Timer_KillTEParticle, pack);
			WritePackCell(pack, EntIndexToEntRef(iEntity));
		}
	}
	return true
}
public Action Timer_KillParticle(Handle timer, any data)
{	
	int entity = EntRefToEntIndex(data);
	if (IsValidEdict(entity))
	{
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(entity, "DispatchEffect");
		RemoveEdict(entity);
	}
	return Plugin_Stop;
}
public Action:Timer_KillTEParticle(Handle timer, Handle pack)
{
	ResetPack(pack);	
	int entity = EntRefToEntIndex(ReadPackCell(pack));
	
	if (IsValidEdict(entity))
	{
		SetVariantString("ParticleEffectStop");
		AcceptEntityInput(entity, "DispatchEffect");
	}
	
	return Plugin_Stop;
}