--[[

	Written by MrDoubleA
	Please give credit!

	Concept from WhiteYoshiEgg (https://www.smwcentral.net/?p=section&a=details&id=20835)
	Graphics for red/flower pipe improved by Novarender

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")

local carryablePipe = {}

carryablePipe.ids = {}

carryablePipe.playerInfo = {}



local STATE_ENTER      = 0
local STATE_TRANSITION = 1
local STATE_EXIT       = 2

local configDefaults = {
    enterSpeed = 8,
    exitSpeed = 8,

    launchSpeed = 4,

    cameraMovementSpeed = 24,

    conserveXSpeed = false,
	
	-- Top for normal pipe sound effect, bottom for short version.
	
	--enterSoundEffect = 17,
	enterSoundEffect = Misc.multiResolveFile("warp-short.ogg", "sound/extended/warp-short.ogg"),
}

local function boundCamera(x,y,width,height,bounds)
	if x < bounds.left then
		x = bounds.left
	elseif x > bounds.right-width then
		x = bounds.right-width
	end
	if y < bounds.top then
		y = bounds.top
	elseif y > bounds.bottom-height then
		y = bounds.bottom-height
	end

	return x,y
end

function carryablePipe.registerCarryablePipe(id)
	carryablePipe.ids[id] = true
	
	for k,v in pairs(configDefaults) do
		if NPC.config[id][k] == nil then
			-- Set config variable if it isn't already set.
			npcManager.setNpcSettings({id = id,[k] = v})
		end
	end
    
    npcManager.registerEvent(id,carryablePipe,"onTickNPC")
end

function carryablePipe.onInitAPI()
    registerEvent(carryablePipe,"onTickEnd")
	registerEvent(carryablePipe,"onDraw")
	registerEvent(carryablePipe,"onCameraUpdate")
end

function carryablePipe.onTickEnd()
	for k,v in ipairs(Player.get()) do
		local info = carryablePipe.playerInfo[k]

        if info then
            local config = NPC.config[info.enterNPC.id]

			if v.forcedState ~= 8 then
				carryablePipe.playerInfo[k] = nil
			elseif (not info.enterNPC or not info.enterNPC.isValid) or (not info.exitNPC or not info.exitNPC.isValid) or (info.enterNPC.id ~= info.exitNPC.id) or (not carryablePipe.ids[info.enterNPC.id] or not carryablePipe.ids[info.exitNPC.id]) then
				-- In the case that the NPC has been killed/despawned, cancel
				carryablePipe.playerInfo[k] = nil

				v.forcedState = 0
				v.forcedTimer = 0
			elseif info.state == STATE_ENTER then
				v.x = (info.enterNPC.x+(info.enterNPC.width/2))-(v.width/2)
				v.y = (info.enterNPC.y-v.height)

				info.yOffset = info.yOffset + config.enterSpeed

				if info.yOffset >= v.height then
					info.yOffset = v.height

                    if not config.cameraMovementSpeed or config.cameraMovementSpeed == 0 -- Skip camera movement if set to
                    or Player.count() > 1 -- or if it's multiplayer
					or info.enterNPC.section ~= info.exitNPC.section -- or if NPCs are in different sections
                    then
						info.state = STATE_EXIT
						
						if config.enterSoundEffect then
							SFX.play(config.enterSoundEffect)
						end
					else
						info.state = STATE_TRANSITION
						info.cameraX,info.cameraY = camera.x,camera.y
					end
				end
			elseif info.state == STATE_TRANSITION then
				if Player.count() > 1 then
					info.state = STATE_EXIT
					
					if config.enterSoundEffect then
						SFX.play(config.enterSoundEffect)
					end
				else
					local goalX,goalY = boundCamera(
						(info.exitNPC.x+(info.exitNPC.width/2))-(camera.width /2),
						(info.exitNPC.y                       )-(camera.height/2),
						camera.width,camera.height,Section(info.exitNPC.section).boundary
					)

					if info.cameraX > goalX then
						info.cameraX = math.max(goalX,info.cameraX-config.cameraMovementSpeed)
					elseif info.cameraX < goalX then
						info.cameraX = math.min(goalX,info.cameraX+config.cameraMovementSpeed)
					end
					if info.cameraY > goalY then
						info.cameraY = math.max(goalY,info.cameraY-config.cameraMovementSpeed)
					elseif info.cameraY < goalY then
						info.cameraY = math.min(goalY,info.cameraY+config.cameraMovementSpeed)
					end

					if info.cameraX == goalX and info.cameraY == goalY then
						info.state = STATE_EXIT

						if config.enterSoundEffect then
							SFX.play(config.enterSoundEffect)
						end
					end
				end
			elseif info.state == STATE_EXIT then
				v.x = (info.exitNPC.x+(info.exitNPC.width/2))-(v.width/2)
				v.y = (info.exitNPC.y-v.height)
				v.section = info.exitNPC.section

				info.cameraX,info.cameraY = nil,nil

				info.yOffset = info.yOffset - config.exitSpeed

				if info.yOffset <= 0 then
					info.yOffset = 0

					v.forcedState = 0
					v.forcedTimer = 0

					carryablePipe.playerInfo[k] = nil

					if config.launchSpeed ~= 0 then
						v.speedY = -config.launchSpeed
					end
				end
			end
		end
	end
end

function carryablePipe.onDraw()
	for k,v in ipairs(Player.get()) do
		local info = carryablePipe.playerInfo[k]

		if info and info.state ~= STATE_TRANSITION then
			local frame = 15
			if v.mount == 1 or v.mount == 2
			or v.character == CHARACTER_LINK or v.character == CHARACTER_SNAKE or v.character == CHARACTER_SAMUS then
				frame = 1
			elseif v.mount == 3 then
				frame = 30
			end

			local npc
			if info.state == STATE_ENTER then
				npc = info.enterNPC
			else
				npc = info.exitNPC 
			end

			v:render{
				x = (npc.x+(npc.width/2))-(v.width/2),y = npc.y-v.height+info.yOffset,
				ignorestate = true,frame = frame,priority = -70,
			}
		end
	end
end

function carryablePipe.onCameraUpdate()
	local info = carryablePipe.playerInfo[1]

	if info and info.cameraX and info.cameraY then
		camera.x = info.cameraX
		camera.y = info.cameraY
	end
end

function carryablePipe.onTickNPC(v)
    if Defines.levelFreeze
    or v:mem(0x12A, FIELD_WORD) <= 0
    then return end
    
    local config = NPC.config[v.id]
	local data = v.data

    if not data.partner then
        -- If there is no currrent "partner", search for one
		for _,w in ipairs(NPC.get(v.id)) do
			if v.idx ~= w.idx and v.ai2 == w.ai2 and not w.layerObj.isHidden then
				data.partner = w
				break
			end
        end
    elseif data.partner and (not data.partner.isValid or v.id ~= data.partner.id or v.ai2 ~= data.partner.ai2 or (data.partner.layerObj and data.partner.layerObj.isHidden)) then
        data.partner = nil -- Clear "partner" if it no longer matches
    end
    
    v:mem(0x12A,FIELD_WORD,180) -- Prevent despawn
    if data.partner and data.partner.isValid and data.partner:mem(0x12A,FIELD_WORD) ~= -1 then
		data.partner:mem(0x12A,FIELD_WORD,180) -- Force partner to spawn/not despawn
    end
    


	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
    then return end
    

    
    -- Entering logic
	if data.partner and data.partner.isValid and data.partner:mem(0x138,FIELD_WORD) == 0 then
		for k,w in ipairs(Player.get()) do
			if w.forcedState == 0 and w.deathTimer == 0 and w.keys.down and w.standingNPC and v.idx == w.standingNPC.idx then
				if config.enterSoundEffect then
					SFX.play(config.enterSoundEffect)
				end
				
				w.forcedState = 8
				v.forcedTimer = 0
				
				w.x = (v.x+(v.width/2))-(w.width/2)
				w.y = (v.y-w.height)

				w:mem(0x154,FIELD_WORD,0) -- Drop current held NPC
				w:mem(0x176,FIELD_WORD,0) -- Reset standing NPC

				if not config.conserveXSpeed then
					w.speedX = 0
				end					
				w.speedY = 0

				if w.mount == 3 then -- If riding Yoshi...
					if w:mem(0xB4,FIELD_WORD) ~= 0 then
						w:mem(0xB8,FIELD_WORD,0) -- If tongue is out, remove NPC on tongue
					end

					-- Retract tongue
					w:mem(0x10C,FIELD_WORD,0)
					w:mem(0xB4,FIELD_WORD,0)
				end
				
				carryablePipe.playerInfo[k] = {enterNPC = v,exitNPC = data.partner,yOffset = 0,state = STATE_ENTER}
			end
		end
	end

	-- SMBX is dumb so here's specific code to make it deaccelerate, based on the source code
	if v.collidesBlockBottom and v.speedX > 0 then
		v.speedX = math.max(0,v.speedX-0.05)
	elseif v.collidesBlockBottom and v.speedX < 0 then
		v.speedX = math.min(0,v.speedX+0.05)
	elseif v.speedX > 0 then
		v.speedX = math.max(0,v.speedX-0.08)
	elseif v.speedX < 0 then
		v.speedX = math.min(0,v.speedX+0.08)
	end
end

return carryablePipe