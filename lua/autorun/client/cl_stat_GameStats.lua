local Label


hook.Add("StatisticsDrawGui", "ttt_Statistics_Addon_GameStats", function(panel)
  Label = vgui.Create("DLabel", panel)
  Label:SetPos(0,0)
  Label:SetSize(panel:GetWide(), panel:GetTall())
  Label:SetFont("StatisticsHudHint")
  Label:SetTextColor(Color(255,255,255))
end)

--Name says it all
local function roundTo2Decimal(t)
    return math.Round(t*100)*0.01
end

local function TotalKills()
  local IDList = {}
  local ID
  local ClearNames = {}
  local ReadName = LocalPlayer():GetPData("stat_NameDataBase", "")
  local SplitName = string.Split(ReadName, "\n")
  local TotalKills = 0 -- Both Variables are used later
  local TotalDeaths = 0
  for k, v in pairs(SplitName) do -- go thruogh each line of the NameDataBase
    if (k % 2 == 0) and (v ~= "") then -- Only Save every 2nd line (Where the Names are Stored) with its ID (seen in else Statement)
      ClearNames[tostring(ID)] = tostring(v)
    elseif (k % 2 ~= 0) and (v ~= "") then
      ID = v
      table.insert(IDList, ID) -- Fill the IDList
    end
  end
  for k, v in pairs(IDList) do --get every ID from the IDlist
    local KilledYou = LocalPlayer():GetPData(v .."_KilledYou", 0) --get the value of kills of current id
    local KilledByYou = LocalPlayer():GetPData(v .. "_KilledByYou", 0)
    if (KilledYou ~= nil) and (KilledByYou ~= nil) then --Test, if ID got any kills
      TotalKills = TotalKills + tonumber(KilledByYou)
      TotalDeaths = TotalDeaths + tonumber(KilledYou)
    end
  end
  return TotalKills, TotalDeaths
end

-- Return the three weapons with the most kills
-- This way is in my opinion better than working with tables
local function Top3Weapons()
  local read = LocalPlayer():GetPData("stat_TotalWeapons", "")
  local split = string.Split(read, "\n")
  local one = ""
  local two = ""
  local three = ""
  for k , v in pairs(split) do
    if v ~= "" then
      local test = tonumber(LocalPlayer():GetPData("stat_Weapon_" .. v, 0))
      if tonumber(LocalPlayer():GetPData("stat_Weapon_" .. three, 0)) <= test then
        if tonumber(LocalPlayer():GetPData("stat_Weapon_" .. two, 0)) <= test then
          if tonumber(LocalPlayer():GetPData("stat_Weapon_" .. one , 0)) <= test then
            three = two
            two = one
            one = v
          else
            three = two
            two = v
          end
        else
          three = v
        end
      end
    end
  end
  return one, two, three
end


function StatisticsDrawGameStats(visible)
  Label:SetVisible(visible)
  local TotalKills, TotalDeaths = TotalKills()
  local TotalKD = roundTo2Decimal((TotalKills)/(TotalDeaths + LocalPlayer():GetPData("stat_YouKilledYourself", 0) + LocalPlayer():GetPData("stat_UnknownDeath", 0) + LocalPlayer():GetPData("stat_KilledByWorld", 0)))
  local Text = ""
  local one, two, three = Top3Weapons()
  Text = Text .. "Your favourite weapons: \n\nKills with the " .. one .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..one, 0) .. "\nKills with the " .. two .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..two,0) .. "\nKills with the " .. three .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..three, 0)
  Text = Text .. "\n\n------------------\n\nYour special Deaths:\n\nTimes you were killed by the world: ".. LocalPlayer():GetPData("stat_KilledByWorld", 0) .. "\nTimes you killed yourself: " .. LocalPlayer():GetPData("stat_YouKilledYourself", 0) .. "\nTimes you were killed by unknown: " .. LocalPlayer():GetPData("stat_UnknownDeath", 0) .. "\n\nYour Total K/D (With Player K/D): " .. TotalKD
  Text = Text .. "\n\n------------------\n\nIn total you dealt [" .. roundTo2Decimal(LocalPlayer():GetPData("stat_TotalDamageDealt", 0)) .. "] damage\nIn total you received [" .. roundTo2Decimal(LocalPlayer():GetPData("stat_TotalDamageReceived", 0)) .. "] damage"
  if GetConVar("stat_Alex"):GetBool() then
    Text = Text .. "\n\n------------------\n\nAnzahl der Runden, in denen du den Alex gemacht hast: " .. LocalPlayer():GetPData("stat_NoOneHurt", 0) .. "\nAnzahl deiner RDM-Beschwerden: " .. LocalPlayer():GetPData("stat_Rdm", 0)
  else
    Text = Text .. "\n\n------------------\n\nTotal rounds you did no damage to another player: " .. LocalPlayer():GetPData("stat_NoOneHurt", 0)
  end
  Label:SetText(Text)
end

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_GameStats", function()
  AddYourStatisticsAddon("Your Game-stats", StatisticsDrawGameStats, 2)
end)
