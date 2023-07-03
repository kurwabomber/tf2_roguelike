public Event_WaveComplete(Handle event, const char[] name, bool dontBroadcast){
    wavesCleared++;
}
public Event_WaveBegin(Handle event, const char[] name, bool dontBroadcast){
    
}
public Event_ResetStats(Handle event, const char[] name, bool dontBroadcast){
    wavesCleared = 0;
}

public OnEntityCreated(entity, const char[] classname)
{
	if(!IsValidEdict(entity) || entity < 0 || entity > 2048)
		return;

    if(StrEqual(classname, "item_powerup_rune", false))
		RemoveEntity(entity);
}