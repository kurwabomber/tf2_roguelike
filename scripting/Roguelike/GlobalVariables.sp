//Temp buffs for players
enum struct Buff{
	//All values start at 0
	char name[32];
	char description[64];
	int id; //For any custom effects, use a switch statement on logic.
	int priority;
	int inflictor; //UserID 
	float duration; //Measured in engine time (GetGameTime())
	float additiveDamageRaw;
	float additiveDamageMult;
	float multiplicativeDamage;
	float additiveAttackSpeedMult;
	float multiplicativeAttackSpeedMult;
	float additiveMoveSpeedMult;
	float additiveDamageTaken;
	float multiplicativeDamageTaken;
	bool isDebuff;

	void clear(){
		this.name = "";
		this.description = "";
		this.id = 0;
		this.priority = 0;
		this.inflictor = 0;
		this.duration = 0.0;
		this.additiveDamageRaw = 0.0;
		this.additiveDamageMult = 0.0;
		this.multiplicativeDamage = 1.0;
		this.additiveAttackSpeedMult = 0.0;
		this.multiplicativeAttackSpeedMult = 1.0;
		this.additiveMoveSpeedMult = 0.0;
		this.additiveDamageTaken = 0.0;
		this.multiplicativeDamageTaken = 1.0;
		this.isDebuff = false;
	}
	void init(const char sName[32], const char sDescription[64], int iID, int iPriority, int iInflictor, float fDuration, bool bIsDebuff = false)
	{
		this.clear();
		this.name = sName;
		this.description = sDescription;
		this.id = iID;
		this.priority = iPriority;
		this.inflictor = iInflictor;
		this.duration = fDuration+GetGameTime();
		this.isDebuff = bIsDebuff;
	}
}
enum ItemID{
	ItemID_None=0,
	ItemID_MoreGun,
	ItemID_FireRate,
	ItemID_RocketSpecialist,
	ItemID_ExtendedMagazine,
	ItemID_Scavenger,
	ItemID_PlayingWithDanger,
	ItemID_ExplosiveSpecialist,
	ItemID_TheQuickestFix,
	ItemID_Kurwabomber,
	ItemID_TankBuster,
	ItemID_ExtraMunitions,
	ItemID_PocketDispenser,
	ItemID_BigBaboonHeart,
	ItemID_ProjectileSpeed,
	ItemID_MoreBulletperBullet,
	ItemID_Canteen,
	ItemID_UberchargeCanteen,
	ItemID_KritzCanteen,
	ItemID_IlluminationCanteen,
	ItemID_WardingCanteen,
	ItemID_CollectionCanteen,
	ItemID_HeavyWeapons,
	ItemID_Ricochet,
	ItemID_ChainExplosives,
	ItemID_ExplosiveImpact,
	ItemID_FlyingGuillotine,
	ItemID_EscapePlan,
	ItemID_QuadDamage,
	ItemID_AustraliumAlchemist,
	ItemID_CompoundInterest,
	ItemID_GoopGunner,
	ItemID_TheWeaver,
	ItemID_BiomechanicalEngineering,
	ItemID_Martyr,
	ItemID_MedicalAssistance,
	ItemID_FraggyExplosives,
	ItemID_ArmorPenetration,
	ItemID_TrenMaxxdoser,
	ItemID_DecentlyBalanced,
	ItemID_SlowerThanaSpeedingBullet,
	ItemID_PandorasCanteen,
	ItemID_ProjectilePenetration,
	ItemID_DrunkenBomber,
	ItemID_PrecisionTargeting,
	ItemID_GiantSlayer,
	ItemID_Autocollect,
	ItemID_Cleave,
	ItemID_Multishot,
	ItemID_BiggerCaliber,
	ItemID_LongerMelee,
	ItemID_Phaselock,
	ItemID_PrecisionNotAccuracy,
	ItemID_AcceleratedDegeneration,
	ItemID_Bargain,
	ItemID_Snare,
	ItemID_DumpsterDiver,
	ItemID_ImmunityPenetration,
	ItemID_MeteorShower,
	ItemID_Camouflage,
	ItemID_Headshot,
	ItemID_ProjectileInertia,
	ItemID_BossSlayer,
	ItemID_Killstreak,
	ItemID_Leeches,
	ItemID_PowerfulSwings,
	ItemID_DeadlierDecay,
	ItemID_Inferno,
	ItemID_Wounding,
};
enum ItemRarity{
	ItemRarity_Normal=0,
	ItemRarity_Unique,
	ItemRarity_Strange,
	ItemRarity_Genuine,
	ItemRarity_Collectors,
	ItemRarity_Unusual,
	ItemRarity_SelfMade,
	ItemRarity_Valve,
}
enum struct Tags{
	bool reqExplosive;
	bool reqProjectile;
	bool reqBullet;
	bool reqCanteen;
	bool reqRocket;
	int classReq;
	int maximum;
	bool isUltimate;
	char requiredWeaponClassname[64]
	int allowedWeapons[32];
	
	void clear(){
		this.reqExplosive = false;
		this.reqProjectile = false;
		this.reqBullet = false;
		this.reqCanteen = false;
		this.reqRocket = false;
		this.classReq = 0;
		this.maximum = 0;
		this.isUltimate = false;
	}
}
enum struct Item{
	//All values start at 0
	char name[32];
	char description[512];
	ItemID id;
	int weight;
	ItemRarity rarity;
	int cost;
	bool isBought;
	Tags tagInfo;

	void clear(){
		this.name = "";
		this.description = "";
		this.id = ItemID_None;
		this.weight = 0;
		this.rarity = ItemRarity_Normal;
		this.cost = 0;
		this.isBought = false;
		this.tagInfo.clear();
	}
	void init(const char sName[32], const char sDescription[512], ItemID iID, int iWeight, ItemRarity iRarity, int iCost)
	{
		this.name = sName;
		this.description = sDescription;
		this.id = iID;
		this.weight = iWeight;
		this.rarity = iRarity;
		this.cost = iCost;
	}
}
enum {
	Buff_Empty=0,
	Buff_DefenseBuff,
	Buff_IlluminatedDebuff,
	Buff_VulnerableDebuff,
};
enum {
	Powerup_Strength=0,
	Powerup_Haste,
	Powerup_Regeneration,
	Powerup_Resistance,
	Powerup_Vampire,
	Powerup_Reflect,
	Powerup_Precision,
	Powerup_Agility,
	Powerup_Knockout,
	Powerup_King,
	Powerup_Plague,
	Powerup_Supernova,
};
enum{
	TF_PROJECTILE_NONE=0,
	TF_PROJECTILE_BULLET,
	TF_PROJECTILE_ROCKET,
	TF_PROJECTILE_PIPEBOMB,
	TF_PROJECTILE_PIPEBOMB_REMOTE,
	TF_PROJECTILE_SYRINGE,
	TF_PROJECTILE_FLARE,
	TF_PROJECTILE_JAR,
	TF_PROJECTILE_ARROW,
	TF_PROJECTILE_FLAME_ROCKET,
	TF_PROJECTILE_JAR_MILK,
	TF_PROJECTILE_HEALING_BOLT,
	TF_PROJECTILE_ENERGY_BALL,
	TF_PROJECTILE_ENERGY_RING,
	TF_PROJECTILE_PIPEBOMB_PRACTICE,
	TF_PROJECTILE_CLEAVER,
	TF_PROJECTILE_STICKY_BALL,
	TF_PROJECTILE_CANNONBALL,
	TF_PROJECTILE_BUILDING_REPAIR_BOLT,
	TF_PROJECTILE_FESTIVE_ARROW,
	TF_PROJECTILE_THROWABLE,
	TF_PROJECTILE_SPELL,
	TF_PROJECTILE_FESTIVE_JAR,
	TF_PROJECTILE_FESTIVE_HEALING_BOLT,
	TF_PROJECTILE_BREADMONSTER_JARATE,
	TF_PROJECTILE_BREADMONSTER_MADMILK,
	TF_PROJECTILE_GRAPPLINGHOOK,
	TF_PROJECTILE_SENTRY_ROCKET,
	TF_PROJECTILE_BREAD_MONSTER,
	TF_PROJECTILE_NONE2,
	TF_PROJECTILE_NONE3,
	TF_PROJECTILE_METEORSHOWER,
};

Buff playerBuffs[MAXPLAYERS+1][MAXBUFFS+1];
bool buffChange[MAXPLAYERS+1] = {false,...};
bool isHooked[MAXPLAYERS+1];
float currentGameTime = 0.0;
int wavesCleared = 0;
int powerupSelected[MAXPLAYERS+1] = {-1,...};
int currentWaveViewed[MAXPLAYERS+1] = {0,...};
Item playerItems[MAXPLAYERS+1][MAX_HELD_ITEMS];
Item savedPlayerItems[MAXPLAYERS+1][MAX_HELD_ITEMS];
Item generatedPlayerItems[MAXPLAYERS+1][MAX_WAVES][MAX_ITEMS_PER_WAVE];
Item generatedPlayerUltimateItems[MAXPLAYERS+1][MAX_ITEMS_PER_WAVE];
Item availableItems[MAX_ITEMS];
int timesItemGenerated[MAXPLAYERS+1][MAX_ITEMS];
int amountOfItem[MAXPLAYERS+1][MAX_ITEMS];
int loadedItems = 0;
int canteenCount[MAXPLAYERS+1];
float canteenCooldown[MAXPLAYERS+1];
int amountHits[MAXPLAYERS+1];
int compoundInterestStacks[MAXPLAYERS+1][MAXPLAYERS+1];
float compoundInterestDuration[MAXPLAYERS+1];
float compoundInterestDamageTime[MAXPLAYERS+1];
int projectileBounces[MAXENTITIES+1];
float switchMedicalTargetTime[MAXPLAYERS+1];
int priorityTargeting[MAXPLAYERS+1][MAXPLAYERS+1];
int totalWaveCount;
//Huds
Handle itemDisplayHUD;
//SDKCalls
Handle SDKCall_GetWeaponProjectile;

//Item Logic
bool isKurwabombered[MAXPLAYERS+1][MAXPLAYERS+1];