local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local Bass = {}
local npcID = NPC_ID
local BassSettings = {
	id = npcID,
	nohurt = true,
	gfxwidth=32,
	gfxoffsetx=0,
	gfxoffsety=0,
	gfxheight=32,
	width=32,
	height=32,
	noblockcollision=1,
	nogravity=1,
	frames=8,
	framestyle=1,
	grid=32,
	ignorethrownnpcs=true,
	gridoffsetx=0,
	gridoffsety=0,
	speed = 0,
	nofireball = true,
	noiceball = true,
	noyoshi = false,
	effectID=990,
	score=6,
	isinteractable=true,
	noblockcollision=true,
	nogravity = true,
	harmlessgrab = true,
	notcointransformable = true,
}

local configFile = npcManager.setNpcSettings(BassSettings)
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_VANISH
	}, 
	{
		[HARM_TYPE_VANISH] = 990
	}
);
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
return Bass