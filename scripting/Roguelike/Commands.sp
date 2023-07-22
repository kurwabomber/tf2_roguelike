public Action Command_GiveItem(int client, int args){
	char strTarget[MAX_TARGET_LENGTH], target_name[MAX_TARGET_LENGTH]
	int target_list[MAXPLAYERS], target_count;
	bool tn_is_ml;
	GetCmdArg(1, strTarget, sizeof(strTarget));
	if((target_count = ProcessTargetString(strTarget, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}

	char itemArgument[64];
	int id = -1;
	GetCmdArg(2, itemArgument, sizeof(itemArgument));
	for(int i = 0;i <= loadedItems;i++){
		if(StrEqual(itemArgument, availableItems[i].name, false)){
			id = i;
			break;
		}
	}
	if(id == -1){
		ReplyToCommand(client, "Invalid item name.");
		return Plugin_Handled;
	}

	char quantityArgument[64];
	GetCmdArg(3, quantityArgument, sizeof(quantityArgument));
	int amount = StringToInt(quantityArgument);
	if(amount > 0){
		for(int i = 0; i < target_count; ++i){
			if(!IsValidClient(target_list[i]))
				continue;

			for(int a = 0; a < amount; ++a){
				playerItems[target_list[i]][getFirstEmptyItemSlot(target_list[i])] = availableItems[id];
				++amountOfItem[client][id+1]; 
			}

			buffChange[target_list[i]] = true;
		}
		canteenCount[client] = amountOfItem[client][ItemID_Canteen];
	}else{
		ReplyToCommand(client, "Invalid quantity.");
		return Plugin_Handled;
	}

	return Plugin_Handled;
}