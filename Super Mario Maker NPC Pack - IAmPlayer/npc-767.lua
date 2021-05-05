local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local rotatingBurner = {}
local npcID = NPC_ID

local rotatingBurnerSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 2,
	framestyle = 0,
	framespeed = 8,
	speed = 1,
	
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = true,

	nohurt=true,
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

	fireID = {765, 766},
	fireDirection = {-1, 1},
	cooldown = 256,
}

local configFile = npcManager.setNpcSettings(rotatingBurnerSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

function rotatingBurner.onInitAPI()
	npcManager.registerEvent(npcID, rotatingBurner, "onStartNPC")
	npcManager.registerEvent(npcID, rotatingBurner, "onTickNPC")
	npcManager.registerEvent(npcID, rotatingBurner, "onDrawNPC")
end

local DIR_ON = -1
local DIR_OFF = 1

function rotatingBurner.onStartNPC(v)
	local data = v.data
	
	if data._settings.rState == nil then
		data._settings.rState = 0
	end
	
	if v.direction == DIR_OFF then
		data.state = 0
	elseif v.direction == DIR_ON then
		data.state = 1
	end
	
	data.rState = data._settings.rState
	
	if data.rState == 1 then
		data.rotation = 90
	elseif data.rState == 2 then
		data.rotation = 180
	elseif data.rState == 3 then
		data.rotation = 270
	end
	
	if v.friendly then
		data.friendly = true
		v.friendly = false
	else
		data.friendly = false
	end
end

function rotatingBurner.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	data.timer = data.timer or 0
	data.state = data.state or 0 --0 is for cooldown, 1 is for releasing fire
	data.rState = data.rState or 0 --0 is 0 degrees, 1 is 90 degrees, 2 is 180 degrees, 3 is 270 degrees
	data.rotation = data.rotation or 0
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		
		if data.rState == 1 then
			data.rotation = 90
		elseif data.rState == 2 then
			data.rotation = 180
		elseif data.rState == 3 then
			data.rotation = 270
		else
			data.rotation = 0
		end
		return
	end
	v.animationTimer = 0
	
	data.sprite = Sprite{
			image = Graphics.sprites.npc[npcID].img,
			x = v.x + (v.width / 2),
			y = v.y + (v.height / 2),
			width = configFile.gfxwidth,
			height = configFile.gfxheight,
			align = Sprite.align.CENTER,
		}

	if not data.initialized then
		data.initialized = true
	end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		--a
	else
		--b
	end
	
	--AI
	if lunatime.tick() > 0 then
		data.timer = data.timer + 1
	else
		data.sprite.rotation = data.rotation * 90
	end
	
	if data.state == 0 then
		if data.timer >= configFile.cooldown + 48 then
			data.state = 1
			data.timer = 0
		end
		
		if data.timer <= 90 / (configFile.speed * 4) and lunatime.tick() > 90 / (configFile.speed * 4) then
			data.rotation = data.rotation + (configFile.speed * 4)
		end
	elseif data.state == 1 then
		if data.timer == 1 then
			SFX.play(42)
			if data.rState == 0 then
				data.flame = NPC.spawn(configFile.fireID[1], v.x + 2, v.y - NPC.config[configFile.fireID[1]].height, v:mem(0x146, FIELD_WORD))
				data.flame.direction = configFile.fireDirection[1]
				data.flame.layerName = "Spawned NPCs"
				data.flame.friendly = data.friendly
				data.rotation = 0
			elseif data.rState == 1 then
				data.flame = NPC.spawn(configFile.fireID[2], v.x + NPC.config[v.id].width, v.y + 2, v:mem(0x146, FIELD_WORD))
				data.flame.direction = configFile.fireDirection[2]
				data.flame.layerName = "Spawned NPCs"
				data.flame.friendly = data.friendly
				data.rotation = 90
			elseif data.rState == 2 then
				data.flame = NPC.spawn(configFile.fireID[1], v.x + 2, v.y + v.height, v:mem(0x146, FIELD_WORD))
				data.flame.direction = configFile.fireDirection[2]
				data.flame.layerName = "Spawned NPCs"
				data.flame.friendly = data.friendly
				data.rotation = 180
			elseif data.rState == 3 then
				data.flame = NPC.spawn(configFile.fireID[2], v.x - NPC.config[configFile.fireID[2]].width, v.y + 2, v:mem(0x146, FIELD_WORD))
				data.flame.direction = configFile.fireDirection[1]
				data.flame.layerName = "Spawned NPCs"
				data.flame.friendly = data.friendly
				data.rotation = 270
			end

			data.flame.data._settings.parent = v
		elseif data.timer >= configFile.cooldown + 48 then
			data.state = 0
			data.timer = 0
			
			if data.rState == 3 then
				data.rState = 0
			else
				data.rState = data.rState + 1
			end
		end
	end
	
	--make this thing movable, shall we?
	v.x = v.x + v.layerObj.speedX
	v.y = v.y + v.layerObj.speedY
end

function rotatingBurner.onDrawNPC(v)
	if v:mem(0x12A, FIELD_WORD) <= 0 then return end
	
	local data = v.data
	
	if not Misc.isPaused() then
		if not Defines.levelFreeze and lunatime.tick() > 0 then
			data.sprite:rotate(data.rotation)
		end
	end
	
	local p = -45
    if configFile.foreground then
        p = -15
    end
	
	data.sprite:draw{
		priority = p,
		sceneCoords = true,
	}
	
	npcutils.hideNPC(v)
end

--Gotta return the library table!
return rotatingBurner