local KDList
local KDLabel
local IDList
local ID
local ClearNames


hook.Add("StatisticsDrawGui", function(panel)
  KDList = vgui.Create( "DListView", panel )
  KDList:SetVisible(false)
  KDList:SetPos( 0,0)
  KDList:SetSize( 0.49018416143 * panel:GetWide(), panel:GetTall() )
  KDList:AddColumn("Name")
  KDList:AddColumn("Kills")
  KDList:AddColumn("Deaths By")

  KDLabel = vgui.Create("DLabel", panel)
  KDLabel:SetPos(0.602078125 * panel:GetWide(), 0)
  KDLabel:SetSize(0.11676666666 * panel:GetWide() , panel:GetTall())
  KDLabel:SetFont("StatisticsDefault")
end)

--Name says it all
local function roundTo2Decimal(t)
    return math.Round(t*100)*0.01
end

--Returns the amount of Kills and Deaths the player has and updates the KDList
local function TotalKills()
  local TotalKills = 0 -- Both Variables are used later
  local TotalDeaths = 0
  for k, v in pairs(IDList) do --get every ID from the ID_list
    local KilledYou = LocalPlayer():GetPData(v .."_KilledYou", 0) --get the value of kills of current id
    local KilledByYou = LocalPlayer():GetPData(v .. "_KilledByYou", 0)
    if (KilledYou ~= nil) and (KilledByYou ~= nil) then --Test, if ID got any kills
      KDList:AddLine(Clear_Names[tostring(v)],tonumber(KilledByYou),tonumber(KilledYou)) -- Print out data
      TotalKills = TotalKills + tonumber(KilledByYou)
      TotalDeaths = TotalDeaths + tonumber(KilledYou)
    end
  end
  return TotalKills, TotalDeaths
end

--Updates the IDList
local function GetIDNamesFromDB()
  IDList = {}
  local ReadName = LocalPlayer():GetPData("stat_NameDataBase", "")
  local SplitName = string.Split(ReadName, "\n")
  for k, v in pairs(SplitName) do -- go thruogh each line of the NameDataBase
    if (k % 2 == 0) and (v ~= "") then -- Only Save every 2nd line (Where the Names are Stored) with its ID (seen in else Statement)
      ClearNames[tostring(ID)] = tostring(v)
    elseif (k % 2 ~= 0) and (v ~= "") then
      ID = v
      table.insert(IDList, ID) -- Fill the IDList
    end
  end
end

function StatisticsDrawPlayerKD(visible)
  KDList:SetVisible(visible)
  KDLabel:SetVisible(visible)
  GetIDNamesFromDB() -- Update IDList
  KDList:Clear()
  local TotalKills, TotalDeaths = TotalKills()
  KDLabel:SetText("Number of kills: \n" .. TotalKills .. "\n\nNumber of deaths by players: \n" .. TotalDeaths .. "\n\nK/D (only Players): " .. roundTo2Decimal(TotalKills / TotalDeaths))
end

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_PlayerKD", function()
  AddYourStatisticsAddon("Show Player-Kills/Deaths", StatisticsDrawPlayerKD )
end)
