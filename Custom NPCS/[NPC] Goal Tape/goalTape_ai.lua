--[[

	Written by MrDoubleA
    Please give credit!
    
    Credit to Novarender for vastly improving the font used for character names

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")

local megashroom = require("npcs/ai/megashroom")
local starman = require("npcs/ai/starman")

local playerManager = require("playerManager")
local textplus = require("textplus")

local goalTape = {}

goalTape.idList = {}
goalTape.idMap = {}

goalTape.playerInfo = {}


local COLLISION_TYPE_TOUCH        = 0 -- (SMM)  Needs to touch the actual NPC to trigger the level exit.
local COLLISION_TYPE_TOUCH_REGION = 1 -- (SMM2) Needs to touch its "patrolling" region to trigger the level exit.
local COLLISION_TYPE_TOUCH_ABOVE  = 2 -- (SMW)  Needs to touch anywhere above the bottom of the "patrolling" region to trigger the level exit.

local STATE_RAISING  = 0
local STATE_LOWERING = 1

local LEVEL_BEAT_CODE_ADDR = 0x00B2C5D4

local colBox = Colliders.Box(0,0,0,0)

local buffer = Graphics.CaptureBuffer(800,600)

local irisShader = Shader()
irisShader:compileFromFile(nil, Misc.resolveFile("goalTape_irisOut.frag"))

local collisionTypes = {
    [COLLISION_TYPE_TOUCH]        = (function(v,w,data) return Colliders.collide(v,w) end),
    [COLLISION_TYPE_TOUCH_REGION] = (function(v,w,data)
        colBox.x,colBox.y,colBox.width,colBox.height = v.x,data.top,v.width,data.bottom-data.top
        return Colliders.collide(colBox,w)
    end),
    [COLLISION_TYPE_TOUCH_ABOVE]  = (function(v,w,data)
        colBox.x,colBox.y,colBox.width,colBox.height = v.x,Section(v.section).boundary.top,v.width,data.bottom-Section(v.section).boundary.top
        return Colliders.collide(colBox,w)
    end),
}

--local exitTypes = {[0] = 1,[1] = 2,[2] = 3,[3] = 4,[4] = 6,[5] = 7} -- From extra settings field to win state

goalTape.powerupNPCIDs = {
	[1] = {},
	[2] = {185,9,185,249},
	[3] = {183,14,182},
	[4] = {34},
	[5] = {160},
	[6] = {170},
	[7] = {264},

	extraLife = 187,

	starman = 293,
	mega = 425,
}

goalTape.text = {
    results = {
        font = textplus.loadFont("goalTape_resultsFont.ini"),
        xscale = 2,yscale = 2,

        courseClear = "COURSE CLEAR!",
        timeCountdown = "@%d*%d=%d", -- The first "%d" is replaced by the amount of time, the second is replaced by the time multiplier, and the third is replaced by the score. @ is the clock in the default font used for the results.
    },

    characterNames = {
        font = textplus.loadFont("goalTape_nameFont.ini"),
        xscale = 2,yscale = 2,

        useCostumeName = false, -- When enabled, the name of the player's costume will be used if they're using one.

        [CHARACTER_MARIO          ] = {name = "MARIO"           ,color = Color.fromHexRGBA(0xD83818FF)}, -- Red
        [CHARACTER_LUIGI          ] = {name = "LUIGI"           ,color = Color.fromHexRGBA(0x58F858FF)}, -- Green
        [CHARACTER_PEACH          ] = {name = "PEACH"           ,color = Color.fromHexRGBA(0xF85858FF)}, -- Pink-ish
        [CHARACTER_TOAD           ] = {name = "TOAD"            ,color = Color.fromHexRGBA(0xD83818FF)}, -- Red
        [CHARACTER_LINK           ] = {name = "LINK"            ,color = Color.fromHexRGBA(0x58F858FF)}, -- Green
        [CHARACTER_MEGAMAN        ] = {name = "MEGAMAN"         ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
        [CHARACTER_WARIO          ] = {name = "WARIO"           ,color = Color.fromHexRGBA(0xF8D870FF)}, -- Yellow
        [CHARACTER_BOWSER         ] = {name = "BOWSER"          ,color = Color.fromHexRGBA(0x58F858FF)}, -- Green
        [CHARACTER_KLONOA         ] = {name = "KLONOA"          ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
        [CHARACTER_NINJABOMBERMAN ] = {name = "NINJA BOMBERMAN" ,color = Color.fromHexRGBA(0xF85858FF)}, -- Pink-ish
        [CHARACTER_ROSALINA       ] = {name = "ROSALINA"        ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
        [CHARACTER_SNAKE          ] = {name = "SNAKE"           ,color = Color.fromHexRGBA(0x58F858FF)}, -- Green
        [CHARACTER_ZELDA          ] = {name = "ZELDA"           ,color = Color.fromHexRGBA(0xF8D870FF)}, -- Yellow
        [CHARACTER_ULTIMATERINKA  ] = {name = "ULTIMATE RINKA"  ,color = Color.fromHexRGBA(0xD8A038FF)}, -- Gold
        [CHARACTER_UNCLEBROADSWORD] = {name = "UNCLE BROADSWORD",color = Color.fromHexRGBA(0xD8A038FF)}, -- Gold
        [CHARACTER_SAMUS          ] = {name = "SAMUS"           ,color = Color.fromHexRGBA(0xD8A038FF)}, -- Gold
        
        -- A2XT names
        --[CHARACTER_MARIO          ] = {name = "DEMO"            ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
        --[CHARACTER_LUIGI          ] = {name = "IRIS"            ,color = Color.fromHexRGBA(0x58F858FF)}, -- Green
        --[CHARACTER_PEACH          ] = {name = "KOOD"            ,color = Color.fromHexRGBA(0xD8A038FF)}, -- Gold
        --[CHARACTER_TOAD           ] = {name = "RAOCOW"          ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
        --[CHARACTER_LINK           ] = {name = "SHEATH"          ,color = Color.fromHexRGBA(0x58A8F0FF)}, -- Blue
    },
}

local textLayoutCache = {}
local function getTextLayout(text,font,xscale,yscale)
    textLayoutCache[text]                       = textLayoutCache[text]                       or {}
    textLayoutCache[text][font]                 = textLayoutCache[text][font]                 or {}
    textLayoutCache[text][font][xscale]         = textLayoutCache[text][font][xscale]         or {}
    textLayoutCache[text][font][xscale][yscale] = textLayoutCache[text][font][xscale][yscale] or textplus.layout(textplus.parse(text,{font = font,xscale = xscale,yscale = yscale}))

    return textLayoutCache[text][font][xscale][yscale]
end

local function stopSounds(info)
    if info.mainSound then
        info.mainSound:stop()
    end
    if info.irisOutSound then
        info.irisOutSound:stop()
    end

    if info.countdownStartSound then
        info.countdownStartSound:stop()
    end
    if info.countdownLoopSound then
        info.countdownLoopSound:stop()
    end
    if info.countdownEndSound then
        info.countdownEndSound:stop()
    end
end

local function resetPlayerInfo(k)
    local info = goalTape.playerInfo[k]

    if info then
        Defines.player_walkspeed = nil
        Defines.player_runspeed = nil

        stopSounds(info)

        Audio.MusicVolume(info.priorMusicVolume)
        Timer.hurryTime = info.priorHurryTime

        --[[if info.originalSection and info.originalMusic then
            Audio.MusicChange(info.originalSection,info.originalMusic)
        end]]

        goalTape.playerInfo[k] = nil
    end
end

function goalTape.register(id)
    npcManager.registerEvent(id,goalTape,"onTickNPC")

    table.insert(goalTape.idList,id)
    goalTape.idMap[id] = true
end

function goalTape.onInitAPI()
    registerEvent(goalTape,"onTick")
    registerEvent(goalTape,"onTickEnd")
    registerEvent(goalTape,"onCameraUpdate")
    registerEvent(goalTape,"onDraw")

    registerEvent(goalTape,"onReset") -- rooms.lua support
end

function goalTape.onTick()
    for k,v in ipairs(Player.get()) do
        local info = goalTape.playerInfo[k]

        if info then
            local config = NPC.config[info.id]

            if v.deathTimer == 0 and not v:mem(0x13C,FIELD_BOOL) then -- If the player is alive
                info.timer = info.timer + 1

                -- Disable player input
                for w,_ in pairs(v.keys) do
                    v.keys[w] = false
                end


                if info.timer > 464 and info.timer < 560 then
                    v.speedX = 0
                elseif info.timer == 560 then
                    if config.doIrisOut then
                        info.irisOutSound = SFX.play(config.irisOutSFX)
                    end

                    info.irisOutRadius = math.max(camera.width,camera.height)
                    info.savedCameraPos = {camera.x,camera.y}
                else
                    if info.irisOutRadius then
                        info.irisOutRadius = math.max(0,info.irisOutRadius - 10)

                        if info.irisOutRadius < 2 then
                            -- Exit level
                            mem(LEVEL_BEAT_CODE_ADDR,FIELD_WORD,info.exitType)
                            Level.exit()

                            Checkpoint.reset()

                            Audio.MusicVolume(info.priorMusicVolume)
                        end

                        Defines.player_walkspeed = nil
                        Defines.player_runspeed = nil
                    else
                        if playerManager.getBaseID(v.character) == CHARACTER_LINK then
                            Defines.player_runspeed = 1.5
                        else
                            Defines.player_walkspeed = 1.5
                        end
                    end

                    if not info.stopBehind or ((info.direction == DIR_RIGHT and (v.x+(v.width/2)) < info.startX+160) or (info.direction == DIR_LEFT and (v.x+(v.width/2)) > info.startX-160)) then
                        if info.direction == DIR_LEFT then
                            v.keys.left = KEYS_DOWN
                        elseif info.direction == DIR_RIGHT then
                            v.keys.right = KEYS_DOWN
                        end
                    else
                        v.direction = -info.direction
                        v.speedX = 0
                    end
                end

                -- Timer countdown
                if config.doTimerCountdown and info.timer > 224 and Timer.isActive() then
                    Timer.hurryTime = -1

                    local speed = math.ceil(info.timerStart/config.timerCountdownSpeed)
                    local score = (config.timerScoreMultiplier*math.min(speed,Timer.getValue()))

                    SaveData._basegame.hud.score = SaveData._basegame.hud.score + score
                    info.timerScore = info.timerScore + score

                    Timer.set(math.max(0,Timer.getValue()-speed))

                    -- Sound effect logic
                    if config.countdownStartSFX and config.countdownLoopSFX and config.countdownEndSFX then
                        if not info.countdownStartSound then
                            info.countdownStartSound = SFX.play{sound = config.countdownStartSFX}
                        elseif not info.countdownStartSound:isPlaying() and not info.countdownLoopSound then
                            info.countdownLoopSound = SFX.play{sound = config.countdownLoopSFX,loops = 0}
                        elseif info.countdownLoopSound and not info.countdownEndSound and Timer.getValue() == 0 then
                            info.countdownLoopSound:stop()
                            info.countdownEndSound = SFX.play{sound = config.countdownEndSFX}
                        end
                    end
                end

                -- Darken
                if config.doDarken and info.timer > 464 then
                    info.darkness = math.max(0,info.darkness - 0.006)
                elseif config.doDarken then
                    info.darkness = math.min(1,info.darkness + 0.0075)
                end
            else -- if the player is dead
                stopSounds(info)
            end
        end
    end
end

function goalTape.onTickEnd()
    for k,v in ipairs(Player.get()) do
        local info = goalTape.playerInfo[k]

        if info
        and v.deathTimer == 0 and not v:mem(0x13C,FIELD_BOOL)
        and info.timer > 464
        and v.speedX == 0 and (v:isGroundTouching() or v.mount == 2)
        then
            local config = NPC.config[info.id]

            if (v.mount ~= 3 and config.victoryPose) then
                v.frame = config.victoryPose
            elseif (v.mount == 3 and config.victoryPoseOnYoshi) then
                v.frame = config.victoryPoseOnYoshi
            end
        end
    end
end

function goalTape.onCameraUpdate()
    for k,v in ipairs(Player.get()) do
        local info = goalTape.playerInfo[k]

        if info and info.savedCameraPos then
            camera.x = info.savedCameraPos[1]
            camera.y = info.savedCameraPos[2]
        end
    end
end

function goalTape.onDraw()
    for k,v in ipairs(Player.get()) do
        local info = goalTape.playerInfo[k]

        if info then
            local config = NPC.config[info.id]

            if info.darkness > 0 then
                Graphics.drawBox{x=0,y=0,width=camera.width,height=camera.height,color=Color.black.. info.darkness,priority = -7}
                v:render{color=Color.white.. info.darkness,priority = -6}
            end
            if info.irisOutRadius and config.doIrisOut then
                local center = vector((v.x+(v.width/2))-camera.x,(v.y+(v.height/2))-camera.y)

                if v.mount == 2 then
                    center.y = (v.y-camera.y)
                end

                buffer:captureAt(6)

                Graphics.drawBox{
                    texture = buffer,x = 0,y = 0,
                    width = buffer.width,height = buffer.height,
                    priority = 6,shader = irisShader,
                    uniforms = {
                        radius = info.irisOutRadius,
                        center = center,
                    },
                }
            end

            if info.timer > 160 then
                local y = 160

                if goalTape.text.characterNames and config.displayCharacterName then
                    local color = Color.white
                    local text = "PLAYER"
                    
                    if goalTape.text.characterNames.useCostumeName and Player.getCostume(v.character) ~= nil then
                        color = goalTape.text.characterNames[v.character].color or color
                        text = Player.getCostume(v.character)
                    elseif goalTape.text.characterNames[v.character] then
                        color = goalTape.text.characterNames[v.character].color or color
                        text = goalTape.text.characterNames[v.character].name or text
                    end

                    local layout = getTextLayout(text,goalTape.text.characterNames.font,goalTape.text.characterNames.xscale,goalTape.text.characterNames.yscale)

                    textplus.render{
                        layout = layout,color = color,priority = 5,
                        x = (camera.width/2)-(layout.width/2),y = y,
                    }

                    y = y + layout.height + (8*(goalTape.text.characterNames.yscale or 1))
                end

                if goalTape.text.results and goalTape.text.results.courseClear and config.displayCourseClear then
                    local layout = getTextLayout(goalTape.text.results.courseClear,goalTape.text.results.font,goalTape.text.results.xscale,goalTape.text.results.yscale)

                    textplus.render{
                        layout = layout,color = color,priority = 5,
                        x = (camera.width/2)-(layout.width/2),y = y,
                    }

                    y = y + layout.height + (16*(goalTape.text.characterNames.yscale or 1))
                end
                if goalTape.text.results and goalTape.text.results.timeCountdown and (config.doTimerCountdown and Timer.isActive()) then
                    local layout = getTextLayout(goalTape.text.results.timeCountdown:format(info.timerStart,config.timerScoreMultiplier,info.timerScore),goalTape.text.results.font,goalTape.text.results.xscale,goalTape.text.results.yscale)

                    textplus.render{
                        layout = layout,color = color,priority = 5,
                        x = (camera.width/2)-(layout.width/2),y = y,
                    }
                end
            end
        end
    end
end

function goalTape.onReset(fromRespawn) -- rooms.lua support
	if fromRespawn then
		for k,v in ipairs(Player.get()) do
			resetPlayerInfo(k)
		end
	end
end

function goalTape.onTickNPC(v)
	if Defines.levelFreeze then return end
    
    local config = NPC.config[v.id]
    local data = v.data
    
    local settings = v.data._settings
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.state = nil
		return
	end

	if not data.state then
        data.state = STATE_LOWERING
        
        data.top = (v.y+v.height)

        -- Get position of bottom. Goes down in intervals of 8 and will stop upon reaching the bottom of the section.
        for y=(v.y+v.height),Section(v.section).boundary.bottom,8 do
            colBox.x,colBox.y = v.x,y-8
            colBox.width,colBox.height = v.width,8

            for _,w in ipairs(Colliders.getColliding{
                a = colBox,
                b = Block.SOLID.. Block.SEMISOLID.. Block.PLAYER.. Block.SLOPE,
                btype = Colliders.BLOCK,
            }) do
                data.bottom = w.y
                break
            end

            if data.bottom then break end -- Stop if a block was hit
        end
        data.bottom = data.bottom or Section(v.section).boundary.bottom
    end
    
    --[[if data.stopBehind == nil then
        data.stopBehind = v.friendly
        v.friendly = true
    end]]

    v.friendly = true

    -- Move with layers
    if not Layer.isPaused() and v.layerObj then
        v.x = v.x + v.layerObj.speedX
        v.y = v.y + v.layerObj.speedY

        data.top    = data.top    + v.layerObj.speedY
        data.bottom = data.bottom + v.layerObj.speedY
    end

	if v:mem(0x12C, FIELD_WORD) > 0    --Grabbed
	or v:mem(0x136, FIELD_BOOL)        --Thrown
	or v:mem(0x138, FIELD_WORD) > 0    --Contained within
	then return end
	
    if data.state == STATE_RAISING then
        v.speedY = -config.movementSpeed

        if (v.y+v.height) <= data.top then
            data.state = STATE_LOWERING
        end
    elseif data.state == STATE_LOWERING then
        v.speedY = config.movementSpeed

        if (v.y+v.height) >= data.bottom then
            data.state = STATE_RAISING
        end
    end

    for k,w in ipairs(Player.get()) do
        if (w.forcedState == 0 and w.deathTimer == 0 and not w:mem(0x13C,FIELD_BOOL)) and (collisionTypes[config.requiredCollisionType] and collisionTypes[config.requiredCollisionType](v,w,data)) then
            if Level.winState() == 0 then
				if w.holdingNPC and config.heldNPCsTransform then-- If the player is holding an NPC, transform it into a something else
					-- Determine the ID that it should be transformed into (this should be fairly accurate to the original)
                    local id
                    if table.ifind(goalTape.powerupNPCIDs[w.powerup],w.reservePowerup) then -- If the player has their current powerup in the reserve box, give an extra life
						id = goalTape.powerupNPCIDs.extraLife or 90
					elseif #goalTape.powerupNPCIDs[w.powerup] > 0 then -- Give the player another of their current powerup, if we have one
						id = goalTape.powerupNPCIDs[w.powerup][1]
					else -- Otherwise, give them a mushroom
						id = goalTape.powerupNPCIDs[2][1] or 9
                    end

                    if id then
                        local e = Effect.spawn(10,0,0)
                        e.x,e.y = (w.holdingNPC.x+(w.holdingNPC.width/2)-(e.width/2)),(w.holdingNPC.y+(w.holdingNPC.height/2)-(e.height/2))

                        SFX.play(34)

						w.holdingNPC:transform(id,true,false)

                        w.holdingNPC.direction = v.direction
                        w.holdingNPC.dontMove = true

                        if not settings.stopBehind then
                            w.holdingNPC.speedX = v.direction*(math.abs(w.speedX)*0.7)
                        else
                            w.holdingNPC.speedX = v.direction*2
                        end
                        w.holdingNPC.speedY = -10

                        -- Reset a bunch of different NPC values related to being grabbed
                        w.holdingNPC:mem(0x12C,FIELD_WORD,0)
                        --w.holdingNPC:mem(0x12E,FIELD_WORD,0)
                        --w.holdingNPC:mem(0x130,FIELD_WORD,0)
                        --w.holdingNPC:mem(0x132,FIELD_WORD,0)
                        w.holdingNPC:mem(0x134,FIELD_WORD,0)
                        w.holdingNPC:mem(0x136,FIELD_BOOL,true)

                        w:mem(0x154,FIELD_WORD,0)
                    end
                end

                local e = Effect.spawn(10,0,0)
                e.x,e.y = (v.x+(v.width/2)-(e.width/2)),(v.y+(v.height/2)-(e.height/2))

                megashroom.StopMega(w,true)
                starman.stop(w)

                goalTape.playerInfo[k] = {
                    id = v.id,direction = v.direction,
                    stopBehind = settings.stopBehind or false,
                    timer = 0,darkness = 0,
                    mainSound = SFX.play(config.mainSFX),
                    startX = (v.x+(v.width/2)),
                    exitType = settings.exitType or 7,

                    -- Cleanup stuff
                    priorMusicVolume = Audio.MusicVolume(),
                    priorHurryTime = Timer.hurryTime,

                    timerStart = Timer.getValue(),timerScore = 0,
                }

                Audio.MusicVolume(0)

                Level.winState(4096)

                -- boring thing to "remove" other players, replicated from the source code
                for _,p in ipairs(Player.get()) do
                    if p.idx ~= w.idx then
                        p.section = w.section
                        p.x = (w.x+(w.width/2)-(p.width/2))
                        p.y = (w.y+w.height-p.height)
                        p.speedX,p.speedY = 0,0
                        p.forcedState,p.forcedTimer = 8,-w.idx
                    end
                end
            end

            v.friendly = false -- Needs to not be friendly to be able to turn into a coin

            Misc.npcToCoins()
            v:kill(HARM_TYPE_OFFSCREEN)

            break
        end
    end
end

return goalTape