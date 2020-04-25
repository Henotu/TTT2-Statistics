local RoleList
local RoundLabel
local OtherLabel

hook.Add("StatisticsDrawGui", "ttt_Statistics_Addon_TTTGeneral", function(panel)
  RoleList = vgui.Create("DListView", panel)
  RoleList:SetPos(0,0)
  RoleList:SetSize(0.39682713791 * panel:GetWide(), 0.41938271604 * panel:GetTall())
  RoleList:AddColumn("Rolename")
  RoleList:AddColumn("Frequency")

  RoundLabel = vgui.Create("DLabel", panel)
  RoundLabel:SetPos(0.602078125 * panel:GetWide(), 0)
  RoundLabel:SetSize(0.11676666666 * panel:GetWide() , panel:GetTall())
  RoundLabel:SetFont("StatisticsDefault")

  OtherLabel = vgui.Create("DLabel", panel)
  OtherLabel:SetPos(0, 0.48277777777 * panel:GetTall())
  OtherLabel:SetSize(0.39682713791 * panel:GetWide(), 0.395 * panel:GetTall())
  OtherLabel:SetFont("StatisticsDefault")
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
    if v ~= "" then
      RoleList:AddLine(v, LocalPlayer():GetPData("stat_TimesYouWere_" .. v, 0))
    end
  end
  local RoundsWon = LocalPlayer():GetPData("stat_RoundsWon", 0)
  local RoundsLost = LocalPlayer():GetPData("stat_RoundsLost", 0)
  RoundLabel:SetText("Your round-statistics:\n\nRounds played: \n" .. LocalPlayer():GetPData("stat_RoundsPlayed", 0) .. "\n\nRounds won: \n" .. RoundsWon .. "\n\nRounds lost: \n" .. RoundsLost .. "\n\nWin/loose ratio: " .. roundTo2Decimal(RoundsWon / RoundsLost))
  OtherLabel:SetText("Total bodies identified: " .. LocalPlayer():GetPData("stat_TotalPlayersFound", 0) .. "\n\nTimes you were caught shopping: " .. LocalPlayer():GetPData("stat_DeathWhileShopping", 0))
end

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_TTTGeneral", function()
  AddYourStatisticsAddon("TTT General-stats", StatisticsDrawTTTGeneral)
end)
