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