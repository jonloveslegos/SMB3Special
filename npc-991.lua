local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local Bass = {}
local npcID = NPC_ID
local ASmovement = require("AI/sinewave")
local BassSettings = {
	id = npcID,
	iswaternpc=true,
	ChaseSpeed = 0.1,
	MaxSpeed = 6,
	spawnTimer = 3,
	wavestart = 1,
	chase = false,
	jumphurt = true,
	nohurt = false,
	gfxwidth=32,
	gfxoffsetx=0,
	gfxoffsety=2,
	gfxheight=32,
	width=26,
	height=26,
	jumphurt=1,
	noblockcollision=1,
	nogravity=1,
	frames=2,
	framestyle=1,
	grid=32,
	gridoffsetx=2,
	gridoffsety=2,
	speed = 1,
	amplitude = 0.5,
	frequency = 6,
	effectID=991,
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
		[HARM_TYPE_PROJECTILE_USED]=991,
		[HARM_TYPE_TAIL]=991,
		[HARM_TYPE_LAVA]=991,
		[HARM_TYPE_NPC]=991,
		[HARM_TYPE_SPINJUMP]=991
	}
);
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
ASmovement.register(npcID)
return Bass