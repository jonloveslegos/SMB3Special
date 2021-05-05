local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local baby = {}
startY = nil
local AnimOffset = 0
local touchedWater = false
function baby.register(id)
    npcManager.registerEvent(id, baby, "onTickNPC")
	npcManager.registerEvent(id, baby, "onDrawNPC")
end
function baby.onStart(v)
	
end
function baby.onTickNPC(v)
	
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function baby.onDrawNPC(v)
	
end
return baby;