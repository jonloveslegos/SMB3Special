local npcManager = require("npcManager")
local orbits = require("orbits")

local newFirebar = {}
local npcID = NPC_ID

local newFirebarSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	framestyle = 0,
	framespeed = 8,
	speed = 1,
	
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = true,

	nohurt=false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
}

local configFile = npcManager.setNpcSettings(newFirebarSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

function newFirebar.onInitAPI()
	npcManager.registerEvent(npcID, newFirebar, "onTickNPC")
end

function newFirebar.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	data.lifetime = data.lifetime or 0
	data.isMade = data.isMade or false
	
	if data.notLimited == nil then
		data.notLimited = true
	end
	
	data._settings.length = data._settings.length or 6
	data._settings.angle = data._settings.angle or 0
	data._settings.number = data._settings.number or 1
	data._settings.speed = data._settings.speed or 5
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if data.lifetime == 1 then
		if not data.isMade then
			data.center = NPC.spawn(260, v.x + (v.width * 0.5), v.y + (v.height * 0.5), player.section, data.notLimited, true)
			data.center.friendly = v.friendly
			
			data.center.x = v.x + (v.width / 4)
			data.center.y = v.y + (v.height / 4)
			
			for i = 1, data._settings.length do
				data.orbit = orbits.new{
					attachToNPC = v,
					id = 260,
					section = v:mem(0x146, FIELD_WORD),
					rotationSpeed = (0.1 * data._settings.speed) * v.direction,
					number = 1,
					angleDegs = 270 + data._settings.angle,
					number = data._settings.number,
					radius = 16 * i,
					friendly = v.friendly,
				}
			end
			
			data.isMade = true
		
			if lunatime.tick() > 2 then
				SFX.play(16)
			end
		end
	elseif data.lifetime > 1 then
		v.friendly = false
		
		--make this thing movable, shall we?
		v.x = v.x + v.layerObj.speedX
		v.y = v.y + v.layerObj.speedY
		
		--this too
		if data.center ~= nil then
			data.center.x = v.x + (v.width / 4)
			data.center.y = v.y + (v.height / 4)
		end
	end
	
	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		data.lifetime = 0
		data.notLimited = false
	else
		data.lifetime = data.lifetime + 1
	end
end

--Gotta return the library table!
return newFirebar