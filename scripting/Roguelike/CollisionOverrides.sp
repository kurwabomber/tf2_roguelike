public Action OnCollideUpgrade(entity, other){
    if(!IsValidClient(other))
        return Plugin_Continue;

    Menu_FrontPage(other, 0);
    SDKHook(entity, SDKHook_Touch, FullStopCollision);
    return Plugin_Stop;
}
public Action FullStopCollision(entity, other){
    SDKUnhook(entity, SDKHook_Touch, FullStopCollision);
    return Plugin_Stop;
}