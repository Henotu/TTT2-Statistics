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

local Clear_Names = {}
local ID
local ID_list = {}
local ClearNames = {}

surface.CreateFont("stat_Default", {
  font = "Default",
  extended = false,
  size = (ScreenScale(4.4)),
  weight = 400,
  blursize = 0
})
-- This function sets up a table to save the Names from stat_NameDataBase in a list
local function GetID_NamesfromDB()
  ID_list = {}
  local read_name = LocalPlayer():GetPData("stat_NameDataBase", "")
  local split_name = string.Split(read_name, "\n")
  for k, v in pairs(split_name) do -- go thruogh each line of the NameDataBase
    if (k % 2 == 0) and (v ~= "") then -- Only Save every 2nd line (Where the Names are Stored) with its ID (seen in else Statement)
      Clear_Names[tostring(ID)] = tostring(v)
    elseif (k % 2 ~= 0) and (v ~= "") then
      ID = v
      table.insert(ID_list, ID) -- Fill the ID_list
    end
  end
end

-- Return the three weapons with the most kills
-- This way is in my opinion better than working with tables
local function stat_Top3Weapons()
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

--Name says it all
local function roundTo2Decimal(t)
    return math.Round(t*100)*0.01
end

--Returns the amount of Kills and Deaths the player has
local function TotalKills()
  local TotalKills = 0 -- Both Variables are used later
  local TotalDeaths = 0
  for k, v in pairs(ID_list) do --get every ID from the ID_list
    local KilledYou = LocalPlayer():GetPData(v .."_KilledYou", 0) --get the value of kills of current id
    local KilledByYou = LocalPlayer():GetPData(v .. "_KilledByYou", 0)
    if (KilledYou ~= nil) and (KilledByYou ~= nil) then --Test, if ID got any kills
      stat_gui_List1:AddLine(Clear_Names[tostring(v)],tonumber(KilledByYou),tonumber(KilledYou)) -- Print out data
      TotalKills = TotalKills + tonumber(KilledByYou)
      TotalDeaths = TotalDeaths + tonumber(KilledYou)
    end
  end
  return TotalKills, TotalDeaths
end

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

--Easier way to show/hide elements in the gui
local function stat_Show(a,b,c,d,e,f,g,h)
  stat_gui_List1:SetVisible(a or false)
  stat_gui_List4:SetVisible(b or false)
  stat_gui_Label1:SetVisible(c or false)
  stat_gui_Label2:SetVisible(d or false)
  stat_gui_Label3:SetVisible(e or false)
  stat_gui_ButtonS:SetVisible(f or false)
  stat_gui_List3:SetVisible(g or false)
  stat_gui_Label4:SetVisible(h or false)
end

local function DrawMenu()
  stat_Show(nil,nil,nil,true,nil,true)
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
  e:SetFont("stat_Default")
  e:SetText("Set the maximum damage added to your stats per received/dealt damage:")

  local e = vgui.Create( "DButton", frame )
  e:SetPos( 0.2745995423341 * frame:GetWide(), 0.83333333333333 * frame:GetTall() )
  e:SetSize( 0.45766590389016 * frame:GetWide(), 0.094017094017094 * frame:GetTall() )
  e:SetText("Close Window")
  e:SetFont("stat_Default")
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
  e:SetFont("stat_Default")
end

local function ChangePart1()
  if not stat_gui_List1:IsVisible() then
    stat_Show(true,nil,true)
    GetID_NamesfromDB() -- UpdateIDlist
    stat_gui_List1:Clear()
    local TotalKills, TotalDeaths = TotalKills()
    stat_gui_Label1:SetText("Number of kills: \n" .. TotalKills .. "\n\nNumber of deaths by players: \n" .. TotalDeaths .. "\n\nK/D (only Players): " .. roundTo2Decimal(TotalKills / TotalDeaths))
  else
  DrawMenu()
  end
end

local function ChangePart2()
  if not stat_gui_Label3:IsVisible() then
    stat_Show(nil,nil,nil,nil,true,nil)
    local TotalKills, TotalDeaths = TotalKills()
    local totalKD = roundTo2Decimal((TotalKills)/(TotalDeaths + LocalPlayer():GetPData("stat_YouKilledYourself", 0) + LocalPlayer():GetPData("stat_UnknownDeath", 0) + LocalPlayer():GetPData("stat_KilledByWorld", 0)))
    local text = ""
    local one, two, three = stat_Top3Weapons()
    text = text .. "Your favourite weapons: \n\nKills with the " .. one .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..one, 0) .. "\nKills with the " .. two .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..two,0) .. "\nKills with the " .. three .. ": " .. LocalPlayer():GetPData("stat_Weapon_"..three, 0)
    text = text .. "\n\n------------------\n\nYour special Deaths:\n\nTimes you were killed by the world: ".. LocalPlayer():GetPData("stat_KilledByWorld", 0) .. "\nTimes you killed yourself: " .. LocalPlayer():GetPData("stat_YouKilledYourself", 0) .. "\nTimes you were killed by unknown: " .. LocalPlayer():GetPData("stat_UnknownDeath", 0) .. "\n\nYour Total K/D (With Player K/D): " .. totalKD
    text = text .. "\n\n------------------\n\nIn total you dealt [" .. roundTo2Decimal(LocalPlayer():GetPData("stat_TotalDamageDealt", 0)) .. "] damage\nIn total you received [" .. roundTo2Decimal(LocalPlayer():GetPData("stat_TotalDamageReceived", 0)) .. "] damage"
    if GetConVar("stat_Alex"):GetBool() then
      text = text .. "\n\n------------------\n\nAnzahl der Runden, in denen du den Alex gemacht hast: " .. LocalPlayer():GetPData("stat_NoOneHurt", 0)
    else
      text = text .. "\n\n------------------\n\nTotal rounds you did no damage to another player: " .. LocalPlayer():GetPData("stat_NoOneHurt", 0)
    end
    stat_gui_Label3:SetText(text)
  else
    DrawMenu()
  end
end

local function ChangePart3()
  if (not stat_gui_List3:IsVisible()) then
    stat_gui_List3:Clear()
    stat_Show(nil,nil,true,nil,nil,nil,true,true)
    local string = LocalPlayer():GetPData("stat_TotalRoles", "")
    local split = string.Split(string , "\n")
    for k,v in pairs(split) do
      if v ~= "" then
        stat_gui_List3:AddLine(v, LocalPlayer():GetPData("stat_TimesYouWere_" .. v, 0))
      end
    end
    local stat_won = LocalPlayer():GetPData("stat_RoundsWon", 0)
    local stat_lost = LocalPlayer():GetPData("stat_RoundsLost", 0)
    stat_gui_Label1:SetText("Your round-statistics:\n\nRounds played: \n" .. LocalPlayer():GetPData("stat_RoundsPlayed", 0) .. "\n\nRounds won: \n" .. stat_won .. "\n\nRounds lost: \n" .. stat_lost .. "\n\nWin/loose ratio: " .. roundTo2Decimal(stat_won / stat_lost))
    stat_gui_Label4:SetText("Total bodies identified: " .. LocalPlayer():GetPData("stat_TotalPlayersFound", 0) .. "\n\nTimes you were caught shopping: " .. LocalPlayer():GetPData("stat_DeathWhileShopping", 0))
  else
    DrawMenu()
  end
end

local function ChangePart4()
  if not stat_gui_List4:IsVisible() then
    local read_item = LocalPlayer():GetPData("stat_ItemBought", "")
    local split_item = string.Split(read_item, "\n")
    local ID_name
    local TotalItems = 0
    stat_Show(nil,true,true)
    stat_gui_List4:Clear()
    for k, v in pairs(split_item) do -- go through every Line of the string
      if ( k % 2 ~= 0) and (v ~= "") then -- Get the ID of the Item
        ID_name = v
        TotalItems = TotalItems + LocalPlayer():GetPData(ID_name .. "_BoughtByPlayer", 0) -- Counting total items
      end
      if ( k % 2 == 0) and (v ~= "") then -- If the Realname exists, write it
        stat_gui_List4:AddLine(v, LocalPlayer():GetPData(ID_name .. "_BoughtByPlayer", 0))
      elseif ( k % 2 == 0) and (v == "") and (ID_name ~= nil) then -- If the Realname doesnt exists
        stat_gui_List4:AddLine(ID_name, LocalPlayer():GetPData(ID_name .. "_BoughtByPlayer", 0))
        ID_name = nil
      end
    end
    stat_gui_Label1:SetText("Total Items Bought: " .. TotalItems .. "\n\n----------------------\n\nNote:\nYou can edit the \ndisplayed name of the item \nby right-clicking on it")
  else
    DrawMenu()
  end
end

-- If the player sets a custom name for an item
local function Update_Itemfile(Name, NewText)
  local read_item = LocalPlayer():GetPData("stat_ItemBought", "")
  local split_item = string.Split(read_item, "\n")
  local newstring = ""
  local testing = false
  for k, v in pairs(split_item) do
    if k < #split_item then
      if ( k % 2 ~= 0) and (Name == v) then
        testing = true
        newstring = newstring .. v .. "\n"
      elseif ((k % 2 == 0) and (testing)) or ((k % 2 == 0) and (Name == v)) then
        newstring = newstring .. NewText .. "\n"
        testing = false
      else
        newstring = newstring .. v .. "\n"
      end
    end
  end

  LocalPlayer():SetPData("stat_ItemBought", newstring)
  stat_gui_List4:SetVisible(false)
  ChangePart4()
end

--For changing the Displayed T-item name
local function RunWindow(notused, self)
  local LineName = stat_gui_List4:GetLine(self):GetColumnText(1)
  local frame = vgui.Create("DFrame")
  frame:SetPos( 0.371875 * ScrW(), 0.49351851851852 * ScrH() )
  frame:SetSize( 0.20572916666667 * ScrW(), 0.11481481481481 * ScrH() )
  frame:MakePopup()


   stat_gui_TextEntry = vgui.Create( "DTextEntry", frame )
						 stat_gui_TextEntry:SetPos( 0.083544303797468 * frame:GetWide(), 0.26612903225806 * frame:GetTall() )
						 stat_gui_TextEntry:SetSize( 0.82784810126582 * frame:GetWide(), 0.29032258064516 * frame:GetTall() )

  stat_gui_TextButton = vgui.Create( "DButton", frame )
						 stat_gui_TextButton:SetPos( 0.24810126582278 * frame:GetWide(), 0.66935483870968 * frame:GetTall() )
						 stat_gui_TextButton:SetSize( 0.50632911392405 * frame:GetWide(), 0.17741935483871 * frame:GetTall() )
             stat_gui_TextButton:SetText("Save!")
             stat_gui_TextButton.DoClick = function()
               Update_Itemfile(LineName, stat_gui_TextEntry:GetValue() )
               frame:Remove()
             end
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
  --Make custom font that scales with the Display
  local FrameHeight = stat_gui_frame:GetTall()
  surface.CreateFont("stat_HudHint", {
    font = "HudHintTextLarge",
    extended = false,
    size = (FrameHeight * 0.02992592592),
    weight = 10000,
    blursize = 0})

           stat_gui_Button1 = vgui.Create( "DButton", stat_gui_frame )
           stat_gui_Button1:SetPos( 0.014583333333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_Button1:SetSize( 0.20833333333333 * stat_gui_frame:GetWide(), 0.17962962962963 * stat_gui_frame:GetTall() )
           stat_gui_Button1:SetText("Show Player-Kills/Deaths")
           stat_gui_Button1:SetFont("stat_Default")
           stat_gui_Button1.DoClick = ChangePart1

           stat_gui_Button2 = vgui.Create( "DButton", stat_gui_frame )
           stat_gui_Button2:SetPos( 0.014583333333333 * stat_gui_frame:GetWide(), 0.3 * stat_gui_frame:GetTall() )
           stat_gui_Button2:SetSize( 0.20833333333333 * stat_gui_frame:GetWide(), 0.17962962962963 * stat_gui_frame:GetTall() )
           stat_gui_Button2:SetText("Your Game-stats")
           stat_gui_Button2:SetFont("stat_Default")
           stat_gui_Button2.DoClick = ChangePart2

           stat_gui_Button3 = vgui.Create( "DButton", stat_gui_frame )
           stat_gui_Button3:SetPos( 0.014583333333333 * stat_gui_frame:GetWide(), 0.53333333333333 * stat_gui_frame:GetTall() )
           stat_gui_Button3:SetSize( 0.20833333333333 * stat_gui_frame:GetWide(), 0.17962962962963 * stat_gui_frame:GetTall() )
           stat_gui_Button3:SetText("TTT General-stats")
           stat_gui_Button3:SetFont("stat_Default")
           stat_gui_Button3.DoClick = ChangePart3

           stat_gui_Button4 = vgui.Create( "DButton", stat_gui_frame )
           stat_gui_Button4:SetPos( 0.014583333333333 * stat_gui_frame:GetWide(), 0.76851851851852 * stat_gui_frame:GetTall() )
           stat_gui_Button4:SetSize( 0.20833333333333 * stat_gui_frame:GetWide(), 0.17962962962963 * stat_gui_frame:GetTall() )
           stat_gui_Button4:SetText("TTT Item-stats")
           stat_gui_Button4:SetFont("stat_Default")
           stat_gui_Button4.DoClick = ChangePart4

           stat_gui_ButtonS = vgui.Create( "DButton", stat_gui_frame )
           stat_gui_ButtonS:SetPos( 0.4 * stat_gui_frame:GetWide(), 0.76851851851852 * stat_gui_frame:GetTall() )
           stat_gui_ButtonS:SetSize( 0.2 * stat_gui_frame:GetWide(), 0.1 * stat_gui_frame:GetTall() )
           stat_gui_ButtonS:SetText("Settings")
           stat_gui_ButtonS:SetFont("stat_Default")
           stat_gui_ButtonS.DoClick = stat_SettingWindow

           stat_gui_List1 = vgui.Create( "DListView", stat_gui_frame )
           stat_gui_List1:SetVisible(false)
           stat_gui_List1:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_List1:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
           stat_gui_List1:AddColumn("Name")
           stat_gui_List1:AddColumn("Kills")
           stat_gui_List1:AddColumn("Deaths By")

           stat_gui_List3 = vgui.Create("DListView", stat_gui_frame)
           stat_gui_List3:SetVisible(false)
           stat_gui_List3:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_List3:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.47777777777778 * stat_gui_frame:GetTall() )
           stat_gui_List3:AddColumn("Rolename")
           stat_gui_List3:AddColumn("Frequency")

           stat_gui_List4 = vgui.Create( "DListView", stat_gui_frame )
           stat_gui_List4:SetVisible(false)
           stat_gui_List4:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_List4:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
           stat_gui_List4:AddColumn("Name of the item")
           stat_gui_List4:AddColumn("Times bought")
           stat_gui_List4.OnRowRightClick = function(notused, self)
             RunWindow(notused ,self)
           end

           stat_gui_Label1 = vgui.Create( "DLabel", stat_gui_frame )
           stat_gui_Label1:SetPos( 0.825 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_Label1:SetSize( 0.16 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
           stat_gui_Label1:SetColor(Color(255,255,255))
           stat_gui_Label1:SetTextColor(Color(255,255,255))
           stat_gui_Label1:SetFont("stat_Default")
           stat_gui_Label1:SetText("")

           stat_gui_Label2 = vgui.Create("DLabel", stat_gui_frame)
           stat_gui_Label2:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_Label2:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
           stat_gui_Label2:SetFont("stat_HudHint")
           stat_gui_Label2:SetTextColor(Color(255,255,255))
           stat_gui_Label2:SetText("Welcome to the TTT2-Statistics-Addon!\n\nThis Addon is intended for the TTT2 gamemode, but I think it could also be \nused for the normal TTT gamemode and/or other gamemodes. \n(It should still track your kills/deaths)\n\nEverything the Addon tracks is stored on the client-side, the server is only \nused for sending the player the information needed.\n\nIf you want to stop the recording of new data, delete all entries in the \nDatabase or change other settings, click the button below. \n\nHave fun!")

           stat_gui_Label3 = vgui.Create("DLabel",stat_gui_frame )
           stat_gui_Label3:SetPos( 0.25520833333333 * stat_gui_frame:GetWide(), 0.07037037037037 * stat_gui_frame:GetTall() )
           stat_gui_Label3:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.87777777777778 * stat_gui_frame:GetTall() )
           stat_gui_Label3:SetVisible(false)
           stat_gui_Label3:SetTextColor(Color(255,255,255))
           stat_gui_Label3:SetFont("stat_HudHint")

           stat_gui_Label4 = vgui.Create("DLabel", stat_gui_frame)
           stat_gui_Label4:SetVisible(false)
           stat_gui_Label4:SetPos( 0.26520833333333 * stat_gui_frame:GetWide(), 0.55 * stat_gui_frame:GetTall() )
           stat_gui_Label4:SetSize( 0.543754 * stat_gui_frame:GetWide(), 0.45 * stat_gui_frame:GetTall() )
           stat_gui_Label4:SetTextColor(Color(255,255,255))
           stat_gui_Label4:SetFont("stat_HudHint")
end
--Bindings

concommand.Add("stat_DrawGui", stat_DrawGui)

hook.Add("TTT2FinishedLoading", "ttt_Statistics_Addon" ,function()
  bind.Register("ttt_Statistics_Addon", stat_DrawGui , nil, nil, "Show Statistics") --TEMPORARY LINE: NEEDS EDIT
  AddTTT2AddonDev("76561198143340527")
end)
