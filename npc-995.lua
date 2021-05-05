local npcManager = require("npcManager")

local CoinHiddenInvis = {}
local npcID = NPC_ID

local CoinHiddenInvisSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 28,
	width = 0,
	height = 0,
	gfxoffsetx = 2,
	gfxoffsety = 0,
	frames = 4,
	framestyle = 0,
	speed = 0,
	grabside = false,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	--Various interactions
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,
	isinteractable = false,
	iscoin = false,
	notcointransformable = true,
	ignorethrownnpcs = true,
	nowaterphysics  = true,
}

npcManager.setNpcSettings(CoinHiddenInvisSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
