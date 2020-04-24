local
local


hook.Add("StatisticsDrawGui", function(panel)
  stat_List = vgui.Create( "DListView", panel )
  stat_List:SetVisible(false)
  stat_List:SetPos( 0,0)
  stat_List:SetSize( 0.49018416143 * panel:GetWide(), panel:GetTall() )
  stat_List:AddColumn("Name")
  stat_List:AddColumn("Kills")
  stat_List:AddColumn("Deaths By")

  stat_Label = vgui.Create("DLabel", panel)
  stat_Label:SetPos(0.602078125 * panel:GetWide(), 0)
  stat_label:SetSize(0.11676666666 * panel:GetWide() , panel:GetTall())
  stat_label:SetFont("stat_Default")

end)

function stat_DrawPlayerKD()

end

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_PlayerKD", function()
  stat_AddyourAddon("Show Player-Kills/Deaths", stat_DrawPlayerKD )
end)
