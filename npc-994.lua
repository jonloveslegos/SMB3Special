local npcManager = require("npcManager")

local PowerWing = {}
local npcID = NPC_ID

local PowerWingSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 28,
	width = 32,
	height = 28,
	gfxoffsetx = 2,
	gfxoffsety = 4,
	frames = 1,
	framestyle = 0,
	speed = 0,
	grabside = false,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	--Various interactions
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,
	isinteractable = true,
	iscoin = false,
	notcointransformable = true,
	ignorethrownnpcs = true,
	nowaterphysics  = true,
}

npcManager.setNpcSettings(PowerWingSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end