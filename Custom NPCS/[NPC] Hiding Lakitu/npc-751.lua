--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local hidingLakitu = {}
local npcID = NPC_ID

local deathEffectID = (npcID)

local hidingLakituSettings = {
	id = npcID,
	
	gfxwidth = 36,
	gfxheight = 60,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 32,
	height = 52,
	
	frames = 4,
	framestyle = 1,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = false,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi = false,
	nowaterphysics = true,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	idleTime = 64,   -- How long the lakitu stays hiding before it starts rising.
	watchTime = 128, -- How long the lakitu looks left and right before it starts rising again.
	readyTime = 32,  -- How long the lakitu waits before throwing an NPC.
	throwTime = 48,  -- How long the lakitu is throwing an NPC.

	raiseSpeed = 1, -- How fast the lakitu raises upwards.
	lowerSpeed = 1, -- How fast the lakitu returns to its spawn point.

	throwXSpeed = 1.5, -- How fast the thrown NPC moves horizontally.
	throwYSpeed = -5,  -- How fast the thrown NPC moves vertically.

	throwSFX = 25, -- The sound played when the lakitu throws an NPC. Can be nil for none, a number for a vanilla sound, or a sound effect object/string for a custom sound.

	minPlayerDistance = 48, -- The minimum distance from the player to be able to start rising.
}

npcManager.setNpcSettings(hidingLakituSettings)
npcManager.registerDefines(npcID,{NPC.HITTABLE})
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_SPINJUMP,
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		[HARM_TYPE_JUMP]            = deathEffectID,
		[HARM_TYPE_FROMBELOW]       = deathEffectID,
		[HARM_TYPE_NPC]             = deathEffectID,
		[HARM_TYPE_PROJECTILE_USED] = deathEffectID,
		[HARM_TYPE_HELD]            = deathEffectID,
		[HARM_TYPE_TAIL]            = deathEffectID,
		[HARM_TYPE_SPINJUMP]        = 10,
		[HARM_TYPE_OFFSCREEN]       = deathEffectID,
	}
)

-- Define constants
local DIR_UP   = DIR_LEFT
local DIR_DOWN = DIR_RIGHT

local STATE_IDLE       = 0
local STATE_START_RISE = 1
local STATE_WATCH      = 2
local STATE_FINAL_RISE = 3
local STATE_READY      = 4
local STATE_THROW      = 5
local STATE_LOWER      = 6

local facePlayerStateMap = table.map{STATE_IDLE,STATE_START_RISE,STATE_FINAL_RISE,STATE_READY} -- A map of states the lakitu is able to face the player in

local throwSpecialCases = {}

function hidingLakitu.onInitAPI()
	npcManager.registerEvent(npcID,hidingLakitu,"onTickEndNPC")
	npcManager.registerEvent(npcID,hidingLakitu,"onDrawNPC")

	registerEvent(hidingLakitu,"onStart")
end

function hidingLakitu.onStart()
	for id=1,NPC_MAX_ID do
		local config = NPC.config[id]

		-- Exceptions for certain IDs. 'v' is the thrown NPC, while 'w' is the lakitu.
		if config.iscoin then -- Coins
			throwSpecialCases[id] = (function(v,w) v.ai1 = 1 end)
		elseif id == 12 then -- Podoboo
			throwSpecialCases[id] = (function(v,w) v.ai2 = 2 end)
		elseif id == 45 then -- Throw block
			throwSpecialCases[id] = (function(v,w) v.ai1 = 1 end)
		elseif id == 246 then -- Venus Fire Trap's fireball
			throwSpecialCases[id] = (function(v,w)
				local n = Player.getNearest(v.x+(v.width/2),v.y+(v.height/2))

				if n then
					local angle = -math.atan2((n.y+(n.height/2))-(v.y+(v.height/2)),(n.x+(n.width/2))-(v.x+(v.width/2)))

					v.speedX =  math.cos(angle)*3
					v.speedY = -math.sin(angle)*3
				end
			end)
		elseif id == 263 then -- Ice block
			throwSpecialCases[id] = (function(v,w) v:transform(237) end) -- shh nobody will notice it's actually a different NPC
		elseif id == 615 then -- Boomerang
			throwSpecialCases[id] = (function(v,w) v.data._basegame.ownerBro = w end)
		end
	end
end

function hidingLakitu.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local config = NPC.config[v.id]
	local data = v.data
	
	if v.despawnTimer <= 0 then
		data.state = nil
		return
	end

	if not data.state then
		data.state = STATE_IDLE
		data.timer = 0

		data.animationTimer = 0

		data.horizontalDirection = DIR_LEFT

		if v.spawnId > 0 then
			data.home = vector(v.spawnX+(v.spawnWidth/2),v.spawnY+(v.spawnHeight/2))
			data.verticalDirection = v.spawnDirection
		else
			data.home = vector(v.x+(v.width/2),v.y+(v.height/2))
			data.verticalDirection = v.direction
		end
	end

	data.animationTimer = data.animationTimer + 1

	v.animationFrame = math.floor(data.animationTimer/config.framespeed)%(config.frames/4)
	
	if data.state == STATE_THROW then
		v.animationFrame = v.animationFrame + (config.frames/4)
	end

	if data.horizontalDirection == DIR_RIGHT then
		v.animationFrame = v.animationFrame + (config.frames/2)
	end
	if config.framestyle >= 1 and data.verticalDirection == DIR_DOWN then
		v.animationFrame = v.animationFrame + (config.frames)
	end

	if config.framestyle >= 2 and (v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL)) then
		v.animationFrame = v.animationFrame + (config.frames*2)
	end


	-- Handle odd case of being on yoshi's tongue before the player dismounts
    if v:mem(0x138,FIELD_WORD) == 0 and data.priorlyOnTongue then
        v:harm(HARM_TYPE_NPC)
    end
	data.priorlyOnTongue = (v:mem(0x138,FIELD_WORD) == 5)
	

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then return end

	local n = Player.getNearest(v.x+(v.width/2),v.y+(v.height/2))
	local playerDistanceX,playerDistanceY = math.huge,math.huge

	if n then
		playerDistanceX = (n.x+(n.width /2))-(v.x+(v.width /2))
		playerDistanceY = (n.y+(n.height/2))-(v.y+(v.height/2))

		if facePlayerStateMap[data.state] and math.abs(playerDistanceX) > 8 then
			data.horizontalDirection = math.sign(playerDistanceX)
		end
	end
	
	data.timer = data.timer + 1

	if data.state == STATE_IDLE then
		v.speedY = 0

		if data.timer >= config.idleTime then
			if math.abs(playerDistanceX) > config.minPlayerDistance then
				data.state = STATE_START_RISE
				data.timer = 0
			else
				data.timer = 0
			end
		end
	elseif data.state == STATE_START_RISE then
		v.speedY = config.raiseSpeed*data.verticalDirection

		if math.abs((v.y+(v.height/2))-data.home.y) > (v.height*0.45) then
			data.state = STATE_WATCH
			data.timer = 0
		end
	elseif data.state == STATE_WATCH then
		v.speedY = 0

		if data.timer >= config.watchTime then
			data.state = STATE_FINAL_RISE
			data.timer = 0
		elseif data.timer%math.ceil(config.watchTime/3) == 0 then
			data.horizontalDirection = -data.horizontalDirection
		end
	elseif data.state == STATE_FINAL_RISE then
		v.speedY = config.raiseSpeed*data.verticalDirection

		if math.abs((v.y+(v.height/2))-data.home.y) > (v.height*0.75) then
			data.state = STATE_READY
			data.timer = 0
		end
	elseif data.state == STATE_READY then
		v.speedY = 0

		if data.timer >= config.readyTime then
			data.state = STATE_THROW
			data.timer = 0
		end
	elseif data.state == STATE_THROW then
		if data.timer == 1 then
			local spawnId = v.ai1
			if spawnId == 0 then
				spawnId = 286
			end

			local w = NPC.spawn(spawnId,v.x+(v.width/2),v.y+(v.height/4),v.section,false,true)

			w.direction = data.horizontalDirection

			w.speedX = config.throwXSpeed*data.horizontalDirection

			if NPC.config[w.id].harmlessthrown then
				w:mem(0x136,FIELD_BOOL,true)
			end
			if not NPC.config[w.id].nogravity then
				w.speedY = -config.throwYSpeed*data.verticalDirection
			end

			if throwSpecialCases[w.id] then
				throwSpecialCases[w.id](w,v)
			end

			if config.throwSFX then
				SFX.play(config.throwSFX)
			end
		elseif data.timer >= config.throwTime then
			data.state = STATE_LOWER
			data.timer = 0
		end
	elseif data.state == STATE_LOWER then
		v.speedY = -config.lowerSpeed*data.verticalDirection

		if math.abs((v.y+(v.height/2))-data.home.y) <= config.lowerSpeed then
			data.state = STATE_IDLE
			data.timer = 0
		end
	end
end

function hidingLakitu.onDrawNPC(v)
	if v.despawnTimer <= 0 then return end

	local config = NPC.config[v.id]
	local data = v.data

	--Colliders.Box(data.home.x-(v.width/2),data.home.y-(v.height/2),v.width,v.height):Draw()

	if not config.foreground and v:mem(0x12C, FIELD_WORD) == 0 and not v:mem(0x136, FIELD_BOOL) and v:mem(0x138, FIELD_WORD) == 0 then
		npcutils.drawNPC(v,{priority = -75})
		npcutils.hideNPC(v)
	end
end

return hidingLakitu