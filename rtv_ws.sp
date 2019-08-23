#include <sourcemod>
#include <cstrike>

#pragma semicolon 1
#pragma newdecls required

//Процент, который надо набрать, чтобы запустилось голосование
#define PERCENT 70.0
//Через сколько раундов доступно голосование
#define ROUNDS_MIN 7

bool bChange[MAXPLAYERS+1], bVoting = false;

public Plugin myinfo ={
	name = "RTV for Workshop Maps",
	author = "XTANCE",
	description = "Rock the vote",
	version = "0.1",
	url = "https://t.me/xtance"
}

public void OnPluginStart(){
	RegConsoleCmd("sm_rtv", Action_RTV, "RTV");
	RegConsoleCmd("rtv", Action_RTV, "RTV");
}

public void OnMapStart(){
	bVoting = false;
}

public Action Action_RTV(int iClient, int iArgs){
	if (CS_GetTeamScore(2) + CS_GetTeamScore(3) < ROUNDS_MIN) PrintToChat(iClient, " \x06>>\x01 Надо сыграть хотя бы \x06%i раундов!",ROUNDS_MIN);
	else{
		if (bVoting) PrintToChat(iClient, " \x06>>\x01 Сейчас голосовать нельзя.");
		else if (bChange[iClient]) PrintToChat(iClient, " \x06>>\x01 Ты уже голосовал за смену карты!");
		else{
			bChange[iClient] = true;
			float f = GetPercent();
			if (f >= PERCENT){
				bVoting = true;
				for (int i = 1; i <= MaxClients; i++) bChange[i] = false;
				PrintToChatAll(" \x06>>\x01 Начинается голосование за смену карты!");
				PrintToChatAll(" \x06>>\x01 Процент игроков за: \x06%.0f%%\x01",f);
				
				
				//если этого не сделать, будем играть до смены сторон, а потом внезапно кончится карта
				//можете удалить строчку ниже, если у вас и так нет смены сторон
				ServerCommand("sm_cvar mp_halftime 0");
				
				//не костыль, а фича.
				ServerCommand("mp_maxrounds 1");
			}
			else PrintToChatAll(" \x06>>\x01 %N хочет сменить карту -> \x06/rtv\x01 [%.0f%% из %.0f%%]",iClient,f,PERCENT);
		}
	}
	return Plugin_Handled;
}

public void OnClientConnected(int iClient){
	bChange[iClient] = false;
}

float GetPercent(){
	int iChange, iPlayers;
	for (int i = 1; i<=MaxClients; i++){
		if (IsClientInGame(i)){
			if (bChange[i]) iChange++;
			iPlayers++;
		}
	}
	return (float(iChange)*100.0 / float(iPlayers));
}