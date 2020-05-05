local RoleList
local RoundLabel
local OtherLabel

hook.Add("StatisticsDrawGui", "ttt_Statistics_Addon_TTTGeneral", function(panel)
  RoleList = vgui.Create("DListView", panel)
  RoleList:SetPos(0,0)
  RoleList:SetSize(0.7450811304596 * panel:GetWide(), 0.52999178312104 * panel:GetTall())
  RoleList:AddColumn("Rolename")
  RoleList:AddColumn("Frequency")
  RoleList:AddColumn("Percentage")

  RoundLabel = vgui.Create("DLabel", panel)
  RoundLabel:SetPos(0.78075934913 * panel:GetWide(), 0)
  RoundLabel:SetSize(0.21924065087068 * panel:GetWide() , panel:GetTall())
  RoundLabel:SetFont("StatisticsDefault")
  RoundLabel:SetTextColor(Color(255,255,255))

  OtherLabel = vgui.Create("DLabel", panel)
  OtherLabel:SetPos(0, 0.52999178312104 * panel:GetTall())
  OtherLabel:SetSize(0.7450811304596 * panel:GetWide(), 0.49917830735818 * panel:GetTall())
  OtherLabel:SetFont("StatisticsHudHint")
  OtherLabel:SetTextColor(Color(255,255,255))
end)

local function roundTo2Decimal(t)
    return math.Round(t*100)*0.01
end

function StatisticsDrawTTTGeneral(visible)
  RoleList:SetVisible(visible)
  RoundLabel:SetVisible(visible)
  OtherLabel:SetVisible(visible)
  RoleList:Clear()
  local string = LocalPlayer():GetPData("stat_TotalRoles", "")
  local split = string.Split(string , "\n")
  for k,v in pairs(split) do
    local Frequency = tonumber(LocalPlayer():GetPData("stat_TimesYouWere_" .. v, 0))
    local Percentage = 100 * roundTo2Decimal(Frequency / LocalPlayer():GetPData("stat_RoundsPlayed", 1))
    if v ~= "" then
      RoleList:AddLine(v, Frequency, Percentage)
    end
  end
  local RoundsWon = LocalPlayer():GetPData("stat_RoundsWon", 0)
  local RoundsLost = LocalPlayer():GetPData("stat_RoundsLost", 0)
  local TimeSurvivedAverage = math.Round(tonumber(LocalPlayer():GetPData("stat_TimeSurvivedTotal", 0))) / tonumber(LocalPlayer():GetPData("stat_TimeSurvivedCount", 0))
  local AverageTimeMinutes =  string.format("%02d", math.floor(TimeSurvivedAverage/60)) .. ":" .. string.format("%02d", TimeSurvivedAverage % 60)
  RoundLabel:SetText("Your round-statistics:\n\nRounds played: \n" .. LocalPlayer():GetPData("stat_RoundsPlayed", 0) .. "\n\nRounds won: \n" .. RoundsWon .. "\n\nRounds lost: \n" .. RoundsLost .. "\n\nWin/loose ratio: " .. roundTo2Decimal(RoundsWon / RoundsLost))
  OtherLabel:SetText("Total bodies identified: " .. LocalPlayer():GetPData("stat_TotalPlayersFound", 0) .. "\n\nTimes you were caught shopping: " .. LocalPlayer():GetPData("stat_DeathWhileShopping", 0) .. "\n\nYour average time survived is: " .. AverageTimeMinutes)
end

hook.Add("TTT2PlayerReady", "ttt_Statistics_Addon_TTTGeneral", function()
  local PDEntries = {"stat_TotalRoles", "stat_RoundsWon", "stat_RoundsLost", "stat_RoundsPlayed", "stat_DeathWhileShopping", "stat_TotalPlayersFound", "stat_TimeSurvivedTotal", "stat_TimeSurvivedCount"}
  local string = LocalPlayer():GetPData("stat_TotalRoles", "")
  local split = string.Split(string , "\n")
  for k,v in pairs(split) do
    if v ~= "" then
      table.insert(PDEntries, "stat_TimesYouWere_" .. v)
    end
  end
  AddYourStatisticsAddon("TTT General-stats", StatisticsDrawTTTGeneral, PDEntries, 3)
end)
