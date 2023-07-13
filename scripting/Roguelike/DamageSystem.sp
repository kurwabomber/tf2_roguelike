/*
    The hooks appear in order of when triggered.
    Must return Plugin_Changed to edit reference values (ie: attacker, damage, weapon, etc.)
*/

//Only thing calculated is damage & "mult_dmg" attribute
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
    if(IsValidClient(attacker) && IsValidWeapon(weapon)){
        for(int item=0;item<=loadedItems;++item){

            //Do attacker stuff
            if(amountOfItem[attacker][item] > 0){
                switch(item){
                    case (_:ItemID_Kurwabomber):{
                        if(victim == attacker && !TF2Attrib_HookValueFloat(0.0, "no_self_blast_dmg", weapon)){
                            isKurwabombered[attacker][victim] = true;
                        }
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}

//Crit stuff
public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3],int damagecustom, CritType &critType){
    return Plugin_Continue;
}

//Crit stuff but crit damage has already been modified
public Action TF2_OnTakeDamageModifyRules(int victim, int &attacker, int &inflictor, float &damage,
int &damagetype, int &weapon, float damageForce[3], float damagePosition[3],
int damagecustom, CritType &critType){
    return Plugin_Continue;
}

//Final
public Action OnTakeDamageAlive(victim, &attacker, &inflictor, float &damage, &damagetype, &weapon, float damageForce[3], float damagePosition[3], damagecustom){
    if(IsValidClient(attacker)){
        for(int item=0;item<=loadedItems;++item){
            if(amountOfItem[attacker][item] > 0){
                switch(item){
                    case (_:ItemID_Kurwabomber):{
                        if(isKurwabombered[attacker][attacker]){
                            isKurwabombered[attacker][victim] = true;
                        }
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}