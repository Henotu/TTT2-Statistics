--Create Convar
if not ConVarExists("stat_ShowMilestones") then
  CreateConVar("stat_ShowMilestones", 1)
end

local stat_EndRoundText = ""
util.AddNetworkString("ttt_Statistics_Addon_Milestone")

net.Receive("ttt_Statistics_Addon_Milestone", function()
  local text = net.ReadString()
  stat_EndRoundText = stat_EndRoundText .. text .. "\n"
end)

util.AddNetworkString("stat_Attaker")
util.AddNetworkString("stat_Victim")
util.AddNetworkString("stat_Player")
util.AddNetworkString("stat_Hurt")
util.AddNetworkString("stat_Damage")
util.AddNetworkString("stat_GotHurt")
util.AddNetworkString("stat_DamageRecieved")

local function SendMessageStr(Name, str)
  util.AddNetworkString(Name)
  net.Start(Name)
  net.WriteString(str)
  net.Broadcast()
end

hook.Add("PlayerDeath", "ttt_Statistics_Addon", function(victim, inflictor, attaker)
  if attaker and victim ~= nil then
    net.Start("stat_Attaker")
    net.WriteEntity(attaker)
    net.Broadcast()

    net.Start("stat_Victim")
    net.WriteEntity(victim)
    net.Broadcast()
  end
end)

hook.Add("TTTBodyFound", "ttt_Statistics_Addon", function(player, x, xx)
  net.Start("stat_Player")
  net.Send(player)
end)

hook.Add("PlayerHurt", "ttt_Statistics_Addon", function(player, entity, remain, dealt)
  if entity:IsPlayer() then
    net.Start("stat_Hurt")
    net.Send(entity)
    net.Start("stat_Damage")
    net.WriteFloat(dealt)
    net.Send(entity)
  end
  if player:IsPlayer() then
    net.Start("stat_GotHurt")
    net.Send(player)
    net.Start("stat_DamageRecieved")
    net.WriteFloat(dealt)
    net.Send(player)
  end
end)

hook.Add("TTTEndRound", "ttt_Statistics_Addon2", function(result)
  SendMessageStr("stat_result", result)
  if (stat_EndRoundText ~= "") and (GetConVar("stat_ShowMilestones"):GetBool()) then
    PrintMessage(3, string.sub(
      stat_EndRoundText, 0, string.len(stat_EndRoundText) - string.len("\n")))
  end
    stat_EndRoundText = ""
end)
