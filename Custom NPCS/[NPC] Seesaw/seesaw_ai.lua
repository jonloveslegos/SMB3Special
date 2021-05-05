--[[

	Written by MrDoubleA
    Please give credit!

    Thanks to Josh for helping me with math™

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")

local unclebroadsword = require("characters/unclebroadsword")
local lineguide = require("lineguide")


local seesaw = {}

seesaw.enableSemisolidSlopeFix = true -- Enables a fix for semisolid slopes.


-- The IDs of thwomps, since the thwomps AI file doesn't keep a list of them
seesaw.thwompIDMap  = table.map{295,432,435,437}
-- The IDs of skewers, since the skewers AI file keeps its list of them local
seesaw.skewerIDList =          {423,424}



seesaw.playerData = {} -- A data table for players.

seesaw.idList = {}
seesaw.idMap  = {}


local function warioIsGroundPounding(v)
    return (v.character == CHARACTER_WARIO and (math.floor(Defines.player_grav*10)/10) == 0.8)
end
local function broadswordIsSlamming(v)
    return (v.character == CHARACTER_UNCLEBROADSWORD and (unclebroadsword.attackState == 6 or unclebroadsword.attackState == 7))
end


local function getDistanceFromPivot(v,w) -- Get the distance between the pivot of the platform (v) and an object (w).
    local settings = v.data._settings

    return vector((v.x+(v.width*settings.pivot))-(w.x+(w.width/2)),(v.y)-(w.y+w.height))
end
local function getHorizontalDistanceFromPivot(v,w) -- Gets only the horizontal distance from the pivot, taking into account rotation
    local data = v.data
    
    return getDistanceFromPivot(v,w):rotate(-data.rotation).x
end


local function setupBlock(v)
    local config = NPC.config[v.id]
    local data = v.data

    local settings = v.data._settings

    -- Spawn a new block if we don't have one
    if not data.block or not data.block.isValid then
        data.block = Block.spawn(1,0,0) -- This gets changed after this, so the details don't really matter
    end

    -- Get the right ID for the block
    local id = config.solidBlockID -- Straight, with no slope
    if data.rotation < 0 then
        id = config.leftSlopeBlockID -- To the left
    elseif data.rotation > 0 then
        id = config.rightSlopeBlockID -- To the right
    else
        data.block.isHidden = false -- Prevent it from being hidden if straight
    end

    if data.block.id ~= id then
        data.block:transform(id)
    end

    -- Determine how large the left side and right side of the platform are
    local leftWidth  = (v.width*(  settings.pivot))
    local rightWidth = (v.width*(1-settings.pivot))

    -- Get the leftmost and rightmost points on the platform, relative to the centre
    local left  = vector(leftWidth ,0):rotate(data.rotation+180)
    local right = vector(rightWidth,0):rotate(data.rotation)


    -- See the size of the block
    data.block.width  = math.abs(right.x-left.x)
    data.block.height = math.abs(right.y-left.y)

    if data.rotation == 0 then -- Prevent the block being too small
        data.block.height = v.height
    end

    local x = math.min(v.x+leftWidth+left.x,v.x+leftWidth+right.x)
    local y = math.min(v.y+left.y,v.y+right.y)+0.25

    if data.block.x ~= x or data.block.y ~= y then
        data.block:translate(x-data.block.x,y-data.block.y)
    end
end


local function getObjectsOnPlatform(v) -- Get any objects standing on this platform
    local data = v.data

    local objects = {}

    if data.block and data.block.isValid then -- Only do this if we have a block
        if Block.config[data.block.id].floorslope == 0 then -- Platform does not have a slope
            local x1,y1,x2,y2 = (data.block.x),(data.block.y-1),(data.block.x+data.block.width),(data.block.y)

            for _,w in ipairs(table.append(Player.getIntersecting(x1,y1,x2,y2),NPC.getIntersecting(x1,y1,x2,y2))) do
                if (w.__type == "Player" and w:mem(0x146,FIELD_WORD) > 0) or (w.__type == "NPC" and w.collidesBlockBottom) then -- The object is probably standing on that block
                    table.insert(objects,w)
                end
            end
        else -- Platform has a slope
            for _,w in ipairs(table.append(Player.get(),NPC.get())) do
                if (w.__type == "Player" and w:mem(0x48,FIELD_WORD) == data.block.idx) or (w.__type == "NPC" and w:mem(0x22,FIELD_WORD) == data.block.idx) then -- The object is standing on the slope
                    table.insert(objects,w)
                end
            end
        end
    end

    return objects
end

local function rotateTo(v,angle)
    local data = v.data

    local settings = v.data._settings

    -- Apply rotation to any objects on the platform
    local difference = (angle-data.rotation)

    for _,w in ipairs(getObjectsOnPlatform(v)) do
        local distance = getDistanceFromPivot(v,w) -- The distance between the pivot point and object

        if math.abs(angle) > 60 then -- yeet everything off
            w.speedX = (math.sign(distance.x)*-3)
            w.soeedY = -4
        else
            -- Keep track of the original position for later
            local originalPosition = vector(w.x,w.y)

            -- Rotate the object with the platform
            distance = distance:rotate(difference)

            w.x = v.x+v.speedX+(v.width*settings.pivot)-distance.x-(w.width/2)
            w.y = v.y+v.speedY                         -distance.y-(w.height )

            if w.__type == "NPC" then
                w.speedY = 0
            else
                --w:mem(0x146,FIELD_WORD,0)
            end

            -- If this new position would cause the object to collide with something
            local idList = Block.SOLID
            if w.__type == "Player" then
                idList = idList.. Block.PLAYERSOLID
            else
                idList = idList.. Block.PLAYER
            end

            if #Colliders.getColliding{a = w,b = idList,btype = Colliders.BLOCK} > 0 then
                -- Go back to the original position
                w.x = originalPosition.x-w.speedX
                w.y = originalPosition.y-w.speedY
            end
        end
    end

    data.rotation = angle
end


local function getBaseWeight(v,stopRecursion) -- Get the base weight of a player/NPC, meaning it doesn't take into account speed/position
    local weight = (v.width*v.height)/(32^2)

    if v.__type == "Player" then
        if v.mount > 0 then
            weight = weight*1.5
        end
        if v.isMega or v:mem(0x4A,FIELD_BOOL) then -- Mega or statue
            weight = weight*2
        end

        -- Holding an NPCs
        if not stopRecursion then
            if v.holdingNPC ~= nil then -- Holding an NPC
                weight = weight+getBaseWeight(v.holdingNPC,true)
            elseif v:mem(0xB8,FIELD_WORD) > 0 then -- NPC in yoshi's mouth
                weight = weight+getBaseWeight(NPC(v:mem(0xB8,FIELD_WORD)-1),true)
            elseif v:mem(0xBA,FIELD_WORD) > 0 then -- Player in yoshi's mouth
                weight = weight+getBaseWeight(Player(v:mem(0xBA,FIELD_WORD)),true)
            end
        end

        -- Ground pound logic
        local data = (seesaw.playerData[v] or {})

        if data.wasGroundPoundingLastFrame then
            weight = math.huge
        end
    elseif v.__type == "NPC" then
        local config = NPC.config[v.id]

        if config and config.isheavy then
            weight = weight*1.5
        end

        -- For any players standing on this NPC
        if not stopRecursion then
            for _,w in ipairs(Player.get()) do
                if w.standingNPC == v then
                    weight = weight+getBaseWeight(w,false)
                end
            end
        end

        -- Thwomp logic
        if seesaw.thwompIDMap[v.id] then
            local thwompData = v.data._basegame

            if thwompData.state == 1 or thwompData.state == 4 then
                weight = math.huge
            end
        end
    end

    return weight
end

local colBox = Colliders.Box(0,0,0,0)
local function getWeightOnPlatform(v)
    local data = v.data

    local settings = v.data._settings

    local totalWeight = 0 -- Negative weight means to the left, positive means to the right

    -- Take into account things on this platform
    for _,w in ipairs(getObjectsOnPlatform(v)) do
        local distanceFromPivot = getHorizontalDistanceFromPivot(v,w)
        local weight = getBaseWeight(w,false)

        weight = weight+(math.abs(distanceFromPivot)/32)
        weight = weight+(w.speedY/12) -- Add some speed stuff in

        totalWeight = totalWeight - (weight*math.sign(distanceFromPivot))
    end

    -- Skewer logic
    for _,w in ipairs(NPC.get(seesaw.skewerIDList)) do
        local skewerConfig = NPC.config[w.id]
        local skewerData = w.data._basegame

        -- If the skewer is going down
        if  (not w.isGenerator and not w.isHidden and w.despawnTimer > 0)
        and (not skewerConfig.horizontal and w.direction == DIR_RIGHT)
        and (not skewerData.extended and skewerData.time > skewerConfig.waitDelay and skewerData.hitcollider) then
            colBox.x,colBox.y = skewerData.hitcollider.x,skewerData.hitcollider.y
            colBox.width,colBox.height = skewerData.hitcollider.width,skewerData.hitcollider.height*2

            if (data.block and data.block.isValid) and colBox:collide(data.block) then
                local distanceFromPivot = getHorizontalDistanceFromPivot(v,w)

                totalWeight = -math.huge*distanceFromPivot
            end
        end
    end

    return totalWeight
end

local function applyGroundPoundLaunch(v,weight) -- Launch everything on the platform up
    local settings = v.data._settings

    for _,w in ipairs(getObjectsOnPlatform(v)) do
        local distanceFromPivot = getHorizontalDistanceFromPivot(v,w)

        if math.sign(distanceFromPivot) == math.sign(weight) then
            -- Reset slope for NPCs
            if w.__type == "NPC" then
                w:mem(0x22,FIELD_WORD,0)
            end

            w.speedY = -12
        end
    end
end


function seesaw.register(id)
    npcManager.registerEvent(id,seesaw,"onTickNPC")
    npcManager.registerEvent(id,seesaw,"onDrawNPC")
    
    table.insert(seesaw.idList,id)
    seesaw.idMap[id] = true
end


function seesaw.onInitAPI()
    registerEvent(seesaw,"onTick"   ,"onTickSemisolidSlope",true)
    registerEvent(seesaw,"onTickEnd","onTickSemisolidSlope",true)
    registerEvent(seesaw,"onDraw","onDrawSemisolidSlope")

    registerEvent(seesaw,"onTick")

    registerEvent(seesaw,"onPostNPCKill")
end


function seesaw.onTick()
    for _,v in ipairs(Player.get()) do
        seesaw.playerData[v] = seesaw.playerData[v] or {}


        local data = seesaw.playerData[v]

        data.wasGroundPoundingLastFrame = (data.isGroundPounding or false) -- Need to keep track of this because redigit, I guess

        data.isGroundPounding = (v:mem(0x5C,FIELD_BOOL) or warioIsGroundPounding(v) or broadswordIsSlamming(v))
    end
end


function seesaw.onPostNPCKill(v,reason)
    if not seesaw.idMap[v.id] then return end

    local data = v.data

    if data.block and data.block.isValid then
        data.block:delete()
    end
end


function seesaw.onTickNPC(v)
	if Defines.levelFreeze then return end
    
    local config = NPC.config[v.id]
    local data = v.data
    
    local lineguideData = v.data._basegame.lineguide
    
    local settings = v.data._settings

    -- Adjust the NPC's width, if necessary
    local newWidth = (config.width*settings.length)
    if math.ceil(v.width) ~= math.ceil(newWidth) then
        v.spawnX = v.spawnX+(v.spawnWidth/2)-(newWidth*settings.pivot)
        v.spawnWidth = newWidth

        v.x = v.x+(v.width/2)-(newWidth*settings.pivot)
        v.width = newWidth
        
        v.section = Section.getIdxFromCoords(v) or v.section -- Change section, if necessary

        -- Update lineguide "sensor" because it doesn't like changing sizes
        if lineguideData then
            lineguide.onStartNPC(v)
        end
    end
	
	if v.despawnTimer <= 0 then
        data.rotation = nil
        
        if data.block and data.block.isValid then
            data.block:delete()
        end

		return
	end

	if not data.rotation then
        data.rotation = 0
        
        data.rotationSpeed = 0 -- Used for weight-based platforms
        data.timer = 0 -- Used for self-rotating paltforms
    end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
    then return end

    -- Make platforms that have gone off of lineguides fall down
    if config.nogravity and lineguideData.state == lineguide.states.FALLING then
        local gravity = Defines.npc_grav
        local topSpeed = 8
        if v.underwater then
            gravity = gravity*0.2
            topSpeed = topSpeed*0.375
        end

        v.speedY = math.min(topSpeed,v.speedY + gravity)
    end
    
    if config.isWeightBased then
        -- Weight-based platform logic
        local totalWeight = getWeightOnPlatform(v)

        if math.abs(totalWeight) < 0.5 then
            data.rotationSpeed = (data.rotationSpeed-(data.rotation*0.0005))

            if math.abs(data.rotation) < 0.35 and math.abs(data.rotationSpeed) < 0.35 then
                data.rotationSpeed = 0
                rotateTo(v,0)
            elseif math.sign(data.rotationSpeed) ~= math.sign(data.rotation) then
                data.rotationSpeed = data.rotationSpeed*0.985
            end
        elseif math.abs(totalWeight) == math.huge then -- Ground pound
            applyGroundPoundLaunch(v,totalWeight)
            data.rotationSpeed = math.sign(totalWeight)*4
        else
            data.rotationSpeed = data.rotationSpeed+(math.min(math.abs(totalWeight)*0.0125,0.0175)*math.sign(totalWeight))
        end

        -- Bounce up if at an angle more than the max allowed angle
        if math.abs(data.rotation) > config.maxAngle and math.sign(data.rotationSpeed) == math.sign(data.rotation) then
            data.rotationSpeed = -data.rotationSpeed*0.25

            if math.abs(data.rotationSpeed) < 0.02 then
                data.rotationSpeed = 0
            end
        end

        rotateTo(v,data.rotation+data.rotationSpeed)

        --Text.print(math.floor(totalWeight),v.x-camera.x,v.y-camera.y)
    else
        -- Self-rotating platform logic
        local rotationSettings = settings.selfRotating

        data.timer = data.timer + 1

        rotateTo(v,(math.cos((data.timer/rotationSettings.speed)*(math.pi*2))*rotationSettings.amount)+rotationSettings.offset)
    end
	
	setupBlock(v)
end


local lowPriorityStates = table.map{1,3,4}

function seesaw.onDrawNPC(v)
    if v.despawnTimer <= 0 or v.isHidden then return end

    local config = NPC.config[v.id]
    local data = v.data

    local settings = v.data._settings
    local width = config.width*settings.length

    -- Get priority
    local priority = -55
    if lowPriorityStates[v:mem(0x138,FIELD_WORD)] then
        priority = -75
    elseif config.foreground then
        priority = -15
    end

    local frameOffset = v.animationFrame%(config.frames/4)

    if data.sprite == nil then -- Create sprite object if we don't already have one
        data.sprite = Sprite{texture = Graphics.sprites.npc[v.id].img,frames = config.frames}
    end

    data.sprite.rotation = (data.rotation or 0)

    -- Draw main platform
    for i=1,settings.length do
        local frame = frameOffset+1
        if i == settings.length then -- The end
            frame = frame + (config.frames*0.5)
        elseif i > 1 then -- The middle
            frame = frame + (config.frames*0.25)
        end

        data.sprite.pivot    = vector(-(i-(settings.length*settings.pivot))+1,0.5)
        data.sprite.texpivot = data.sprite.pivot

        data.sprite.position = vector(v.x+(v.width*settings.pivot)+config.gfxoffsetx,v.y+v.height-(config.gfxheight/2)+config.gfxoffsety)
        data.sprite:draw{frame = frame,priority = priority,sceneCoords = true}
    end

    -- Draw centre
    data.sprite.pivot    = Sprite.align.CENTRE
    data.sprite.texpivot = data.sprite.pivot
    
    data.sprite.position = vector(v.x+(v.width*settings.pivot)+config.gfxoffsetx,v.y+v.height-(config.gfxheight/2)+config.gfxoffsety)
    data.sprite:draw{frame = (config.frames*0.75)+frameOffset+1,priority = priority,sceneCoords = true}

    npcutils.hideNPC(v)

    if config.debug and (data.block and data.block.isValid) then
        Graphics.drawBox{x = v.x,y = v.y,width = v.width,height = v.height,color = Color.red.. 0.1,sceneCoords = true}
        
        local vertexCoords

        local w = data.block

        local blockConfig = Block.config[w.id]
        local width,height = math.max(4,w.width),math.max(4,w.height)

        if blockConfig.floorslope < 0 then
            vertexCoords = {w.x,w.y+height,w.x+width,w.y+height,w.x+width,w.y}
        elseif blockConfig.floorslope > 0 then
            vertexCoords = {w.x+width,w.y+height,w.x,w.y+height,w.x,w.y}
        else
            vertexCoords = {w.x,w.y,w.x+width,w.y,w.x,w.y+height,w.x+width,w.y,w.x,w.y+height,w.x+width,w.y+height}
        end

        Graphics.glDraw{vertexCoords = vertexCoords,color = Color.green.. 0.35,sceneCoords = true}
    end
end



-- This is the annoying bit that can "de-jank-ify" semisolid slopes.....
-- "A slope is a slope. You can't say it's semisolid." Well, Andrew """REDIGIT""" Spinks...
do
    local function objectHasCollision(v) -- Get whether a player/NPC has collision. Obviously not perfect, but I guess it does the job
        if v.__type == "Player" then
            return (v.forcedState == 0 and v.deathTimer == 0 and not v:mem(0x13C,FIELD_BOOL))
        elseif v.__type == "NPC" then
            local config = NPC.config[v.id]
            return ((v.despawnTimer > 0 and not v.isGenerator and not v.isHidden) and not v.noblockcollision and (not config or not config.noblockcollision) and v:mem(0x12C,FIELD_WORD) == 0 and v:mem(0x138,FIELD_WORD) == 0)
        end
    end
    local function getObjectGravity(v) -- Get the player/NPC's gravity
        local gravity = 0

        if v.__type == "Player" then
            gravity = Defines.player_grav

            if v:mem(0x36,FIELD_BOOL) then
                gravity = gravity*0.1
            end
        elseif v.__type == "NPC" then
            local config = NPC.config[v.id]
            gravity = Defines.npc_grav

            if config and config.nogravity then
                gravity = 0
            elseif v.underwater and (not config or not config.nowaterphysics) then
                gravity = gravity*0.2
            end
        end

        return gravity
    end

    local function getEjectionPosition(v,w) -- Find where the object (w) should be ejected to when interacting with a slope (v).
        local slopeDirection = Block.config[v.id].floorslope

        local blockSide  = (v.x+(v.width/2))+((v.width/2)*slopeDirection)
        local objectSide = (w.x+(w.width/2))-((w.width/2)*slopeDirection)
        
        return (v.y+v.height)-(math.clamp(((blockSide-objectSide)*slopeDirection)/v.width,0,1)*v.height) -- Where the object should be ejected to
    end
    local function solidBlockFilter(v) -- Used for fixing cliffturn NPCs on semisolid slopes
        if Block.SEMISOLID_MAP[v.id] and (Block.SLOPE_LR_FLOOR_MAP[v.id] or Block.SLOPE_RL_FLOOR_MAP[v.id]) then -- Semisolid slopes
            return ((not v.layerObj or not v.layerObj.isHidden) and not v:mem(0x5A,FIELD_BOOL))
        elseif Block.SOLID_MAP[v.id] or Block.PLAYER_MAP[v.id] or Block.SEMISOLID_MAP[v.id] then -- Solid blocks
            return (not v.isHidden and not v:mem(0x5A,FIELD_BOOL))
        else
            return false
        end            
    end

    
    local colBox = Colliders.Box(0,0,0,0)

    local function playerSemisolidSlopeLogic(v,w)
        colBox.x,colBox.y = w.x+w.speedX,w.y+w.height-1
        colBox.width,colBox.height = w.width,1

        local ejectPosition = getEjectionPosition(v,w)

        if ((w.speedY > -getObjectGravity(w) or w.mount == 1) and w.y+w.height+(w.speedY*2)-3 > ejectPosition) and w:mem(0x48,FIELD_WORD) == 0 and colBox:collide(v) then
            v.isHidden = true -- Prevent the player from clipping to the top of the slope
        end
    end
    local function npcSemisolidSlopeLogic(v,w)
        colBox.x,colBox.y = w.x+w.speedX,w.y+w.speedY+w.height-1
        colBox.width,colBox.height = w.width,1

        if w.speedY > -getObjectGravity(w) and colBox:collide(v) then
            local ejectPosition = getEjectionPosition(v,w)

            if w.y+w.height-(w.speedY*2)-3 < ejectPosition then -- If the NPC should be standing on this slope
                -- Make the NPC think they're on this slope
                w.y = ejectPosition-w.height

                w.speedY = -getObjectGravity(w)

                w.collidesBlockBottom = true
                w:mem(0x22,FIELD_WORD,v.idx)
                
                -- Fix cliffturn NPCs
                local npcConfig = NPC.config[w.id]

                if (npcConfig and npcConfig.cliffturn) and not w:mem(0x136,FIELD_BOOL) then
                    -- Recreation of redigit's cliffturn logic for slopes, kind of
                    colBox.width,colBox.height = 16,32

                    colBox.x = (w.x+(w.width/2))+(((w.width/2)+4)*w.direction)-(colBox.width*((w.direction+1)*0.5))
                    colBox.y = (w.y+w.height-8)

                    if #Colliders.getColliding{a = colBox,btype = Colliders.BLOCK,filter = solidBlockFilter} == 0 then
                        w:mem(0x120,FIELD_BOOL,true)
                    end
                end
            end
        end
    end

    local function playerBuriedSlopeLogic(v,w)
        colBox.x,colBox.y = w.x+(w.speedX*2),w.y+w.height-1
        colBox.width,colBox.height = w.width,1

        if not w:isGroundTouching() then -- If in the air
            colBox.y = colBox.y+w.speedY
        end

        v.isHidden = ((w:mem(0x146,FIELD_WORD) > 1 or (w.speedY == 0 and w:mem(0x48,FIELD_WORD) == 0)) and not colBox:collide(v)) -- If standing on a normal block and not touching this slope
    end


    function seesaw.onTickSemisolidSlope()
        if not seesaw.enableSemisolidSlopeFix then return end

        for _,v in ipairs(Block.get()) do
            if (Block.SLOPE_LR_FLOOR_MAP[v.id] or Block.SLOPE_RL_FLOOR_MAP[v.id]) then -- If this is a slope
                if not v.layerObj or not v.layerObj.isHidden then -- If the layer is hidden
                    local config = Block.config[v.id]
                    
                    local x1,y1,x2,y2 = (v.x-8),(v.y-8),(v.x+v.width+16),(v.y+v.height+16)
                    
                    -- Handle players
                    for _,w in ipairs(Player.getIntersecting(x1,y1,x2,y2)) do
                        if objectHasCollision(w) then
                            playerBuriedSlopeLogic(v,w)

                            if Block.SEMISOLID_MAP[v.id] then
                                playerSemisolidSlopeLogic(v,w)
                            end                            
                        end
                    end
                    -- Handle NPCs
                    for _,w in ipairs(NPC.getIntersecting(x1,y1,x2,y2)) do
                        if objectHasCollision(w) and Block.SEMISOLID_MAP[v.id] then
                            npcSemisolidSlopeLogic(v,w)
                        end
                    end
                else -- If the layer is hidden, we can end here
                    v.isHidden = true
                end
            end
        end
    end

    function seesaw.onDrawSemisolidSlope()
        if not seesaw.enableSemisolidSlopeFix then return end

        for _,v in ipairs(Block.get()) do
            if (Block.SLOPE_LR_FLOOR_MAP[v.id] or Block.SLOPE_RL_FLOOR_MAP[v.id]) then -- If this is a slope
                v.isHidden = (v.layerObj and v.layerObj.isHidden) -- Incase this block was forced to be hidden by a player falling through it
            end
        end
    end
end



return seesaw