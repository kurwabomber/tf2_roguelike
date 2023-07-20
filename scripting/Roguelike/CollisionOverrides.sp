public Action OnCollideUpgrade(entity, other){
    if(!IsValidClient(other))
        return Plugin_Continue;

    Menu_FrontPage(other, 0);
    return Plugin_Stop;
}
public Action OnStopCollideUpgrade(entity, other){
    if(!IsValidClient(other))
        return Plugin_Continue;

    CancelClientMenu(other);
    return Plugin_Stop;
}
public Action FullStopCollision(entity, other){
    return Plugin_Stop;
}
public Action OnStartBounceTouch(entity, other)
{
	if (other > 0 && other <= MaxClients)
		return Plugin_Continue;
		
	int owner = getOwner(entity);
	if(!IsValidClient(owner))
		return Plugin_Continue;
	
	if (projectileBounces[entity] >= amountOfItem[owner][ItemID_DrunkenBomber])
		return Plugin_Continue;

	char classname[32];
	GetEntityClassname(entity, classname, sizeof(classname));
	float projectileOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", projectileOrigin);

	if(StrEqual(classname, "tf_projectile_rocket") || StrEqual(classname, "tf_projectile_sentryrocket") || StrEqual(classname, "tf_projectile_energy_ball")){
		for(int i = 1; i<=MaxClients;++i){
			if(!IsValidClient(i))
				continue;
			if(!(IsOnDifferentTeams(owner, i) || owner == i))
				continue;
			float playerOrigin[3];
			GetClientAbsOrigin(i, playerOrigin);
			
			if(GetVectorDistance(playerOrigin, projectileOrigin) <= 144.0)
				return Plugin_Continue;
		}
	}

	SDKHook(entity, SDKHook_Touch, OnBounceTouch);
	return Plugin_Handled;
}
public Action OnBounceTouch(entity, other)
{
	float vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
	
	float vAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
	
	float vVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVelocity);
	
	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TEF_ExcludeEntity, entity);
	
	if(!TR_DidHit(trace))
	{
		delete trace;
		return Plugin_Continue;
	}
	
	float vNormal[3];
	TR_GetPlaneNormal(trace, vNormal);
	
	float dotProduct = GetVectorDotProduct(vNormal, vVelocity);
	
	ScaleVector(vNormal, dotProduct);
	ScaleVector(vNormal, 2.0);
	
	float vBounceVec[3];
	SubtractVectors(vVelocity, vNormal, vBounceVec);
	
	float vNewAngles[3];
	GetVectorAngles(vBounceVec, vNewAngles);
	
    TeleportEntity(entity, NULL_VECTOR, vNewAngles, vBounceVec);
    
	delete trace;

	projectileBounces[entity]++;
	SDKUnhook(entity, SDKHook_Touch, OnBounceTouch);
	return Plugin_Handled;
}
public bool TEF_ExcludeEntity(entity, contentsMask, any:data)
{
	return (entity != data);
}
public Action:CollisionFrag(entity, client)
{
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity")
	if(!IsValidClient(owner))
		return Plugin_Continue;
	if(!IsValidForDamage(client))
		return Plugin_Continue;
	if(!IsOnDifferentTeams(owner,client))
		return Plugin_Continue;

	SDKHooks_TakeDamage(client, owner, owner, 15.0*TF2_GetDamageModifiers(owner), DMG_BULLET, _, NULL_VECTOR, NULL_VECTOR);

	RemoveEntity(entity);
	return Plugin_Stop;
}