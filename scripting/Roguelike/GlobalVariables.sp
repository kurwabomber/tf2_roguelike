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
	float additiveArmorRecharge;

	void clear(){
		this.name = "";
		this.description = "";
		this.id = 0;
		this.priority = 0;
		this.inflictor = 0;
		this.duration = 0.0;
		this.additiveDamageRaw = 0.0;
		this.additiveDamageMult = 0.0;
		this.multiplicativeDamage = 0.0;
		this.additiveAttackSpeedMult = 0.0;
		this.multiplicativeAttackSpeedMult = 0.0;
		this.additiveMoveSpeedMult = 0.0;
		this.additiveDamageTaken = 0.0;
		this.multiplicativeDamageTaken = 0.0;
		this.additiveArmorRecharge = 0.0;
	}
	void init(const char sName[32], const char sDescription[64], int iID, int iPriority, int iInflictor, float fDuration)
	{
		this.name = sName;
		this.description = sDescription;
		this.id = iID;
		this.priority = iPriority;
		this.inflictor = iInflictor;
		this.duration = fDuration+GetGameTime();
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
	int classReq;
	int maximum;
	
	void clear(){
		this.reqExplosive = false;
		this.reqProjectile = false;
		this.reqBullet = false;
		this.classReq = 0;
		this.maximum = 0;
	}
}
enum struct Item{
	//All values start at 0
	char name[32];
	char description[128];
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
	void init(const char sName[32], const char sDescription[128], ItemID iID, int iWeight, ItemRarity iRarity, int iCost)
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
Item availableItems[MAX_ITEMS];
int timesItemGenerated[MAXPLAYERS+1][MAX_ITEMS];
int amountOfItem[MAXPLAYERS+1][MAX_ITEMS];
int loadedItems = 0;
//Huds
Handle itemDisplayHUD;
//SDKCalls
Handle SDKCall_GetWeaponProjectile;

//Item Logic
bool isKurwabombered[MAXPLAYERS+1][MAXPLAYERS+1];