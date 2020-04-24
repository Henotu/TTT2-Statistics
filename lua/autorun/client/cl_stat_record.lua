--[[
Created by u/Henotu
If you want to use parts of this code or you find a way to improve it, message me
I write LocalPlayer() everytime instead of making a variable because it led to bugs with gmod
]]
--Fixes Bugs from V 0.99
if LocalPlayer():GetPData("stat_Bugfix0_99", 0) ~= 1 then
	LocalPlayer():RemovePData("stat_TotalRoles")
	GetConVar("stat_Record"):SetBool(true)
	LocalPlayer():SetPData("stat_Bugfix0_99", 1)
end

local tshop_exists = false
local stat_playerhurt = false
local roundActive = false

local function stat_HasNumber(tbl, nmb) -- Checks if a table has a given value
	for k ,v in pairs(tbl) do
		if v == tonumber(nmb) then
			return true
		end
	end
	return false
end

function stat_UpdatePData(Name, event1, event2) -- Increases the given Entry by one and
	if (GetConVar("stat_Record"):GetBool()) and (roundActive) then
		LocalPlayer():SetPData(Name, LocalPlayer():GetPData(Name, 0) +1)
	end
	local numbers = {20, 50, 100, 200, 500, 1000, 1500, 2000, 2500, 3000}
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
function stat_FavWeapon()
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
		stat_UpdatePData("stat_Weapon_" .. weaponName)
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
		if equip == "1" and (GetConVar("stat_Record"):GetBool()) and (roundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Body Armor\n")
		elseif equip == "2" and (GetConVar("stat_Record"):GetBool()) and (roundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Radar\n")
		elseif equip == "4" and (GetConVar("stat_Record"):GetBool()) and (roundActive) then
			LocalPlayer():SetPData("stat_ItemBought", read .. equip .. "\n" .. "Disguiser\n")
		elseif (GetConVar("stat_Record"):GetBool()) and (roundActive) then
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
			stat_UpdatePData(attaker:AccountID().."_KilledYou")
			NameDataBase(attaker)
			--Check if the player was shopping; tshop_exists is set in the hook "TTTEquipmentTabs"
			if tshop_exists == true then
				stat_UpdatePData("stat_DeathWhileShopping","achieved", " deaths while shopping")
			end
		elseif (attaker == LocalPlayer()) and (victim ~= LocalPlayer()) and (victim:IsValid()) and (not victim:IsBot()) and (type(victim) == type(LocalPlayer())) then
			-- Update the entry of how many times the player killed another Player
			stat_UpdatePData(victim:AccountID() .. "_KilledByYou", "has killed " ..victim:GetName().." for the", "th time")
			NameDataBase(victim)
			stat_FavWeapon()
		elseif (attaker == LocalPlayer()) and (victim == LocalPlayer()) then
			-- Suicides
			stat_UpdatePData("stat_YouKilledYourself", "killed himself"," times")
		elseif (attaker:IsWorld()) and (victim == LocalPlayer()) then
			-- Deaths by world
			stat_UpdatePData("stat_KilledByWorld")
		else
			-- Deaths by unknown
			if (victim == LocalPlayer()) then
				stat_UpdatePData("stat_UnknownDeath")
			end
		end
	end)
end)

-- When the player finds a unidentified body
net.Receive("stat_Player", function()
	local player = net.ReadEntity()
	if player == LocalPlayer() then
		stat_UpdatePData("stat_TotalPlayersFound")
	end
end)

-- Updates stat_playerhurt when the player hurts someone; Update the Damage caused by the player
net.Receive("stat_Hurt", function()
	local entity = net.ReadEntity()
	if entity == LocalPlayer() then
		stat_playerhurt = true
		net.Receive("stat_Damage", function()
			local damage = net.ReadFloat()
			local max = GetConVar("stat_MaxDamage"):GetInt()
			if damage > max then
				damage = max -- Set the max damage defined by ConVar
			end
			if GetConVar("stat_Record"):GetBool() and (roundActive) then
				LocalPlayer():SetPData("stat_TotalDamageDealt", LocalPlayer():GetPData("stat_TotalDamageDealt", 0) + damage)
			end
		end)
	end
end)

-- Update the Damage received by the player
net.Receive("stat_GotHurt", function()
	local entity = net.ReadEntity()
	if entity == LocalPlayer() then
		net.Receive("stat_DamageRecieved", function()
			local damage = net.ReadFloat()
			local max = GetConVar("stat_MaxDamage"):GetInt()
			if damage > max then
				damage = max -- Set the max damage defined by ConVar
			end
			if GetConVar("stat_Record"):GetBool() and (roundActive) then
				LocalPlayer():SetPData("stat_TotalDamageReceived", LocalPlayer():GetPData("stat_TotalDamageReceived", 0) + damage)
			end
		end)
	end
end)

--Update the Rounds Won/Lost
net.Receive("stat_result", function()
	local result = net.ReadString()
	if result == LocalPlayer():GetTeam() then
		stat_UpdatePData("stat_RoundsWon")
	else
		stat_UpdatePData("stat_RoundsLost")
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
	stat_UpdatePData(equip .. "_BoughtByPlayer", "has bought the item "..RealName.." for the", "th time")
	ItemBought(equip)
end)

--Update Roles; roundsPlayed
hook.Add("TTTBeginRound", "ttt_Statistics_Addon", function()
	roundActive = true
	stat_playerhurt = false
	local stat_name = "stat_TimesYouWere_" .. LocalPlayer():GetRoleString()
	local totalRoles_string = LocalPlayer():GetPData("stat_TotalRoles", "")
	local totalRoles_table = string.Split(totalRoles_string, "\n")
	local stat_testing = false
	-- Test if the role is stored in the Database, if not store it
	for k, v in pairs(totalRoles_table) do
		if v == LocalPlayer():GetRoleString() then
			stat_testing = true
			break
		end
	end
	if (not testing) and (GetConVar("stat_Record"):GetBool()) then
		totalRoles_string = totalRoles_string .. LocalPlayer():GetRoleString() .. "\n"
		LocalPlayer():SetPData("stat_TotalRoles", totalRoles_string)
	end
	-- Update the times the player was the role
	stat_UpdatePData(stat_name)
	--How many times the LocalPlayer() started rounds:
	stat_UpdatePData("stat_RoundsPlayed", "played his/her", "th round")
end)


hook.Add("TTTEndRound", "ttt_Statistics_Addon", function()
	tshop_exists = false -- Just in case it doesn't got updated
	roundActive = false
	-- Update the DB if player hurt someone
	if (not stat_playerhurt) then
		stat_UpdatePData("stat_NoOneHurt")
	end
end)

-- Update tshop_exists when the T-shop gets opened/closed
hook.Add("TTTEquipmentTabs", "ttt_Statistics_Addon", function(shoppanel)
	tshop_exists = true
	function shoppanel:OnRemove()
		tshop_exists = false
	end
end)
