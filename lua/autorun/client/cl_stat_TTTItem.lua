local ItemList
local ItemLabel

-- If the player sets a custom name for an item
local function UpdateItemfile(Name, NewText)
  local ReadItem = LocalPlayer():GetPData("stat_ItemBought", "")
  local SplitItem = string.Split(ReadItem, "\n")
  local NewString = ""
  local testing = false
  for k, v in pairs(SplitItem) do
    if k < #SplitItem then
      if ( k % 2 ~= 0) and (Name == v) then
        testing = true
        NewString = NewString .. v .. "\n"
      elseif ((k % 2 == 0) and (testing)) or ((k % 2 == 0) and (Name == v)) then
        NewString = NewString .. NewText .. "\n"
        testing = false
      else
        NewString = NewString .. v .. "\n"
      end
    end
  end
  LocalPlayer():SetPData("stat_ItemBought", NewString)
  StatisticsDrawTTTItem(true)
end

--For changing the Displayed T-item name
local function RunWindow(notused, self)
  local LineName = ItemList:GetLine(self):GetColumnText(1)
  local frame = vgui.Create("DFrame")
  frame:SetPos( 0.371875 * ScrW(), 0.49351851851852 * ScrH() )
  frame:SetSize( 0.20572916666667 * ScrW(), 0.11481481481481 * ScrH() )
  frame:MakePopup()


   local TextEntry = vgui.Create( "DTextEntry", frame )
						 TextEntry:SetPos( 0.083544303797468 * frame:GetWide(), 0.26612903225806 * frame:GetTall() )
						 TextEntry:SetSize( 0.82784810126582 * frame:GetWide(), 0.29032258064516 * frame:GetTall() )

  local TextButton = vgui.Create( "DButton", frame )
						 TextButton:SetPos( 0.24810126582278 * frame:GetWide(), 0.66935483870968 * frame:GetTall() )
						 TextButton:SetSize( 0.50632911392405 * frame:GetWide(), 0.17741935483871 * frame:GetTall() )
             TextButton:SetText("Save!")
             TextButton.DoClick = function()
               UpdateItemfile(LineName, TextEntry:GetValue() )
               frame:Remove()
             end
 end


hook.Add("StatisticsDrawGui", "ttt_Statistics_Addon_TTTItem", function(panel)
  ItemList = vgui.Create("DListView", panel)
  ItemList:SetPos( 0,0)
  ItemList:SetSize( 0.49018416143 * panel:GetWide(), panel:GetTall() )
  ItemList:AddColumn("Name of the item")
  ItemList:AddColumn("Times bought")
  ItemList.OnRowRightClick = function(notused, self)
    RunWindow(notused ,self)
  end
end)

function StatisticsDrawTTTItem(visible)
  ItemList:SetVisible(visible)
  ItemLabel:SetVisible(visible)
  local ReadItem = LocalPlayer():GetPData("stat_ItemBought", "")
  local SplitItem = string.Split(ReadItem, "\n")
  local IDName
  local TotalItems = 0
  ItemList:Clear()
  for k, v in pairs(SplitItem) do -- go through every Line of the string
    if ( k % 2 ~= 0) and (v ~= "") then -- Get the ID of the Item
      IDName = v
      TotalItems = TotalItems + LocalPlayer():GetPData(IDName .. "_BoughtByPlayer", 0) -- Counting total items
    end
    if ( k % 2 == 0) and (v ~= "") then -- If the Realname exists, write it
      ItemList:AddLine(v, LocalPlayer():GetPData(IDName .. "_BoughtByPlayer", 0))
    elseif ( k % 2 == 0) and (v == "") and (IDName ~= nil) then -- If the Realname doesnt exists
      ItemList:AddLine(IDName, LocalPlayer():GetPData(IDName .. "_BoughtByPlayer", 0))
      IDName = nil
    end
  end
  ItemLabel:SetText("Total Items Bought: " .. TotalItems .. "\n\n----------------------\n\nNote:\nYou can edit the \ndisplayed name of the item \nby right-clicking on it")
end

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_TTTItem", function()
  AddYourStatisticsAddon("TTT Item-stats", StatisticsDrawTTTItem)
end)
