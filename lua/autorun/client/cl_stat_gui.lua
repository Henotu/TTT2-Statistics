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

local TotalAddons = {}
local ButtonOrder = {}
local TotalAddonsOrdered = {}
local PDEntries = {}

surface.CreateFont("StatisticsDefault", {
  font = "Default",
  extended = false,
  size = (ScreenScale(4.4)),
  weight = 400,
  blursize = 0})

--Make custom font that scales with the Display
surface.CreateFont("StatisticsHudHint", {
  font = "HudHintTextLarge",
  extended = false,
  size = (0.5 * ScrH() * 0.02992592592),
  weight = 10000,
  blursize = 0})

--Adds all addons to addon-table
function AddYourStatisticsAddon(ButtonName, FunctionName, Table, Number)
  TotalAddons[ButtonName] = FunctionName
  if Number ~= nil then
    ButtonOrder[Number] = ButtonName
  end
  if Table ~= nil then
    table.Add(PDEntries, Table)
  end
end

local function OrderButtons()
  TotalAddonsOrdered = {}
  local Number
  local TempList = table.GetKeys(TotalAddons)
  for k,v in pairs(ButtonOrder) do
    TotalAddonsOrdered[k] = ButtonOrder[k]
    Number = k
  end
  for n, p in pairs(TempList) do
    local o = 1
    Number = Number + 1
    local testing = false
    while o <= #TotalAddonsOrdered do
      if TotalAddonsOrdered[o] == p then
        testing = true
        break
      end
      o = o + 1
    end
    if testing == false then
      TotalAddonsOrdered[Number] = p
    end
  end
end

-- Saves all Data from the gmod DB inside a .json file
local function SaveAllEntries()
  local values = {}

  for k,v in pairs(PDEntries) do
    values[v] = LocalPlayer():GetPData(v, 0)
  end

  local data = util.TableToJSON(values, true)

  if (!file.IsDir("ttt_Statistics_Addon", "DATA")) then
    file.CreateDir("ttt_Statistics_Addon")
  end

  local filename = "Stat_Export_" .. string.Replace( util.DateStamp(), " ", "_") .. ".json"
  file.Write("ttt_Statistics_Addon/" .. filename, data)
end

-- Removes all Data from the gmod DB
local function DeleteAllEntries()
  for k,v in pairs(PDEntries) do
    LocalPlayer():RemovePData(v)
  end
end

local function DrawDeveloperWindow(Entry)
  local frame = vgui.Create("DFrame")
  frame:SetPos( 0.21302083333333 * ScrW(), 0.23981481481481 * ScrH() )
  frame:SetSize( 0.6 * ScrW(), 0.36574074074074 * ScrH() )
  frame:MakePopup()

   local TextEntryList = vgui.Create( "DTextEntry", frame )
    TextEntryList:SetPos( 0.01641266119578 * frame:GetWide(), 0.85822784810127 * frame:GetTall() )
  	TextEntryList:SetSize( 0.27549824150059 * frame:GetWide(), 0.091139240506329 * frame:GetTall() )
    TextEntryList.OnEnter = function()
      DrawDeveloperWindow(TextEntryList:GetValue())
      frame:Remove()
    end

   local ListView = vgui.Create( "DListView", frame )
  	ListView:SetPos( 0.01641266119578 * frame:GetWide(), 0.09873417721519 * frame:GetTall() )
  	ListView:SetSize( 0.27549824150059 * frame:GetWide(), 0.73164556962025 * frame:GetTall() )
    ListView:AddColumn("Entry")
    ListView.OnRowSelected = function(notused, self)
      DrawDeveloperWindow(ListView:GetLine(self):GetColumnText(1))
      frame:Remove()
    end

    local MainLabel = vgui.Create("DLabel", frame)
  	MainLabel:SetPos( 0.31770222743259 * frame:GetWide(), 0.09873417721519 * frame:GetTall() )
  	MainLabel:SetSize( 0.63892145369285 * frame:GetWide(), 0.35696202531646 * frame:GetTall() )
    MainLabel:SetFont("StatisticsHudHint")
    MainLabel:SetTextColor(Color(255, 255, 255))
    MainLabel:SetText("Select an Entry to continue")

   local TextEntryInt = vgui.Create( "DTextEntry", frame )
  	TextEntryInt:SetPos( 0.81125439624853 * frame:GetWide(), 0.49367088607595 * frame:GetTall() )
  	TextEntryInt:SetSize( 0.14536928487691 * frame:GetWide(), 0.093670886075949 * frame:GetTall() )
    TextEntryInt.OnEnter = function()
      if (Entry ~= nil) and (Entry ~= "") then
        LocalPlayer():SetPData(Entry, TextEntryInt:GetValue())
        DrawDeveloperWindow(Entry)
        frame:Remove()
      end
    end

   local SideLabel = vgui.Create( "DLabel", frame )
  	SideLabel:SetPos( 0.31770222743259 * frame:GetWide(), 0.49367088607595 * frame:GetTall() )
  	SideLabel:SetSize( 0.44548651817116 * frame:GetWide(), 0.093670886075949 * frame:GetTall() )
    SideLabel:SetFont("StatisticsHudHint")
    SideLabel:SetTextColor(Color(255,255,255))
    SideLabel:SetText("")

    for k,v in pairs(PDEntries) do
      ListView:AddLine(v)
    end
    if Entry ~= nil then
      TextEntryList:SetText(Entry)
      MainLabel:SetText("\"" .. Entry .. "\" " .."has a total value of " .. LocalPlayer():GetPData(Entry, 0))
      SideLabel:SetText("Set the new value of \"".. Entry .."\": ")
    end
end

--Draws the Setting-Window
local function DrawSettingsWindow()
  local frame = vgui.Create("DFrame")
  frame:SetPos( 0.32760416666667 * ScrW(), 0.35185185185185 * ScrH() )
  frame:SetSize( 0.22760416666667 * ScrW(), 0.21666666666667 * ScrH() )
  frame:SetTitle("Settings - Version 1.1.1")
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
      DeleteAllEntries()
    elseif e:GetValue() == "Alex.exe" then
      GetConVar("stat_Alex"):SetBool(not GetConVar("stat_Alex"):GetBool())
    elseif e:GetValue() == "DEVELOPER" then
      DrawDeveloperWindow()
    end
  end

  local e = vgui.Create( "DLabel", frame )
  e:SetPos( 0.034324942791762 * frame:GetWide(), 0.63675213675214 * frame:GetTall() )
  e:SetSize( 0.66819221967963 * frame:GetWide(), 0.12820512820513 * frame:GetTall() )
  e:SetText("Type in \"DELETE\" and hit Enter to delete all entries:")
  e:SetFont("StatisticsDefault")
end

local function DrawMenu(Button, Label, visible)
  Button:SetVisible(visible)
  Label:SetVisible(visible)
  local TotalFunction
  if (visible) then
    for k , v in pairs(table.GetKeys(TotalAddons)) do
      TotalAddons[v](false)
    end
  end
end

--
--From here on its just drawing the GUI
--

function DrawStatisticsGUI()
  OrderButtons()
  local MainFrame = vgui.Create("DFrame")
  MainFrame:SetPos( 0.25 * ScrW(), 0.25 * ScrH() )
  MainFrame:SetSize( 0.5 * ScrW(), 0.5 * ScrH() )
  MainFrame:SetTitle("TTT-Statistics-Addon")
  MainFrame:MakePopup()
  MainFrame.Paint = function()
    draw.RoundedBox( 7, 0, 0, MainFrame:GetWide(), MainFrame:GetTall(), Color( 117, 115, 116, 248) )
  end
  local AddonPanel = vgui.Create("DPanel", MainFrame)
  AddonPanel:SetPos(0.25520833333333 * MainFrame:GetWide(), 0.07037037037037 * MainFrame:GetTall())
  AddonPanel:SetSize(0.72979166666667 * MainFrame:GetWide(), 0.9014814814 * MainFrame:GetTall())
  AddonPanel.Paint = function(w,h)
    surface.SetDrawColor(0,0,0,0)
    surface.DrawRect(0 , 0 , AddonPanel:GetWide() , AddonPanel:GetTall() )
  end
  hook.Run("StatisticsDrawGui", AddonPanel)

  --make a panel for unlimited Buttons
  local ScrollPanel = vgui.Create("DScrollPanel", MainFrame)
  ScrollPanel:SetPos(0.014583333333333 * MainFrame:GetWide(), 0.07037037037037 * MainFrame:GetTall())
  ScrollPanel:SetSize( 0.20833333333333 * MainFrame:GetWide(), 0.9014814814 * MainFrame:GetTall())
  --Paint the ScrollBar of the Panel
  local ScrollBar = ScrollPanel:GetVBar()
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

  --"Main Menu"
  local SettingsButton = vgui.Create( "DButton", MainFrame )
  SettingsButton:SetPos( 0.4 * MainFrame:GetWide(), 0.76851851851852 * MainFrame:GetTall() )
  SettingsButton:SetSize( 0.2 * MainFrame:GetWide(), 0.1 * MainFrame:GetTall() )
  SettingsButton:SetText("Settings")
  SettingsButton:SetFont("StatisticsDefault")
  SettingsButton.DoClick = DrawSettingsWindow
  function SettingsButton:Paint(w ,h )
    draw.RoundedBox(5, 0, 0, w, h, Color(253, 251, 252))
  end

  local MainLabel = vgui.Create("DLabel", MainFrame)
  MainLabel:SetPos( 0.25520833333333 * MainFrame:GetWide(), 0.07037037037037 * MainFrame:GetTall() )
  MainLabel:SetSize( 0.543754 * MainFrame:GetWide(), 0.87777777777778 * MainFrame:GetTall() )
  MainLabel:SetFont("StatisticsHudHint")
  MainLabel:SetTextColor(Color(255,255,255))
  MainLabel:SetText("Welcome to the TTT2-Statistics-Addon!\n\nThis Addon is intended for the TTT2 gamemode, but I think it could also be \nused for the normal TTT gamemode and/or other gamemodes. \n(It should still track your kills/deaths)\n\nEverything the Addon tracks is stored on the client-side, the server is only \nused for sending the player the information needed.\n\nIf you want to stop the recording of new data, delete all entries in the \nDatabase or change other settings, click the button below. \n\nHave fun!")
  --Create Buttons
  for k , v in pairs(TotalAddonsOrdered) do --
    StatisticsButtonPressed = ""
    if v ~= "" then
      local SideButtons = vgui.Create("DButton", ScrollPanel)
      SideButtons:SetText(TotalAddonsOrdered[k])
      SideButtons:SetSize(ScrollPanel:GetWide(), (ScrollPanel:GetTall() - 30) / (4))
      function SideButtons:Paint(w ,h )
        draw.RoundedBox(5, 0, 0, w, h, Color(253, 251, 252))
      end
      SideButtons:SetFont("StatisticsDefault")
      SideButtons:Dock(TOP)
      SideButtons:DockMargin(0,0,0,10)
      SideButtons.DoClick = function()
        for _, p in pairs(table.GetKeys(TotalAddons)) do
          local ButtonName = TotalAddonsOrdered[k]
          if (p == ButtonName) and (v ~= StatisticsButtonPressed) then
            TotalAddons[ButtonName](true)
            DrawMenu(SettingsButton, MainLabel, false)
            StatisticsButtonPressed = ButtonName
          elseif (p == ButtonName) and (v == ButtonName) then
            DrawMenu(SettingsButton, MainLabel, true)
            StatisticsButtonPressed = ""
          else
            if p ~= "" then
              TotalAddons[p](false)
            end
          end
        end
      end
      ScrollPanel:AddItem(SideButtons)
      DrawMenu(SettingsButton, MainLabel, true)
    end
  end
end
--Bindings

concommand.Add("stat_DrawGui", DrawStatisticsGUI)

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon_gui" ,function()
  bind.Register("ttt_Statistics_Addon", stat_DrawGui , nil, nil, "Show Statistics") --TEMPORARY LINE: NEEDS EDIT
end)
hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon" ,function()
  bind.Register("ttt_Statistics_Addon", DrawStatisticsGUI , nil, nil, "Show Statistics")
  AddTTT2AddonDev("76561198143340527")
end)
