local npcManager = require("npcManager")
local rng = require("rng")
local CoinHidden = {}
local npcID = NPC_ID

local CoinHiddenSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 28,
	width = 32,
	height = 28,
	gfxoffsetx = 2,
	gfxoffsety = 4,
	frames = 1,
	framestyle = 0,
	speed = 1,
	grabside = false,
	npcblock = true,
	npcblocktop = true,
	playerblock = false,
	playerblocktop = false,
	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = false,
	--Various interactions
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,
	isinteractable = true,
	iscoin = false,
	notcointransformable = true,
	ignorethrownnpcs = true,
}
function CoinHidden.onInitAPI()
	npcManager.registerEvent(npcID,CoinHidden,"onTickNPC")
end
function CoinHidden.onTickNPC(v)
	if v.speedX == 0 then
		local dir = rng.randomInt(0,1)
		if dir == 0 then dir = -1 end
		v.direction = dir
		v.speedX = v.direction*2
	end
end
npcManager.setNpcSettings(CoinHiddenSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

return CoinHidden