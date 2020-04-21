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

--From here on everything is for sending data to the client
function stat_SendMessage_ent(Name, ent)
  util.AddNetworkString(Name)
  net.Start(Name)
  net.WriteEntity(ent)
  net.Broadcast()
end

function stat_SendMessage_str(Name, str)
  util.AddNetworkString(Name)
  net.Start(Name)
  net.WriteString(str)
  net.Broadcast()
end

function stat_SendMessage_flt(Name, flt)
  util.AddNetworkString(Name)
  net.Start(Name)
  net.WriteFloat(flt)
  net.Broadcast()
end

hook.Add("PlayerDeath", "ttt_Statistics_Addon", function(victim, inflictor, attaker)
 if attaker and victim ~= nil then
        stat_SendMessage_ent("stat_Attaker", attaker)
        stat_SendMessage_ent("stat_Victim", victim)
  end
end)

hook.Add("TTTBodyFound", "ttt_Statistics_Addon", function(player, x, xx)
  stat_SendMessage_ent("stat_Player", player)
end)

hook.Add("PlayerHurt", "ttt_Statistics_Addon", function(player, entity, remain, dealt)
  stat_SendMessage_ent("stat_Hurt", entity)
  stat_SendMessage_flt("stat_Damage", dealt)
  stat_SendMessage_ent("stat_GotHurt", player)
  stat_SendMessage_flt("stat_DamageRecieved", dealt)

end)

hook.Add("TTTEndRound", "ttt_Statistics_Addon2", function(result)
  stat_SendMessage_str("stat_result", result)
  if (stat_EndRoundText ~= "") and (GetConVar("stat_ShowMilestones"):GetBool()) then
    PrintMessage(3,stat_EndRoundText)
  end
    stat_EndRoundText = ""
end)
