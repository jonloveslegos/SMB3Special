--[[

	Written by MrDoubleA
	Please give credit!

	Graphics by MatiasNTRM

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")

local bully = {}
local npcID = NPC_ID

local bullySettings = {
	id = npcID,
	
	gfxwidth = 32,
	gfxheight = 32,

	gfxoffsetx = 0,
	gfxoffsety = 2,
	
	width = 32,
	height = 32,
	
	frames = 3,
	framestyle = 1,
	framespeed = 8,
	
	speed = 1,
	score = 0,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = false,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	wanderSpeed    = 1,  -- The speed that the NPC wanders around its spawn position at.
	wanderDistance = 96, -- The maximum distance that the NPC can normally wander from its spawn position.

	startChaseDistance = 160, -- The distance a player needs to be in for the NPC to start chasing them.
	stopChaseDistance  = 224, -- The distance a player needs to be in for the NPC to continue chasing them.

	chaseSpeed        = 3.5,  -- The maximum speed the NPC will chase a player at.
	chaseAcceleration = 0.08, -- How fast the NPC accelerates while chasing a player.
}

npcManager.setNpcSettings(bullySettings)
npcManager.registerDefines(npcID,{NPC.HITTABLE})
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		HARM_TYPE_FROMBELOW,
		HARM_TYPE_NPC,
		HARM_TYPE_PROJECTILE_USED,
		HARM_TYPE_LAVA,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	},
	{
		[HARM_TYPE_JUMP]            = 10,
		[HARM_TYPE_FROMBELOW]       = 10,
		[HARM_TYPE_NPC]             = 10,
		[HARM_TYPE_PROJECTILE_USED] = 10,
		[HARM_TYPE_HELD]            = 10,
		[HARM_TYPE_TAIL]            = 10,
	}
)

local STATE_WANDER = 0
local STATE_CHASE  = 1
local STATE_HIT    = 2
local STATE_SINK   = 3

local colBox = Colliders.Box(0,0,0,0)
local colPoint = Colliders.Point(0,0)

local function updateHomePosition(v)
	local data = v.data

	data.home = vector(v.x+(v.width/2),v.y+(v.height/2))
	data.homeDirection = v.direction
end

function bully.onInitAPI()
	npcManager.registerEvent(npcID,bully,"onTickEndNPC")
	registerEvent(bully,"onNPCHarm")
end

function bully.onNPCHarm(eventObj,v,reason,w)
	if v.id ~= npcID or (reason == HARM_TYPE_OFFSCREEN or reason == HARM_TYPE_HELD or reason == HARM_TYPE_PROJECTILE_USED) then return end

	local data = v.data

	if reason == HARM_TYPE_LAVA then
		if data.state ~= STATE_SINK then
			data.state = STATE_SINK
			data.timer = 0

			v.noblockcollision = true
		end
	elseif data.state ~= STATE_SINK then
		local direction = data.direction or v.direction

		if w then
			direction = (math.sign((w.x+(w.width/2))-(v.x+(v.width/2))))
		end

		data.state = STATE_HIT

		v.speedX = -3*direction
		data.direction = direction

		SFX.play(3)
	end

	eventObj.cancelled = true
end

function bully.onTickEndNPC(v)
	if Defines.levelFreeze then return end
	
	local config = NPC.config[v.id]
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.state = nil
		data.timer = nil

		data.home = nil
		data.homeDirection = nil

		data.direction = nil

		data.animationTimer = nil
		return
	end

	if not data.state then
		data.state = STATE_WANDER
		data.timer = 0

		if v.spawnId > 0 then
			data.home = vector(v.spawnX+(v.spawnWidth/2),v.spawnY+(v.spawnHeight/2))
			data.homeDirection = v.spawnDirection
		else
			updateHomePosition(v)
		end

		data.direction = v.direction

		data.animationTimer = 0
	end

	data.animationTimer = data.animationTimer + 1
	
	if data.state == STATE_HIT then
		v.animationFrame = (((config.frames/3)*2)+(math.floor(data.animationTimer/config.framespeed)%(config.frames/3)))
	else
		local framespeed = config.framespeed

		if data.state == STATE_CHASE or v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL) then
			framespeed = framespeed/2
		end

		v.animationFrame = (math.floor(data.animationTimer/framespeed)%((config.frames/3)*2))
	end

	if config.framestyle >= 1 and (data.direction == DIR_RIGHT) then
		v.animationFrame = v.animationFrame+(config.frames)
	end
	if config.framestyle >= 2 and (v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL)) then
		v.animationFrame = v.animationFrame+(config.frames*2)
	end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then
		data.state = STATE_WANDER
		data.timer = 0

		data.direction = v.direction

		updateHomePosition(v)

		return
	end

	local distanceFromHomeX = (data.home.x-(v.x+(v.width/2)))

	-- Player collision
	for _,w in ipairs(Player.getIntersecting(v.x,v.y,v.x+v.width,v.y+v.height)) do
		if w.forcedState == 0 and w.deathTimer == 0 and not w:mem(0x13C,FIELD_BOOL) then
			local direction = (math.sign((w.x+(w.width/2))-(v.x+(v.width/2))))

			w:mem(0x138,FIELD_FLOAT,6.5*direction)

			data.state = STATE_HIT

			v.speedX = -3*direction
			data.direction = direction

			SFX.play(3)
		end
	end

	if data.state == STATE_WANDER then
		v.speedX = config.wanderSpeed*data.direction

		if v.collidesBlockLeft or v.collidesBlockRight then
			updateHomePosition(v)
		elseif math.abs(distanceFromHomeX) > config.wanderDistance then
			data.direction = math.sign(distanceFromHomeX)
		end

		local n = Player.getNearest(v.x+(v.width/2),v.y+(v.height/2))

		if n then
			local distanceX = (n.x+(n.width /2))-(v.x+(v.width /2))
			local distanceY = (n.y+(n.height/2))-(v.y+(v.height/2))

			local distance = math.abs(distanceX)+math.abs(distanceY)

			if distance < config.startChaseDistance then
				if v.collidesBlockBottom then
					v.speedY = -3
				end

				v.speedX = 0

				data.chasingPlayer = n

				data.state = STATE_CHASE
				data.timer = 0

				data.direction = math.sign(distanceX)
			end
		end
	elseif data.state == STATE_CHASE then
		local exit = (not data.chasingPlayer or not data.chasingPlayer.isValid or data.chasingPlayer.forcedState > 0 or data.chasingPlayer.deathTimer > 0 or data.chasingPlayer:mem(0x13C,FIELD_BOOL))
		
		if not exit then
			local distanceX = (data.chasingPlayer.x+(data.chasingPlayer.width /2))-(v.x+(v.width /2))
			local distanceY = (data.chasingPlayer.y+(data.chasingPlayer.height/2))-(v.y+(v.height/2))

			local distance = math.abs(distanceX)+math.abs(distanceY)

			exit = (distance > config.stopChaseDistance)

			if not exit then
				v.speedX = math.clamp((v.speedX+(math.sign(distanceX)*config.chaseAcceleration)),-config.chaseSpeed,config.chaseSpeed)
				data.direction = math.sign(distanceX)

				local turn = true

				colPoint.x = (v.x+(v.width/2))+(((v.width/2)+1)*math.sign(v.speedX))
				colPoint.y = (v.y+v.height+1)

				for _,w in ipairs(Colliders.getColliding{a = colPoint,b = Block.SOLID.. Block.SEMISOLID.. Block.PLAYER,btype = Colliders.BLOCK}) do
					if not Block.SEMISOLID_MAP[w.id] or (v.speedY >= 0 and v.y+v.height <= w.y+v.speedY+3) then
						turn = false
						break
					end
				end

				if turn then
					v.speedX = 0
				end
			end
		end

		if exit then
			data.state = STATE_WANDER
			data.timer = 0

			data.chasingPlayer = nil
		end
	elseif data.state == STATE_HIT then
		v.speedX = v.speedX - (math.sign(v.speedX)*0.065)

		local e = Effect.spawn(74,0,0)

		e.x = v.x+(v.width/2)+(e.width/2)-v.speedX+RNG.random(-v.width/10,v.width/10)
		e.y = v.y+v.height-e.height

		if math.abs(v.speedX) <= 0.5 then
			data.state = STATE_WANDER
			data.timer = 0
			
			v.speedX = 0
		end

		SFX.play(10)
	elseif data.state == STATE_SINK then
		data.timer = data.timer + 1

		if data.timer%16 == 0 then
			SFX.play(16)
		end

		v.speedX,v.speedY = 0,0.45

		if not config.nogravity and v.underwater and not config.nowaterphysics then
			v.speedY = v.speedY - (Defines.npc_grav/5)
		elseif not config.nogravity then
			v.speedY = v.speedY - (Defines.npc_grav)
		end

		colBox.x,colBox.y = v.x,v.y-1
		colBox.width,colBox.height = v.width,1

		if #Colliders.getColliding{a = colBox,b = Block.LAVA,btype = Colliders.BLOCK} > 0
		or #Colliders.getColliding{a = v     ,b = Block.LAVA,btype = Colliders.BLOCK} == 0 and data.timer > 1
		then
			v:kill(HARM_TYPE_LAVA)
		end
	end
end

return bully