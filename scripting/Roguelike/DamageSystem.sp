/*
    The hooks appear in order of when triggered.
    Must return Plugin_Changed to edit reference values (ie: attacker, damage, weapon, etc.)
*/

//Only thing calculated is damage & "mult_dmg" attribute
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
    if(IsValidClient(attacker) && IsValidWeapon(weapon)){
        damage += GetAttribute(attacker, "additive damage bonus", 0.0);

        if(amountOfItem[attacker][ItemID_Kurwabomber]){
            if(victim == attacker && !TF2Attrib_HookValueFloat(0.0, "no_self_blast_dmg", weapon)){
                isKurwabombered[attacker][victim] = true;
            }
        }
        if(amountOfItem[attacker][ItemID_ImmunityPenetration]){
            Buff deactivateInvulns;
            deactivateInvulns.init("Vulnerable", "Cannot be invulnerable", Buff_VulnerableDebuff, 1, attacker, 0.5, true);
            insertBuff(victim, deactivateInvulns);
        }
        if(amountOfItem[attacker][ItemID_Ricochet]){
            if(damagetype & DMG_BULLET || damagetype & DMG_BUCKSHOT){
                bool isBounced[MAXPLAYERS+1];
                isBounced[victim] = true
                int lastBouncedTarget = victim;
                float lastBouncedPosition[3];
                GetClientEyePosition(lastBouncedTarget, lastBouncedPosition)
                int i = 0
                int maxBounces = 2*amountOfItem[attacker][ItemID_Ricochet];
                for(int client=1;client<MaxClients && i < maxBounces;client++)
                {
                    if(isBounced[client]) {continue;}
                    if(!IsValidClient(client)) {continue;}
                    if(!IsPlayerAlive(client)) {continue;}
                    if(!IsOnDifferentTeams(client,attacker)) {continue;}

                    float VictimPos[3]; 
                    GetClientEyePosition(client, VictimPos); 
                    float distance = GetVectorDistance(lastBouncedPosition, VictimPos);
                    if(distance > 350.0) {continue;}
                    
                    isBounced[client] = true;
                    GetClientEyePosition(lastBouncedTarget, lastBouncedPosition)
                    lastBouncedTarget = client
                    SDKHooks_TakeDamage(client,attacker,attacker,damage,damagetype,-1,NULL_VECTOR,NULL_VECTOR);
                    i++
                    client = 1;
                }
            }
        }
        if(amountOfItem[attacker][ItemID_ChainExplosives]){
            if(damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE)
                EntityExplosion(attacker, damage*0.25*amountOfItem[attacker][ItemID_ChainExplosives], 144.0, damagePosition, _, _, victim, _, damagetype, weapon, 0.2);
        }
        if(amountOfItem[attacker][ItemID_ExplosiveImpact]){
            if(!(damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE))
                EntityExplosion(attacker, damage*0.5*amountOfItem[attacker][ItemID_ExplosiveImpact], 144.0, damagePosition, _, _, victim, _, damagetype, weapon, 0.2);
        }
        if(amountOfItem[attacker][ItemID_QuadDamage]){
            if(amountHits[attacker] % 10 == 0)
                damage *= 4.0;
        }
        if(amountOfItem[attacker][ItemID_CompoundInterest]){
            compoundInterestDuration[victim] = currentGameTime+2.0;
            ++compoundInterestStacks[victim][attacker];
        }
        if(amountOfItem[attacker][ItemID_GoopGunner]){
            int amountOfDebuffs = 0;
            if(TF2_IsPlayerInCondition(victim, TFCond_OnFire))
                ++amountOfDebuffs;
            if(TF2_IsPlayerInCondition(victim, TFCond_Dazed))
                ++amountOfDebuffs;
            if(TF2_IsPlayerInCondition(victim, TFCond_Bleeding))
                ++amountOfDebuffs;             
            if(TF2_IsPlayerInCondition(victim, TFCond_Jarated))
                ++amountOfDebuffs;      
            if(TF2_IsPlayerInCondition(victim, TFCond_MarkedForDeath))
                ++amountOfDebuffs;   
            if(TF2_IsPlayerInCondition(victim, TFCond_Milked))
                ++amountOfDebuffs;   
            if(TF2_IsPlayerInCondition(victim, TFCond_Plague))
                ++amountOfDebuffs;   
            if(TF2_IsPlayerInCondition(victim, TFCond_HealingDebuff))
                ++amountOfDebuffs;
            if(TF2_IsPlayerInCondition(victim, TFCond_Slowed))
                ++amountOfDebuffs;

            for(int buff = 0;buff < MAXBUFFS; ++buff)
            {
                if(playerBuffs[victim][buff].isDebuff)
                    ++amountOfDebuffs;
            }

            damage *= Pow(Pow(1.1, float(amountOfItem[attacker][ItemID_GoopGunner])), float(amountOfDebuffs));
        }

    }
    return Plugin_Changed;
}
//For a tank
public Action Tank_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
    if(IsValidClient(attacker) && IsValidWeapon(weapon)){
        if(amountOfItem[attacker][ItemID_ArmorPenetration]){
            char weaponClass[32];
            GetEntityClassname(weapon, weaponClass, sizeof(weaponClass));
            if(StrEqual(weaponClass, "tf_weapon_minigun"))
                damage *= 4.0;
        }
    }
    return Plugin_Changed;
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
        if(amountOfItem[attacker][ItemID_Kurwabomber]){
            if(isKurwabombered[attacker][attacker]){
                isKurwabombered[attacker][victim] = true;
            }
        }
    }
    if(IsValidClient(victim)){
        if(amountOfItem[victim][ItemID_EscapePlan] && GetClientHealth(victim) < damage){
            int medigun = TF2Util_GetPlayerLoadoutEntity(victim, 1);
            if(IsValidWeapon(medigun) && GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel") > 0.75){
                SetEntProp(medigun, Prop_Send, "m_bChargeRelease",  1);
                TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 5.0, victim);
                TF2_AddCondition(victim, TFCond_UberchargedHidden, 0.5, victim);
                TF2Util_SetPlayerActiveWeapon(victim, medigun);
            }
        }
    }
    return Plugin_Changed;
}