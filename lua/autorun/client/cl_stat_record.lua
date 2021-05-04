--[[
Created by u/Henotu
If you want to use parts of this code or you find a way to improve it, message me
I write LocalPlayer() everytime instead of making a variable because it led to bugs with gmod
]]
--Fixes Bugs from V 0.99
hook.Add("TTT2PlayerReady", "ttt_Statistics_Addon_record" ,function()
	if (tonumber(LocalPlayer():GetPData("stat_Bugfix0_99", 0)) ~= 1) then
		LocalPlayer():RemovePData("stat_TotalRoles")
		GetConVar("stat_Record"):SetBool(true)
		LocalPlayer():SetPData("stat_Bugfix0_99", 1)
	end
end)

local TShopExists = false
local Playerhurt = false
local RoundActive = false
local TimeAlive = 0

local function stat_HasNumber(tbl, nmb) -- Checks if a table has a given value
	if (nmb % 500 == 0 and nmb >= 500) then
		return true
	end
	for k ,v in pairs(tbl) do
		if v == tonumber(nmb) then
			return true
		end
	end
	return false
end

function StatisticsUpdatePData(Name, event1, event2) -- Increases the given Entry by one and
	if (GetConVar("stat_Record"):GetBool()) and (RoundActive) then
		LocalPlayer():SetPData(Name, LocalPlayer():GetPData(Name, 0) +1)
	end
	local numbers = {20, 50, 100, 200}
	local nmb = LocalPlayer():GetPData(Name, 0)
	if (event1 ~= nil) and (stat_HasNumber(numbers, nmb)) then
		net.Start("ttt_Statistics_Addon_Milestone")
		net.WriteString("[Statistic-Milestone] "..LocalPlayer():GetName().." "..event1.." "..nmb..event2)
		net.SendToServer()
	end
end

function NameDataBase(ID) -- makes an entry to save the names used by the AccountID
	local read = LocalPlayer():GetPData("stat_NameDataBase", "") -- read NameDataBase
	local split = string.Split(read, "\n") -- Split NameDataBase per line
	local testing = false
	for k , v in pairs(split) do --iterate through table, test if AccountID exists
		if v == tostring(ID:AccountID()) then
			testing = true
			do return end -- end function if it exists
		end
	end
	if (not testing) and (GetConVar("stat_Record"):GetBool()) then -- if AccountID doesnt exist, write it in the string
		LocalPlayer():SetPData("stat_NameDataBase", read .. ID:AccountID() .. "\n" .. ID:GetName() .. "\n")
	end
end

-- Get the current weapon the player is holding and Update its Kills and/or add it to the TotalWeapons-entry
local function FavWeapon()
	if (IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon())) then
		local weapon = LocalPlayer():GetActiveWeapon()
		local weaponName = weapon:GetPrintName() or "unarmed_name"
		if weaponName == "unarmed_name" then do return end end --Make sure the player isn't holstered
		local read = LocalPlayer():GetPData("stat_TotalWeapons", "")
		local split = string.Split(read, "\n")
		local testing = false
		for k , v in pairs(split) do
			if (v == weaponName) and (v ~= "") then
				testing = true
			end
		end
		if (not testing) and (GetConVar("stat_Record"):GetBool()) then
			LocalPlayer():SetPData("stat_TotalWeapons",read .. weaponName .. "\n")
		end
		StatisticsUpdatePData("stat_Weapon_" .. weaponName)
	end
end

-- makes an entry to store items bought by player
function ItemBought(equip)
	local equip = tostring(equip)
		local read = LocalPlayer():GetPData("stat_ItemBought", "")
		local split = string.Split(read, "\n")
		local testing = false
		local RealName = ""
		for k , v in pairs(split) do --iterate through table, test if ItemName exists
			if v == equip then
				testing = true
				do return end -- end function if it exists
			end
		end
		if (not testing) then -- if not, append name to string
			for k, v in pairs(weapons.GetList()) do -- Get the weapon "normal" names to save them in the line after the weapon id
				if v.id == equip then
					RealName = v.PrintName
					break
				end
			end
		end
		-- Make Custom names for the Radar, Disguiser and Bodyarmor, because otherwise nobody knows what "1" etc means
		if equip == "1" and (GetConVar("stat_Record"):GetBool()) and (RoundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Body Armor\n")
		elseif equip == "2" and (GetConVar("stat_Record"):GetBool()) and (RoundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Radar\n")
		elseif equip == "4" and (GetConVar("stat_Record"):GetBool()) and (RoundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Disguiser\n")
		elseif (GetConVar("stat_Record"):GetBool()) and (RoundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. RealName .. "\n")
		end
end

--Handles kills of any kind (where the LocalPlayer is part of)
net.Receive("stat_Attaker",function() --Receive the attaker entity by server
  local attaker = net.ReadEntity() -- define the attaker var
	net.Receive("stat_Victim",function() -- Recieve the victim entity
		local victim = net.ReadEntity() -- define victim entity
		-- Choose only the cases where the Localplayer gets killed and doesnt kill himself
		if (victim == LocalPlayer()) and (attaker ~= LocalPlayer()) and (attaker:IsValid()) and (type(attaker) == type(LocalPlayer())) then -- IMPORTANT attaker ~= LocalPlayer
			-- Uptdate or create the entry of how many times the player got killed by his attaker
			StatisticsUpdatePData(attaker:AccountID().."_KilledYou")
			NameDataBase(attaker)
			--Check if the player was shopping; TShopExists is set in the hook "TTTEquipmentTabs"
			if TShopExists == true then
				StatisticsUpdatePData("stat_DeathWhileShopping","achieved", " deaths while shopping")
			end
		elseif (attaker == LocalPlayer()) and (victim ~= LocalPlayer()) and (victim:IsValid()) and (not victim:IsBot()) and (type(victim) == type(LocalPlayer())) then
			-- Update the entry of how many times the player killed another Player
			StatisticsUpdatePData(victim:AccountID() .. "_KilledByYou", "has killed " ..victim:GetName().." for the", "th time")
			NameDataBase(victim)
			FavWeapon()
		elseif (attaker == LocalPlayer()) and (victim == LocalPlayer()) then
			-- Suicides
			StatisticsUpdatePData("stat_YouKilledYourself", "killed themselves"," times")
		elseif (attaker:IsWorld()) and (victim == LocalPlayer()) then
			-- Deaths by world
			StatisticsUpdatePData("stat_KilledByWorld")
		else
			-- Deaths by unknown
			if (victim == LocalPlayer()) then
				StatisticsUpdatePData("stat_UnknownDeath")
			end
		end
		if (victim == LocalPlayer()) and (GetConVar("stat_Record"):GetBool()) and (TimeAlive ~= 0) then
			StatisticsUpdatePData("stat_TimeSurvivedCount")
			LocalPlayer():SetPData("stat_TimeSurvivedTotal", LocalPlayer():GetPData("stat_TimeSurvivedTotal", 0) + (SysTime() - TimeAlive))
			TimeAlive = 0
		end
	end)
end)

-- When the player finds a unidentified body
net.Receive("stat_Player", function()
	StatisticsUpdatePData("stat_TotalPlayersFound")
end)

-- Updates Playerhurt when the player hurts someone; Update the Damage caused by the player
net.Receive("stat_Hurt", function()
	Playerhurt = true
	net.Receive("stat_Damage", function()
		local damage = net.ReadFloat()
		local max = GetConVar("stat_MaxDamage"):GetInt()
		if damage > max then
			damage = max -- Set the max damage defined by ConVar
		end
		if GetConVar("stat_Record"):GetBool() and (RoundActive) then
			LocalPlayer():SetPData("stat_TotalDamageDealt", LocalPlayer():GetPData("stat_TotalDamageDealt", 0) + damage)
		end
	end)
end)

-- Update the Damage received by the player
net.Receive("stat_GotHurt", function()
	net.Receive("stat_DamageRecieved", function()
		local damage = net.ReadFloat()
		local max = GetConVar("stat_MaxDamage"):GetInt()
		if damage > max then
			damage = max -- Set the max damage defined by ConVar
		end
		if GetConVar("stat_Record"):GetBool() and (RoundActive) then
			LocalPlayer():SetPData("stat_TotalDamageReceived", LocalPlayer():GetPData("stat_TotalDamageReceived", 0) + damage)
		end
	end)
end)

--Update the Rounds Won/Lost
net.Receive("stat_result", function()
	local result = net.ReadString()
	if result == LocalPlayer():GetTeam() then
		StatisticsUpdatePData("stat_RoundsWon")
	else
		StatisticsUpdatePData("stat_RoundsLost")
	end
end)

--Fixes Bugs from V 0.99
hook.Add("TTT2PlayerReady", "ttt_Statistics_Addon_record" ,function()
	if (tonumber(LocalPlayer():GetPData("stat_Bugfix0_99", 0)) ~= 1) then
		LocalPlayer():RemovePData("stat_TotalRoles")
		GetConVar("stat_Record"):SetBool(true)
		LocalPlayer():SetPData("stat_Bugfix0_99", 1)
	end
end)

--Get item bought by player and update - if needed - the item-list
hook.Add("TTTBoughtItem","ttt_Statistics_Addon",function(is_item, equip) -- is_item is not needed
	local RealName = ""
	for k, v in pairs(weapons.GetList()) do -- Get the weapon's "normal" name
		if v.id == tostring(equip) then
			RealName = v.PrintName
			break
		else
			RealName = tostring(equip)
		end
	end
	StatisticsUpdatePData(equip .. "_BoughtByPlayer", "has bought the item "..RealName.." for the", "th time")
	ItemBought(equip)
end)

--Update Roles; roundsPlayed
hook.Add("TTTBeginRound", "ttt_Statistics_Addon", function()
	RoundActive = true
	Playerhurt = false
	TimeAlive = SysTime()
	local Rolename = "stat_TimesYouWere_" .. LocalPlayer():GetRoleString()
	local TotalRolesString = LocalPlayer():GetPData("stat_TotalRoles", "")
	local TotalRolesTable = string.Split(TotalRolesString, "\n")
	local testing = false
	-- Test if the role is stored in the Database, if not store it
	for k, v in pairs(TotalRolesTable) do
		if v == LocalPlayer():GetRoleString() then
			testing = true
			break
		end
	end
	if (not testing) and (GetConVar("stat_Record"):GetBool()) then
		TotalRolesString = TotalRolesString .. LocalPlayer():GetRoleString() .. "\n"
		LocalPlayer():SetPData("stat_TotalRoles", TotalRolesString)
	end
	-- Update the times the player was the role
	StatisticsUpdatePData(Rolename)
	--How many times the LocalPlayer() started rounds:
	StatisticsUpdatePData("stat_RoundsPlayed", "played their", "th round")
end)


hook.Add("TTTEndRound", "ttt_Statistics_Addon", function()
	TShopExists = false -- Just in case it doesn't got updated
	RoundActive = false
	-- Update the DB if player hurt someone
	if (not Playerhurt) then
		StatisticsUpdatePData("stat_NoOneHurt")
	end
	if (TimeAlive ~= 0) and (GetConVar("stat_Record"):GetBool()) then
		LocalPlayer():SetPData("stat_TimeSurvivedCount", LocalPlayer():GetPData("stat_TimeSurvivedCount", 0)+1)
		LocalPlayer():SetPData("stat_TimeSurvivedTotal", tonumber(LocalPlayer():GetPData("stat_TimeSurvivedTotal", 0)) + (SysTime() - TimeAlive))
		TimeAlive = 0
	end
end)

-- Update TShopExists when the T-shop gets opened/closed
hook.Add("TTTEquipmentTabs", "ttt_Statistics_Addon", function(shoppanel)
	TShopExists = true
	function shoppanel:OnRemove()
		TShopExists = false
	end
end)

--Records if someone types "!rdm [PLAYERNAME]" in Chat; Part of a easteregg for r/Arrrrr
hook.Add("OnPlayerChat", "ttt_Statistics_Addon", function(ply, Text)
	if ply == LocalPlayer() then
		local LowerText = string.lower(Text)
		local SearchText = string.lower("!rdm " .. LocalPlayer():GetName())
		if ((string.find(LowerText, SearchText)) ~= nil) then
			StatisticsUpdatePData("stat_Rdm")
		end
	end
end)