#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <tf2_isPlayerInSpawn>
#include <tf_ontakedamage>
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <dhooks>
#include <morecolors>
#include <tf2utils>
#include <tf2attributes>
#include <tf_econ_data>

#pragma tabsize 0

#define TICKINTERVAL 0.015
#define TICKRATE 66.67
#define MAXBUFFS 12
#define POWERUPS_COUNT 11
#define MAX_HELD_ITEMS 100
#define MAX_ITEMS 200
#define MAX_ITEMS_PER_WAVE 21
#define MAX_WAVES 30
#define PLUGIN_VERSION "INDEV-1.0"
#define MAXENTITIES 2048

//Sounds
#define LARGE_EXPLOSION_SOUND "mvm/sentrybuster/mvm_sentrybuster_explode.wav"

// Plugin Info
public Plugin:myinfo =
{
	name = "TF2 Roguelike",
	author = "Razor",
	description = "MvM Gamemode stylized as a roguelike",
	version = PLUGIN_VERSION,
	url = "https://github.com/kurwabomber/Incremental-Fortress",
}

#include "Roguelike/Stocks.inc"
#include "Roguelike/GlobalVariables.sp"
#include "Roguelike/Functions.sp"
#include "Roguelike/OnPluginStart.sp"
#include "Roguelike/OnConnectDisconnect.sp"
#include "Roguelike/DamageSystem.sp"
#include "Roguelike/CollisionOverrides.sp"
#include "Roguelike/DHooks.sp"
#include "Roguelike/Events.sp"
#include "Roguelike/Timers.sp"
#include "Roguelike/MenuFrontend.sp"
#include "Roguelike/MenuBackend.sp"
#include "Roguelike/Commands.sp"