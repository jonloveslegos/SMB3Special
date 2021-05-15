local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local Bass = {}
local npcID = NPC_ID
local ASmovement = require("AI/bertha")
local BassSettings = {
	id = npcID,
	iswaternpc=true,
	ChaseSpeed = 0.1,
	MaxSpeed = 4,
	spawnTimer = 3,
	jumphurt = true,
	nohurt = false,
	gfxwidth=48,
	gfxheight=64,
	width=48,
	height=64,
	jumphurt=1,
	noblockcollision=1,
	nogravity=1,
	frames=2,
	framestyle=1,
	framespeed = 8,
	grid=64,
	gridoffsetx=0,
	effectID=754,
}

local configFile = npcManager.setNpcSettings(BassSettings)
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_TAIL,
		HARM_TYPE_NPC,
		HARM_TYPE_LAVA,
		HARM_TYPE_SPINJUMP
	}, 
	{
		[HARM_TYPE_PROJECTILE_USED]=754,
		[HARM_TYPE_TAIL]=754,
		[HARM_TYPE_LAVA]=754,
		[HARM_TYPE_NPC]=754,
		[HARM_TYPE_SPINJUMP]=754
	}
);
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
ASmovement.register(npcID)
return Bass