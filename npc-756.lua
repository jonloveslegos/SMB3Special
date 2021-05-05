local npcManager = require("npcManager")
local burnerFire = require("AI/burnerFire")

local fire = {}
local npcID = NPC_ID

local fireSettings = {
	id = npcID,
	gfxheight = 28,
	gfxwidth = 94,
	width = 94,
	height = 28,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 8,
	framestyle = 1,
	framespeed = 8,
	speed = 1,

	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noyoshi= true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	
	lightradius = 64,
	lightbrightness = 2,
	lightcolor = Color.orange,
	duration = 120
}

local configFile = npcManager.setNpcSettings(fireSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

burnerFire.register(npcID, nil)

--Gotta return the library table!
return fire