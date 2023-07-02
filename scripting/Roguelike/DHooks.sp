public MRESReturn OnEnterUpgradeStation(int entity)
{
	if(!IsValidClient(entity))
		return MRES_Ignored;

    PrintToChat(entity, "test");
	return MRES_Ignored;
}