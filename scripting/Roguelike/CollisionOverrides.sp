public Action OnCollideUpgrade(entity, other){
    if(!IsValidClient(other))
        return Plugin_Continue;

    Menu_FrontPage(other, 0);
    return Plugin_Stop;
}