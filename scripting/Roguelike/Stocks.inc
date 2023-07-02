stock void SendItemInfo(int client, const char[] text)
{
	Handle hBuffer = StartMessageOne("KeyHintText", client);
	BfWriteByte(hBuffer, 1);
	BfWriteString(hBuffer, text);
	EndMessage();
}
stock float GetAttribute(int entity, const char[] attrName, float value = 1.0)
{
	Address attribute_address = TF2Attrib_GetByName(entity, attrName);
	if(attribute_address != Address_Null)
		value = TF2Attrib_GetValue(attribute_address);

	return value;
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