--Create the different ConVars
if not ConVarExists("stat_Record") then
  CreateClientConVar("stat_Record", 1, true , false, "If the Addon should record your stats or not.")
end
if not ConVarExists("stat_MaxDamage") then
  CreateClientConVar("stat_MaxDamage", "200", true, false, "The Maximum Damage added to the player stats. Default is 200 per attack")
end
if not ConVarExists("stat_Alex") then
  CreateClientConVar("stat_Alex", 0, true, false, "This is an Easteregg for r/arrrrr")
end
