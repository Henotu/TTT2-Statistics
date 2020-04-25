--[[
Created by u/Henotu
If you want to use parts of this code or you find a way to improve it, message me
I write LocalPlayer() everytime instead of making a variable because it led to bugs with gmod

Thanks to https://github.com/glua/Royal-Derma-Designer for making it possible to design the GUI
]]
--[[
  Entries in the gmod DB:
  -- Lists of Names
  stat_ItemBought
  stat_TotalRoles
  stat_NameDataBase
  stat_TotalWeapons

  -- Button 1
  PLAYER_KilledByYou
  PLAYER_KilledYou
  -- Button 2 [?General Game Stats?]
  stat_NoOneHurt
  stat_YouKilledYourself
  stat_KilledByWorld
  stat_UnknownDeath
  stat_TotalDamageDealt
  stat_TotalDamageReceived
  stat_Weapon_WEAPON
  -- Button 3 [TTT - General Stats]
  stat_TimesYouWere_ROLENAME
  stat_TotalPlayersFound
  stat_DeathWhileShopping
  stat_RoundsPlayed
  stat_RoundsWon
  stat_RoundsLost
  -- Button 4
  EQUIP_BoughtByPlayer
]]

local totalAddons = {}

surface.CreateFont("StatisticsDefault", {
  font = "Default",
  extended = false,
  size = (ScreenScale(4.4)),
  weight = 400,
  blursize = 0
})

--Make custom font that scales with the Display
surface.CreateFont("StatisticsHudHint", {
  font = "HudHintTextLarge",
  extended = false,
  size = (0.5 * ScrH() * 0.02992592592),
  weight = 10000,
  blursize = 0})

-- Removes all Data from the gmod DB
local function stat_DeleteAllEntries()
  local read_name = LocalPlayer():GetPData("stat_NameDataBase", "")
  local split_name = string.Split(read_name, "\n")
  local read_item = LocalPlayer():GetPData("stat_ItemBought", "")
  local split_item = string.Split(read_item, "\n")
  local totalRoles_string = LocalPlayer():GetPData("stat_TotalRoles", "")
  local totalRoles_table = string.Split(totalRoles_string, "\n")
  local read_weapon = LocalPlayer():GetPData("stat_NameDataBase", "")
  local split_weapon = string.Split("read_weapon", "\n")
  -- Delete Entries for Items
  for k, v in pairs(split_item) do
    if (k % 2 ~= 0) then
      LocalPlayer():RemovePData(v .. "_BoughtByPlayer")
    end
  end
  -- Delete Entries for Names and ID
  for k, v in pairs(split_name) do
    if (k % 2 ~= 0) then
      LocalPlayer():RemovePData(v .. "_KilledYou")
      LocalPlayer():RemovePData(v .. "_KilledByYou")
    end
  end
  --Delete Entries for Roles
  for k, v in pairs(totalRoles_table) do
    LocalPlayer():RemovePData("stat_TimesYouWere_" .. v)
  end
  --Delete Entries for Weapons
  for k , v in pairs(split_weapon) do
    LocalPlayer():RemovePData("stat_Weapon_" .. v)
  end

  LocalPlayer():RemovePData("stat_NoOneHurt")
  LocalPlayer():RemovePData("stat_YouKilledYourself")
  LocalPlayer():RemovePData("stat_KilledByWorld")
  LocalPlayer():RemovePData("stat_UnknownDeath")
  LocalPlayer():RemovePData("stat_TotalDamageDealt")
  LocalPlayer():RemovePData("stat_TotalDamageReceived")

  LocalPlayer():RemovePData("stat_TotalPlayersFound")
  LocalPlayer():RemovePData("stat_DeathWhileShopping")
  LocalPlayer():RemovePData("stat_RoundsPlayed")
  LocalPlayer():RemovePData("stat_RoundsWon")
  LocalPlayer():RemovePData("stat_RoundsLost")

  LocalPlayer():RemovePData("stat_TotalWeapons")
  LocalPlayer():RemovePData("stat_TotalRoles")
  LocalPlayer():RemovePData("stat_NameDataBase")
  LocalPlayer():RemovePData("stat_ItemBought")
end

--Draws the Setting-Window
local function stat_SettingWindow()
  local frame = vgui.Create("DFrame")
  frame:SetPos( 0.32760416666667 * ScrW(), 0.35185185185185 * ScrH() )
  frame:SetSize( 0.22760416666667 * ScrW(), 0.21666666666667 * ScrH() )
  frame:SetTitle("Settings - Version 1.0.1")
  frame:MakePopup()


  local e = vgui.Create( "DNumSlider", frame )
  e:SetPos( -0.66875 * frame:GetWide(), 0.42307692307692 * frame:GetTall() )
  e:SetSize( 1.6541666666667 * frame:GetWide(), 0.085470085470085 * frame:GetTall() )
  e:SetMinMax(100, 1000)
  e:SetDecimals(0)
  e:SetDark(false)
  e:SetDefaultValue(200)
  e:SetConVar("stat_MaxDamage")

  local e = vgui.Create( "DCheckBoxLabel", frame )
  e:SetPos( 0.034324942791762 * frame:GetWide(), 0.18376068376068 * frame:GetTall() )
  e:SetSize( 0.93363844393593 * frame:GetWide(), 0.068376068376068 * frame:GetTall() )
  e:SetText("Record your stats")
  e:SetValue(GetConVar("stat_Record"):GetBool())
  e:SetConVar("stat_Record")

  local e = vgui.Create( "DLabel", frame )
  e:SetPos( 0.034324942791762 * frame:GetWide(), 0.33333333333333 * frame:GetTall() )
  e:SetSize( 0.93363844393593 * frame:GetWide(), 0.085470085470085 * frame:GetTall() )
  e:SetFont("StatisticsDefault")
  e:SetText("Set the maximum damage added to your stats per received/dealt damage:")

  local e = vgui.Create( "DButton", frame )
  e:SetPos( 0.2745995423341 * frame:GetWide(), 0.83333333333333 * frame:GetTall() )
  e:SetSize( 0.45766590389016 * frame:GetWide(), 0.094017094017094 * frame:GetTall() )
  e:SetText("Close Window")
  e:SetFont("StatisticsDefault")
  e.DoClick = function() frame:Remove() end

  local e = vgui.Create( "DTextEntry", frame )
  e:SetPos( 0.7025171624714 * frame:GetWide(), 0.63675213675214 * frame:GetTall() )
  e:SetSize( 0.26544622425629 * frame:GetWide(), 0.12820512820513 * frame:GetTall() )
  e.OnEnter = function()
    if e:GetValue() == "DELETE" then
      stat_DeleteAllEntries()
    elseif e:GetValue() == "Alex.exe" then
      GetConVar("stat_Alex"):SetBool(not GetConVar("stat_Alex"):GetBool())
    end
  end

  local e = vgui.Create( "DLabel", frame )
  e:SetPos( 0.034324942791762 * frame:GetWide(), 0.63675213675214 * frame:GetTall() )
  e:SetSize( 0.66819221967963 * frame:GetWide(), 0.12820512820513 * frame:GetTall() )
  e:SetText("Type in \"DELETE\" and hit Enter to delete all entries:")
  e:SetFont("StatisticsDefault")
end

function AddYourStatisticsAddon(ButtonName, FunctionName)
  totalAddons[ButtonName] = FunctionName
end
--
--From here on its just drawing the GUI
--

function stat_DrawGui()
  stat_gui_frame = vgui.Create("DFrame")
  stat_gui_frame:SetPos( 0.25 * ScrW(), 0.25 * ScrH() )
  stat_gui_frame:SetSize( 0.5 * ScrW(), 0.5 * ScrH() )
  stat_gui_frame:SetTitle("TTT-Statistics-Addon")
  stat_gui_frame:MakePopup()
  stat_gui_frame.Paint = function()
    draw.RoundedBox( 7, 0, 0, stat_gui_frame:GetWide(), stat_gui_frame:GetTall(), Color( 117, 115, 116, 248) )
  end
  stat_gui_Panel = vgui.Create("DPanel", stat_gui_frame)
  stat_gui_Panel:SetPos(0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall())
  stat_gui_Panel:SetSize(0.72979166666667 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall())
  stat_gui_Panel.Paint = function(w,h)
    surface.SetDrawColor(0,0,0,0)
    surface.DrawRect(0 , 0 , stat_gui_Panel:GetWide() , stat_gui_Panel:GetTall() )
  end
  hook.Run("StatisticsDrawGui", stat_gui_Panel)

  --Get the amount of Addons to display
  --local totalAddons = LocalPlayer():GetPData("stat_totalAddons","")
  totalAddons["Show Player-Kills/Deaths"] = ChangePart1
  totalAddons["TTT General-stats"] = ChangePart2
  totalAddons["Your Game-stats"] = ChangePart3
  totalAddons["TTT Item-stats"] = ChangePart4
  local totalAddonsString = ""
  for k, v in pairs(table.GetKeys(totalAddons)) do
    totalAddonsString = totalAddonsString .. v .. "\n"
  end

  local totalAddonsSplit = string.Split(totalAddonsString, "\n")

  --make a panel for unlimited Buttons
  stat_gui_ScrollPanel = vgui.Create("DScrollPanel", stat_gui_frame)
  stat_gui_ScrollPanel:SetPos(0.014583333333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall())
  stat_gui_ScrollPanel:SetSize( 0.20833333333333 * stat_gui_frame:GetWide(), 0.9014814814 * stat_gui_frame:GetTall())
  --Paint the ScrollBar of the Panel
  local ScrollBar = stat_gui_ScrollPanel:GetVBar()
  function ScrollBar:Paint(w, h)
	   draw.RoundedBox(0, 0, 0, 0, 0, Color(0, 0, 0))
  end
  function ScrollBar.btnUp:Paint(w, h)
	   draw.RoundedBox(0, 0, 0, 4, h, Color(169, 167, 168))
  end
  function ScrollBar.btnDown:Paint(w, h)
	   draw.RoundedBox(0, 0, 0, 4, h, Color(169, 167, 168))
  end
  function ScrollBar.btnGrip:Paint(w, h)
	   draw.RoundedBox(0, 0, 0, 4, h, Color(169, 167, 168))
  end
  --Create Buttons
  for k , v in pairs(totalAddonsSplit) do
    if v ~= "" then
      local stat_Button = vgui.Create("DButton", stat_gui_ScrollPanel)
      stat_Button:SetText(v)
      stat_Button:SetSize(stat_gui_ScrollPanel:GetWide(), (stat_gui_ScrollPanel:GetTall() - 30) / (4))
      function stat_Button:Paint(w ,h )
        draw.RoundedBox(5, 0, 0, w, h, Color(253, 251, 252))
      end
      stat_Button:SetFont("StatisticsDefault")
      stat_Button:Dock(TOP)
      stat_Button:DockMargin(0,0,0,10)
      stat_Button.DoClick = function()
        for _, p in pairs(totalAddonsSplit) do
          if p == v then
            print(v .. "  v")
            totalAddons[v](true)
          else
            if p ~= "" then
              print(p .. "  p")
              totalAddons[p](false)
            end
          end
        end
      end
      stat_gui_ScrollPanel:AddItem(stat_Button)
    end
  end

  stat_gui_ButtonS = vgui.Create( "DButton", stat_gui_frame )
            stat_gui_ButtonS:SetPos( 0.4 * stat_gui_frame:GetWide(), 0.76851851851852 * stat_gui_frame:GetTall() )
            stat_gui_ButtonS:SetSize( 0.2 * stat_gui_frame:GetWide(), 0.1 * stat_gui_frame:GetTall() )
            stat_gui_ButtonS:SetText("Settings")
            stat_gui_ButtonS:SetFont("StatisticsDefault")
            stat_gui_ButtonS.DoClick = stat_SettingWindow

            stat_gui_Label2 = vgui.Create("DLabel", stat_gui_frame)
            stat_gui_Label2:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
            stat_gui_Label2:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
            stat_gui_Label2:SetFont("StatisticsHudHint")
            stat_gui_Label2:SetTextColor(Color(255,255,255))
            stat_gui_Label2:SetText("Welcome to the TTT2-Statistics-Addon!\n\nThis Addon is intended for the TTT2 gamemode, but I think it could also be \nused for the normal TTT gamemode and/or other gamemodes. \n(It should still track your kills/deaths)\n\nEverything the Addon tracks is stored on the client-side, the server is only \nused for sending the player the information needed.\n\nIf you want to stop the recording of new data, delete all entries in the \nDatabase or change other settings, click the button below. \n\nHave fun!")
end
--Bindings

concommand.Add("stat_DrawGui", stat_DrawGui)

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon" ,function()
  bind.Register("ttt_Statistics_Addon", stat_DrawGui , nil, nil, "Show Statistics") --TEMPORARY LINE: NEEDS EDIT
  AddTTT2AddonDev("76561198143340527")
end)
