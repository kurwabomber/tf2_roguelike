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