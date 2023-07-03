public MRESReturn OnDropPowerup(int client, Handle hParams){
	if(!IsValidClient(client))
		return MRES_Ignored;

	if(!DHookGetParam(hParams, 1)){
		return MRES_Supercede;
	}
	return MRES_Ignored;
}