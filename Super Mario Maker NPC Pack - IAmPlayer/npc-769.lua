local npcManager = require("npcManager")
local rng = require("rng")
local ASmovement = require("AI/angrySun")

local moon = {}
local npcID = NPC_ID

local moonSettings = {
	id = npcID,
	gfxheight = 48,
	gfxwidth = 48,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 8,
	frames = 1,
	framestyle = 0,
	framespeed = 8,
	speed = 1,
	
	--Collision-related
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
	--Various interactions
	jumphurt = true, --If true, spiny-like
	spinjumpsafe = false, --If true, prevents player hurt when spinjumping
	harmlessgrab = false, --Held NPC hurts other NPCs if false
	harmlessthrown = false, --Thrown NPC hurts other NPCs if false
	isinteractable = true,

	lightradius = 320,
	lightbrightness = 1,
	lightoffsetx = 0,
	lightoffsety = 0,
	lightcolor = Color.yellow,
	
	effectID = 753,
}

local configFile = npcManager.setNpcSettings(moonSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

ASmovement.register(npcID)

function moon.onInitAPI()
	npcManager.registerEvent(npcID, moon, "onTickNPC")
end

local function doLuckyStar(v)
	v:kill()
	Effect.spawn(configFile.effectID, v.x - v.width / 2, v.y + v.height / 2)
	local pos = vector(v.x, v.y)
	for _, e in ipairs(NPC.get(NPC.HITTABLE)) do
		if e.x + e.width > camera.x and e.x - e.width < camera.x + 800 and e.y + e.height > camera.y and e.y - e.height < camera.x + 800 then --if onscreen
			Effect.spawn(configFile.effectID, e.x - e.width / 2, e.y + e.height / 2)
			e:kill()
		end
	end
	Misc.givePoints(configFile.score, pos, true)
		
	if configFile.score < 10 then
		SFX.play(6)
	elseif configFile.score >= 10 then
		SFX.play(15)
	end
end

function moon.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if Colliders.collide(player, v) then
		doLuckyStar(v)
	end
end

--Gotta return the library table!
return moon