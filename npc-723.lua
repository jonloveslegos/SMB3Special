local npcManager = require("npcManager")

local burnerLeft = {}
local npcID = NPC_ID
local AnimOffset = 0
local burnerLeftSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 64,
	width = 64,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 4,
	framestyle = 0,
	framespeed = 0,
	speed = 1,
	
	npcblock = true,
	npcblocktop = true,
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	staticdirection	=true,
	baby = 0,
	baby2 = 0,
	baby3 = 0,
	spawned = 0,
	locationsX={},
	locationsY={},
}

local configFile = npcManager.setNpcSettings(burnerLeftSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

function burnerLeft.onInitAPI()
	npcManager.registerEvent(npcID, burnerLeft, "onStartNPC")
	npcManager.registerEvent(npcID, burnerLeft, "onTickNPC")
end

local DIR_ON = -1
local DIR_OFF = 1
function burnerLeft.onStartNPC(v)
end
function burnerLeft.onTickNPC(v)
	if Defines.levelFreeze then return end
	v:transform(231)
	v.spawned = v
	if v.spawned.isValid == false then return end
	v.baby = NPC.spawn(722,v.spawned.x,v.spawned.y)
	v.baby2 = NPC.spawn(722,v.spawned.x,v.spawned.y)
	v.baby3 = NPC.spawn(722,v.spawned.x,v.spawned.y)
	v.baby.target = v.spawned
	v.baby2.target = v.spawned
	v.baby3.target = v.spawned
	v.baby.offset = 12
	v.baby2.offset = 24
	v.baby3.offset = 36
	v.locationsX = {v.spawned.x}
	v.locationsY = {v.spawned.y}
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
--Gotta return the library table!
return burnerLeft