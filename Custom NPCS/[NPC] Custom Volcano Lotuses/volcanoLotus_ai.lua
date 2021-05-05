--[[

	Written by MrDoubleA
	Please give credit!

	Flying Volcano Lotus concept from Darolac (https://www.smwcentral.net/?p=section&a=details&id=20527)

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")

local volcanoLotus = {}

volcanoLotus.idMap = {}
volcanoLotus.fireballIdMap = {}

-- Plant state constants
local STATE_IDLE  = 0
local STATE_FLASH = 1
local STATE_SPURT = 2

-- Fireball state constants
local STATE_LAUNCH = 0
local STATE_FALL   = 1

local configDefaults = {
    idleTime  = 170,      -- How long the NPC is in its idle state.
    flashTime = 70,       -- How long the NPC is in its flashing state.
    spurtTime = 50,       -- How long the NPC is in its spurting state.

    spurtNPCID     = 753, -- ID of the NPCs spawned when spurting.
    spurtNPCSpawns = 4,   -- How many NPCs are spawned when spurting.

    isHorizontal = false, -- Whether or not this NPC is horizontal.
	isWinged = false,     -- Whether or not this NPC can fly around and chase the player.
}
local fireballConfigDefaults = {
    gravity = 0.02,       -- How fast the NPC gains downward speed.
    terminalVelocity = 2, -- Max downwards speed for the NPC.

    trembleSpeed = 0.8,   -- How fast the NPC moves back and forth.
}

local function getNearestPlayer(x,y)
    local c

    for _,v in ipairs(Player.get()) do
        if v.forcedState == 0 and v.deathTimer == 0 then
            if not closest or( (math.abs(x-(v.x+(v.width/2)))+math.abs(y-(v.y+(v.height/2)))) < (math.abs(x-(c.x+(c.width/2)))+math.abs(y-(c.y+(c.height/2))))) then
                c = v
            end
        end
    end

    return c
end

function volcanoLotus.registerVolcanoLotus(id)
    volcanoLotus.idMap[id] = true

    for k,v in pairs(configDefaults) do
		if NPC.config[id][k] == nil then
			npcManager.setNpcSettings({id = id,[k] = v}) -- Set config variable if it isn't already set
		end
    end
    
    npcManager.registerEvent(id,volcanoLotus,"onTickEndNPC","onTickEndPlant")
end
function volcanoLotus.registerFireball(id)
    volcanoLotus.fireballIdMap[id] = true

    for k,v in pairs(fireballConfigDefaults) do
		if NPC.config[id][k] == nil then
			npcManager.setNpcSettings({id = id,[k] = v}) -- Set config variable if it isn't already set
		end
    end

    npcManager.registerEvent(id,volcanoLotus,"onTickEndNPC","onTickEndFireball")
end

function volcanoLotus.onTickEndPlant(v)
	if Defines.levelFreeze then return end
    
    local config = NPC.config[v.id]
    local data = v.data
    
    -- Use extra settings if the per-NPC settings box is ticked, otherwise use the NPC config
    local settings = data._settings
    if not settings.override then settings = config end
	
    if v:mem(0x12A, FIELD_WORD) <= 0 then
        data.state,data.timer,data.animationTimer,data.flyingTimer,data.direction = nil,nil,nil,nil,nil -- Reset the data stuff
		return
    end

    if not data.state then
        -- Set all the needed data stuff
        data.state = STATE_IDLE
        data.timer = 0

        data.animationTimer = 0

        data.flyingTimer = 0

        if v:mem(0xDC,FIELD_WORD) > 0 then
            data.direction = v:mem(0xD8,FIELD_FLOAT) -- Set it to the spawn direction if the NPC respawns...
        else
            data.direction = v.direction -- ... otherwise, set it to the NPC's current direction
        end

        data.priorlyOnTongue = false
    end
    

    -- Animation stuff

    data.animationTimer = data.animationTimer + 1

    if data.state == STATE_IDLE then
        v.animationFrame = (math.floor(data.animationTimer/(config.framespeed))%(config.frames/2))
    elseif data.state == STATE_FLASH then
        local totalAnimationTime = ((config.frames/2)*(config.framespeed/2))

        if (data.animationTimer%totalAnimationTime) < (totalAnimationTime/2) then
            v.animationFrame = (math.floor(data.animationTimer/(config.framespeed*2))%(config.frames/4))
        else
            v.animationFrame = (config.frames*0.5) + (math.floor(data.animationTimer/(config.framespeed*2))%(config.frames/4))
        end
    else
        v.animationFrame = (config.frames*0.75) + (math.floor(data.animationTimer/(config.framespeed))%(config.frames/4))
    end

    if config.framestyle >= 1 and data.direction == DIR_RIGHT then
        v.animationFrame = v.animationFrame + config.frames
    end
    if config.framestyle >= 2 and (v:mem(0x12C, FIELD_WORD) > 0 or v:mem(0x136, FIELD_BOOL)) then
        v.animationFrame = v.animationFrame + config.frames*2
    end


    -- Handle odd case of being on yoshi's tongue before the player dismounts
    if v:mem(0x138,FIELD_WORD) == 0 and data.priorlyOnTongue then
        v:harm(HARM_TYPE_NPC)
    end
    data.priorlyOnTongue = (v:mem(0x138,FIELD_WORD) == 5)

	if v:mem(0x12C,FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136,FIELD_BOOL)        --Thrown
	or v:mem(0x138,FIELD_WORD) > 0    --Contained within
    then
        -- Reset some variables if grabbed
        data.state = STATE_IDLE
        data.timer = 0

        data.flyingTimer = 0
        return
    end

    -- Main behaviour

    data.timer = data.timer + 1
	
    if data.state == STATE_IDLE then
        if data.timer >= settings.idleTime then
            data.state = STATE_FLASH
            data.timer = 0
        end
    elseif data.state == STATE_FLASH then
        if data.timer >= settings.flashTime then
            if not NPC.config[settings.spurtNPCID] or not NPC.config[settings.spurtNPCID].noblockcollision and #Colliders.getColliding{
                a = v,
                b = Block.SOLID.. Block.LAVA.. Block.PLAYER,
                btype = Colliders.BLOCK,
            } > 0
            then
                data.timer = 0
            else
                data.state = STATE_SPURT
                data.timer = 0
            end
        end
    elseif data.state == STATE_SPURT then
        if data.timer == 1 and settings.spurtNPCID >= 0 and settings.spurtNPCID <= 1000 then -- When first entering this state
            for i=-settings.spurtNPCSpawns/2,settings.spurtNPCSpawns/2 do
                if i ~= 0 then
                    local x,y
                    if not config.isHorizontal then
                        -- Vertical spawn positions
                        x = (v.x+(v.width /2))
                        y = (v.y+(v.height/2)+((v.height/2)*data.direction))
                    else
                        -- Horizontal spawn positions
                        x = (v.x+(v.width /2)+((v.width /2)*data.direction))
                        y = (v.y+(v.height/2))
                    end

                    local w = NPC.spawn(settings.spurtNPCID,x,y,v.section,false,true)

                    w.layerName = v.layerName
                    w.data.isHorizontal = config.isHorizontal

                    -- Find speedX and speedY for this NPC
                    local speedX = (1 + (2.5 * (((settings.spurtNPCSpawns/2)-math.abs(i)  )/math.max(1,(settings.spurtNPCSpawns/2)-1))))*math.sign(i)
                    local speedY = (2 + (1.5 * ((                            math.abs(i)-1)/math.max(1,(settings.spurtNPCSpawns/2)-1))))*data.direction

                    -- Set speedX, speedY and direction for this NPC
                    if not config.isHorizontal then
                        w.direction = math.sign(i)

                        w.speedX = speedX
                        w.speedY = speedY
                    else
                        w.direction = data.direction

                        w.speedX = speedY
                        w.speedY = speedX
                    end
                end
            end
        end

        if data.timer >= settings.spurtTime then
            data.state = STATE_IDLE
            data.timer = 0
        end
    end

    if config.isWinged then
        data.flyingTimer = data.flyingTimer + 1

        local n = getNearestPlayer(v.x+(v.width/2),v.y+(v.height/2))
        if n then
            v.speedX = math.clamp(v.speedX+(math.sign((n.x+(n.width/2))-(v.x+(v.width/2)))*0.15),-4.5,4.5)
        elseif v.speedX > 0 then
            v.speedX = math.max(0,v.speedX - 0.15)
        elseif v.speedX < 0 then
            v.speedX = math.min(0,v.speedX + 0.15)
        end

        v.speedY = math.cos(data.flyingTimer/24)*1
    end
end

function volcanoLotus.onTickEndFireball(v)
    if Defines.levelFreeze then return end
    
    local config = NPC.config[v.id]
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
        data.state,data.trembleTimer = nil,nil
		return
	end

	if not data.state then
        data.state = STATE_LAUNCH
        data.trembleTimer = 0
    end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
    then
        -- Reset some variables if grabbed
        data.state = STATE_LAUNCH
        data.trembleTimer = 0
        return
    end

    if data.state == STATE_LAUNCH then
        -- Slow down
        v.speedX = v.speedX * 0.98
        v.speedY = v.speedY * 0.98
    
        if (not data.isHorizontal and math.abs(v.speedY) < 0.5) or (data.isHorizontal and math.abs(v.speedX) < 0.5) then
            -- Enter falling state
            v.speedX,v.speedY = 0,0
    
            data.state = STATE_FALL
            data.trembleTimer = 0
        end
    elseif data.state == STATE_FALL then
        v.speedY = math.min(config.terminalVelocity,v.speedY + config.gravity)
    
        if math.abs(v.speedY) > 0.25 then
            -- Back and forth movement
            data.trembleTimer = data.trembleTimer + 1
    
            if (data.trembleTimer%14) < 7 then
                v.speedX = -config.trembleSpeed
            else
                v.speedX = config.trembleSpeed
            end
        end
    end
end

return volcanoLotus