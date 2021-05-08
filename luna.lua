local hudoverride = require("hudoverride")
local autoscroll = require("autoscroll")
local antiZip = require("antizip")
--local antiZipP2 = require("antizipP2")
goalcads = require("goalcards")
local extendedKoopas = require("extendedKoopas")
local inventory = require("customInventory")
local camDir = true
local starCoinTotal = SaveData._basegame.starcoinCounter
local map = require("map")
local sec0 = Section(0)
local raiseWater = false
local Block1X = -1
local Block2X = -1
local random1 = -1
local randomizeBoxesSpeed = 3
local random2 = -1
local Block1Y = -1
local Block2Y = -1
local movingLayerCounter = 0
local movingLayerDir = 1
local waterMove = 0
local waterDir = 1
local randomizeBoxes = false
local randomizeBoxesCount = 5
local hitSound = SFX.open("block-hit.ogg")
local cameraOffset = 0
local waterHeight = 0
local sectionBounds = sec0.boundary
local anotherPowerDownLibrary = require("anotherPowerDownLibrary")
local counter = 3
local usePBar = true;
local camlock = require("camlock")
local pbarCount = 0;
local randomizeBoxesStep = 1
local reduceTimer = 6;
local lastpowerup = 0;
local stampCollect = Misc.resolveSoundFile("starcoin-collect")
local pwingSound = SFX.open("smb3overhaul/pmeter.wav");
local pwingsnd = SFX.create{x=0,y=0,falloffRadius=128,sound="smb3overhaul/pmeter.wav"}
local upsnd = SFX.open("1up.ogg");
local textplus = require("textplus")
local yFont = textplus.loadFont("HUDCard/1.ini")
local starCoinEmptyicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/starCoinEmpty.png"))
local starCoinFullicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/starCoinFull.png"))
local emptyStamp = Graphics.loadImage(Misc.resolveFile("smb3overhaul/emptyStamp.png"))
local fullStamp = Graphics.loadImage(Misc.resolveFile("smb3overhaul/fullStamp.png"))
local lifeicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/lifecounter.png"))
local coinicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/coincounter.png"))
local timeicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/ui.png"))
local powerbar = Graphics.loadImage(Misc.resolveFile("smb3overhaul/pbar.png"))
local powerbaricon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/pbar_active.png"))
local powerbararrow = Graphics.loadImage(Misc.resolveFile("smb3overhaul/pbar_arrow.png"))
local targetPlayer = {}
local StarCoinCount = 0
local pwingsndp = nil
local starcoin
local won = true
local gotStamp = false
local camOffset = 0
local CamOffDir = 1
local teleToSecret = false
local downTimer = 300
local playerHit = false
local uibox = Graphics.loadImage(Misc.resolveFile("smb3overhaul/back.png"))
function tableContains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end
local levelEnterfilename = Level.filename()
if not SaveData.stamps then
    SaveData.stamps = {}
end
if not SaveData.bonusCount then
    SaveData.bonusCount = 0
end
if not SaveData.stamps[levelEnterfilename] then
    SaveData.stamps[levelEnterfilename] = {}
end
function onStart()
    Timer.activate(300)
    Defines.player_runspeed	= 7
    starcoin = require("npcs/ai/starcoin")
    StarCoinCount = tablelength(NPC.get(310))
    --[[for i=0, Section.count()-1 do
        local sec = Section(i)
        local sectionBounds = sec0.boundary
        sectionBounds.bottom = sectionBounds.bottom+64
        sec.boundary = sectionBounds
    end--]]
    Graphics.activateHud(true)
    --camera.width = 256*2
    --camera.height = 224*2
    targetPlayer = {Player.get()}
    hudoverride.visible.itembox = false
    -- Disable grabbing NPC's. There's some 'Defines' values for this.
    --Defines.player_grabSideEnabled = true
    --Defines.player_grabTopEnabled = true
    --Defines.player_grabShellEnabled = true
    Defines.smb3RouletteScoreValueFlower = 2
    Defines.smb3RouletteScoreValueStar = 2
    Defines.smb3RouletteScoreValueMushroom = 2
    if tablelength(NPC.get(990)) > 0 and SaveData.stamps[levelEnterfilename][1] == nil then
        SaveData.stamps[levelEnterfilename][1] = false
    end
    if SaveData.stamps[levelEnterfilename][1] == true then
        gotStamp = true
    end
    if tablelength(NPC.get(990)) > 0 and gotStamp == true then
        local npcc = NPC.get(990)[1]
        npcc:transform(989)
    end
    --sectionBounds.bottom = sectionBounds.bottom + 48
    --camera1.bounds = sectionBounds
    --camera2.bounds = sectionBounds
end
function onLoadSection(playerIdx)
    movingLayerCounter = 256
    movingLayerDir = 1
    if tablelength(NPC.get(990)) > 0 and gotStamp == true then
        local npcc = NPC.get(990)[1]
        npcc:transform(989)
    end
    if player == nil then return end
    local npcs = NPC.get(993)
    if tablelength(npcs) > 0 then
        for i=1,tablelength(npcs) do
            if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) > -1 then
                if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) == player.section then
                    raiseWater = true
                    break
                else
                    raiseWater = false
                end
            end
        end
    else
        local npcs = Block.get(987)
        if tablelength(npcs) > 0 then
            for i=1,tablelength(npcs) do
                if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) > -1 then
                    if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) == player.section then
                        raiseWater = true
                        break
                    else
                        raiseWater = false
                    end
                end
            end
        else
            raiseWater = false
        end
    end
    local npcs = NPC.get(75)
    if tablelength(npcs) > 0 then
        for i=1,tablelength(npcs) do
            if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) > -1 then
                if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) == player.section then
                    Text.showMessageBox(npcs[i].msg)
                    if tablelength(Block.get(749)) > 0 then 
                        randomizeBoxes = true
                        randomizeBoxesCount = 5
                    end
                end
            end
        end
    end
    local npcs = NPC.get(94)
    if tablelength(npcs) > 0 then
        for i=1,tablelength(npcs) do
            if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) > -1 then
                if Section.getIdxFromCoords(npcs[i].x, npcs[i].y, 32, 32) == player.section then
                    Text.showMessageBox(npcs[i].msg)
                    if tablelength(Block.get(749)) > 0 then 
                        randomizeBoxes = true
                        randomizeBoxesCount = 5
                    end
                end
            end
        end
    end
    if tablelength(Block.get(998)) > 0 then
        for i=1, tablelength(Block.get(998)) do
            if playerIdx == 1 then
                camlock.addZone(Block.get(998)[i].x-(camera.width)+64, Block.get(998)[i].y-(camera.height)+64, (camera.width), (camera.height))
            end
            if playerIdx == 2 then
                camlock.addZone(Block.get(998)[i].x-(camera.width)+64, Block.get(998)[i].y-(camera.height)+64, (camera2.width), (camera2.height))
            end
        end
    end
    players = {player}
    if tablelength(Block.get(999)) > 0 then
        autoscroll.unlockSection()
        if Block.get(999)[1].x <= players[playerIdx].x then
            for i=1,1 do
                for p=1,tablelength(Player.get()) do
                    if Section.getIdxFromCoords(Block.get(999)[1].x, Block.get(999)[1].y, 16, 16) == Player.get()[p].section then
                        autoscroll.scrollRight(0.984615384615385)
                    end
                end
            end
        end
    end
    players = {player}
    if tablelength(Block.get(993)) > 0 then
        local movelayer = Layer.get("upDown")
        movelayer.speedY = 0
        if Block.get(993)[1].x <= players[playerIdx].x then
            for i=1,1 do
                for p=1,tablelength(Player.get()) do
                    if Section.getIdxFromCoords(Block.get(993)[1].x, Block.get(993)[1].y, 16, 16) == Player.get()[p].section then
                        movelayer.speedY = 3
                    end
                end
            end
        end
    end
    local npcs = NPC.get(996)
    if tablelength(npcs) > 0 then
        for i=1, tablelength(npcs) do
            npcs[i]:transform(995)
        end
    end
    
    if tablelength(NPC.get(995)) > 0 then
        for i=1, tablelength(NPC.get(995)) do
            NPC.get(995)[i].isHidden = true
        end
    end
    if tablelength(NPC.get(996)) > 0 then
        for i=1, tablelength(NPC.get(996)) do
            NPC.get(996)[i].isHidden = false
        end
    end
    if tablelength(Block.get(999)) > 0 then
        Block.get(999)[1].isHidden = true
    end
    if tablelength(Block.get(987)) > 0 then
        Block.get(987)[1].isHidden = true
    end
    if tablelength(Block.get(992)) > 0 then
        Block.get(992)[1].isHidden = true
    end
    if tablelength(Block.get(998)) > 0 then
        for i=1, tablelength(Block.get(998)) do
            Block.get(998)[i].isHidden = true
        end
    end
    if tablelength(Block.get(995)) > 0 then
        for i=1, tablelength(Block.get(995)) do
            Block.get(995)[i].isHidden = true
        end
    end
    if tablelength(Block.get(997)) > 0 then
        for i=1, tablelength(Block.get(997)) do
            Block.get(997)[i].isHidden = true
        end
    end
    if tablelength(Block.get(988)) > 0 then
        for i=1, tablelength(Block.get(988)) do
            Block.get(988)[i].isHidden = true
        end
    end
end
function onPlayerKill(eventToken,harmedPlayer)
    if player == harmedPlayer then
        if player2 ~= nil then
            if player2:mem(0x13C,FIELD_BOOL) == true or player2.deathTimer > 0 then
                won = false
            end
        else
            won = false
        end
    end
    if player2 == harmedPlayer then
        if player ~= nil then
            if player:mem(0x13C,FIELD_BOOL) == true or player.deathTimer > 0 then
                won = false
            end
        else
            won = false
        end
    end
end
function onTickEnd()
    if tablelength(NPC.get(990)) > 0 and gotStamp == true then
        local npcc = NPC.get(990)[1]
        npcc:transform(989)
    end
    local bumpBlocks = NPC.get(857)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if bumpBlocks[i].isHidden == true and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                bumpBlocks[i].isHidden = true
            end
            if bumpBlocks[i].isHidden == false and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = true
                bumpBlocks[i].isHidden = false
            end
        end
    end
    local bumpBlocks = Block.get(775)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if player.hasStarman == true then
                bumpBlocks[i].contentID = 1293
            else
                bumpBlocks[i].contentID = 1
            end
        end
    end
    local bumpBlocks = NPC.get(849)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if bumpBlocks[i].isHidden == true and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                bumpBlocks[i].isHidden = true
            end
            if bumpBlocks[i].isHidden == false and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = true
                bumpBlocks[i].isHidden = false
            end
        end
    end
    local bumpBlocks = NPC.get(850)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if bumpBlocks[i].isHidden == true and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                bumpBlocks[i].isHidden = true
            end
            if bumpBlocks[i].isHidden == false and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = true
                bumpBlocks[i].isHidden = false
            end
        end
    end
    local bumpBlocks = NPC.get(848)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if bumpBlocks[i].isHidden == true and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                bumpBlocks[i].isHidden = true
            end
            if bumpBlocks[i].isHidden == false and tablelength(Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) > 0 then
                Block.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = true
                bumpBlocks[i].isHidden = false
            end
        end
    end
    if player == nil then return end
    if player.keys.down == KEYS_DOWN and not Misc.isPaused() then
        if table.contains(Block.getIntersecting(player.x, player.y+player.height, player.x+player.width, player.y+player.height+player.height),Block.get(756)[1]) then
            downTimer = downTimer-1
            if downTimer <= 0 then
                for i=1, tablelength(NPC.get()) do
                    if table.contains(NPC.getIntersecting(player.x-8000,player.y-8000,player.x+8000,player.y+8000),NPC.get()[i]) and NPC.get()[i].id ~= 857 and NPC.get()[i].id ~= 849 and NPC.get()[i].id ~= 850 and NPC.get()[i].id ~= 755 then
                        NPC.get()[i]:kill(HARM_TYPE_VANISH)
                    end
                end
                for i=1, tablelength(Warp.get()) do
                    if table.contains(Warp.getIntersectingEntrance(player.x-8000,player.y-8000,player.x+8000,player.y+8000),Warp.get()[i]) then
                        Warp.get()[i].y = 0
                        Warp.get()[i].x = 0
                    end
                end
                for i=1, tablelength(BGO.get()) do
                    if BGO.get()[i].id ~= 11 and BGO.get()[i].id ~= 61 and BGO.get()[i].id ~= 12 and BGO.get()[i].id ~= 60 then
                        if table.contains(BGO.getIntersecting(player.x-8000,player.y-8000,player.x+8000,player.y+8000),BGO.get()[i]) then
                            BGO.get()[i].isHidden = true
                        end
                        teleToSecret = true
                    end
                end
                for i=1, tablelength(Block.get()) do
                    if Block.config[Block.get()[i].id].sizable == true then
                        if table.contains(Block.getIntersecting(player.x-8000,player.y-8000,player.x+8000,player.y+8000),Block.get()[i]) then
                            Block.get()[i]:delete()
                        end
                    end
                end
            end
        end
    else
        downTimer = 300
    end
    counter = counter-1
    if Level.filename() ~= "rock path.lvlx" and counter <= 0 then
        if player.powerup == PLAYER_ICE and SaveData.playerTurn == 1 then
            Text.showMessageBox("You can't bring that powerup here! I will put it back for you!")
            player.powerup = SaveData.past1Powerup
            inventory.addPowerUp(5, 1)
        elseif player.powerup == PLAYER_ICER and SaveData.playerTurn == 2 then
            Text.showMessageBox("You can't bring that powerup here! I will put it back for you!")
            player.powerup = SaveData.past2Powerup
            inventory.addPowerUp(5, 1)
        elseif player.powerup == PLAYER_ICER and SaveData.playerTurn == 3 then
            Text.showMessageBox("You can't bring that powerup here! I will put it back for you!")
            player.powerup = SaveData.past3Powerup
            inventory.addPowerUp(5, 1)
        elseif player.powerup == PLAYER_ICER and SaveData.playerTurn == 4 then
            Text.showMessageBox("You can't bring that powerup here! I will put it back for you!")
            player.powerup = SaveData.past4Powerup
            inventory.addPowerUp(5, 1)
        elseif player.powerup == PLAYER_ICE then
            Text.showMessageBox("You can't bring that powerup here! I will put it back for you!")
            player.powerup = SaveData.past1Powerup
            inventory.addPowerUp(5, 1)
        end
    end
end
function onPostNPCKill(killedNPC,harmType)
    if killedNPC.id == 993 then NPC.spawn(993,player.x-500-killedNPC.width+1,killedNPC.y) end
end
function onCameraUpdate(camIdx)
    if tablelength(Block.get(988)) > 0 then
        if Block.get(988)[1].x <= player.x and Section.getIdxFromCoords(Block.get(988)[1].x, Block.get(988)[1].y, 16, 16) == player.section then
            camera.y = Section(player.section).boundary.top+camOffset
            if CamOffDir > 0 then
                camOffset=camOffset+0.2
                if Section(player.section).boundary.top+camOffset >= Section(player.section).boundary.bottom-camera.height then CamOffDir = -1 end
            end
            if CamOffDir < 0 then
                camOffset=camOffset-0.2
                if camOffset <= 0 then CamOffDir = 1 end
            end
        end
    end
end
function onTick()
    if player == nil then 
        return 
    end
    if randomizeBoxes == true and randomizeBoxesCount > 0 then
        if randomizeBoxesStep == 1 then
            random1 = Block.get(749)[RNG.randomInt(1,tablelength(Block.get(749)))]
            random2 = Block.get(749)[RNG.randomInt(1,tablelength(Block.get(749)))]
            while random2==random1 do
                random2 = Block.get(749)[RNG.randomInt(1,tablelength(Block.get(749)))]
            end
            random3 = Block.get(749)[RNG.randomInt(1,tablelength(Block.get(749)))]
            while random3==random1 or random3==random2 do
                random3 = Block.get(749)[RNG.randomInt(1,tablelength(Block.get(749)))]
            end
            Block1X = random1.x
            Block2X = random2.x
            Block1Y = random1.y
            Block2Y = random2.y
            random1.x = Block1X
            random2.x = Block2X
            random2.y = Block1Y-64
            random3.y = Block1Y-64
            random1.y = Block2Y-64
            randomizeBoxesStep = 30
        elseif randomizeBoxesStep == 2 then
            randomizeBoxesStep = -30
            randomizeBoxesCount = randomizeBoxesCount-1
            random2.y = Block1Y
            random1.y = Block2Y
            random3.y = Block1Y
        elseif randomizeBoxesStep > 0 then
            if random2.x > Block1X then 
                random2.x = random2.x-randomizeBoxesSpeed
                if random2.x < Block1X then random2.x = Block1X end
            end
            if random2.x < Block1X then 
                random2.x = random2.x+randomizeBoxesSpeed
                if random2.x > Block1X then random2.x = Block1X end
            end
            if random1.x > Block2X then 
                random1.x = random1.x-randomizeBoxesSpeed
                if random1.x < Block2X then random1.x = Block2X end
            end
            if random1.x < Block2X then 
                random1.x = random1.x+randomizeBoxesSpeed
                if random1.x > Block2X then random1.x = Block2X end
            end
            if random1.x == Block2X and random2.x == Block1X then 
                randomizeBoxesStep = 2 
                randomizeBoxesSpeed = randomizeBoxesSpeed*1.4
            end
        elseif randomizeBoxesStep < 1 then
            randomizeBoxesStep = randomizeBoxesStep+1
        end
        player.speedX = 0
        player.speedY = 0
    elseif randomizeBoxes == true then
        randomizeBoxes = false
    end
    if teleToSecret == true then
        for i=1, tablelength(BGO.get()) do
            if table.contains(BGO.getIntersecting(player.x, player.y, player.x+player.width, player.y+player.height),BGO.get(11)[i]) or table.contains(BGO.getIntersecting(player.x, player.y, player.x+player.width, player.y+player.height),BGO.get(12)[i]) or table.contains(BGO.getIntersecting(player.x, player.y, player.x+player.width, player.y+player.height),BGO.get(61)[i]) or table.contains(BGO.getIntersecting(player.x, player.y, player.x+player.width, player.y+player.height),BGO.get(60)[i]) then
                player.section = 10
                player.speedX = 0
                player.speedY = 0
                player:teleport(Block.get(992)[1].x,Block.get(992)[1].y+Block.get(992)[1].height,true)
            end
        end
    end
    if tablelength(Block.get(993)) > 0 then
        local movelayer = Layer.get("upDown")
        movelayer.pauseDuringEffect = true
        if Block.get(993)[1].x <= player.x then
            if movelayer:isPaused() == false then
                for i=1,1 do
                    Block.get(993)[1].isHidden = true
                    for p=1,tablelength(Player.get()) do
                        if Section.getIdxFromCoords(Block.get(993)[1].x, Block.get(993)[1].y, 16, 16) == Player.get()[p].section then
                            movingLayerCounter = movingLayerCounter-1
                            if movingLayerCounter <= 0 then
                                movingLayerDir = -movingLayerDir
                                movingLayerCounter = 324
                                movelayer.speedY = 0
                            end
                            movelayer.speedY = movelayer.speedY + (0.015*(movingLayerDir))
                            if movelayer.speedY > 1 then movelayer.speedY = 1 end
                            if movelayer.speedY < -1 then movelayer.speedY = -1 end
                        else
                            movelayer.speedY = 0
                        end
                    end
                end
            end
        else
            movelayer.speedY = 0
        end
    end
    if player.deathTimer > 0 then
        gotStamp = false
    end
    local bumpBlocks = Block.get(854)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if Colliders.speedCollide(player,bumpBlocks[i]) and player.speedX > 1 and player.x <= bumpBlocks[i].x - (player.width/2) and player.y+player.height-2 >= bumpBlocks[i].y then
                --player.x = player.x-player.speedX
                bumpBlocks[i]:hit(false,player,1)
                bumpBlocks[i].isHidden = true
                
                if tablelength(NPC.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) == 0 then
                    local bump = NPC.spawn(857,bumpBlocks[i].x,bumpBlocks[i].y)
                else
                    NPC.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                end
           elseif Colliders.speedCollide(player,bumpBlocks[i]) and player.speedX < -1 and player.x >= bumpBlocks[i].x and player.y+player.height-2 >= bumpBlocks[i].y then
                --player.x = player.x+player.speedX
                bumpBlocks[i]:hit(false,player,1)
                
                bumpBlocks[i].isHidden = true
                if tablelength(NPC.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)) == 0 then
                    local bump = NPC.spawn(857,bumpBlocks[i].x,bumpBlocks[i].y)
                else
                    NPC.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+8,bumpBlocks[i].y+8)[1].isHidden = false
                end
           end
        end
    end
    local bumpBlocks = Block.get(753)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if player.keys.up and bumpBlocks[i].isHidden == false and tablelength(Player.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+bumpBlocks[i].width,bumpBlocks[i].y+bumpBlocks[i].height)) > 0 then
                Block.spawn(752,bumpBlocks[i].x,bumpBlocks[i].y)
                bumpBlocks[i]:remove(false)
            end
        end
    end
    local bumpBlocks = Block.get(751)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if  player.keys.up and bumpBlocks[i].isHidden == false and tablelength(Player.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+bumpBlocks[i].width,bumpBlocks[i].y+bumpBlocks[i].height)) > 0 then
                Block.spawn(750,bumpBlocks[i].x,bumpBlocks[i].y)
                bumpBlocks[i]:remove(false)
            end
        end
    end
    local bumpBlocks = Block.get(749)
    if tablelength(bumpBlocks) > 0 then
        for i=1,tablelength(bumpBlocks) do
            if  player.keys.up and bumpBlocks[i].isHidden == false and tablelength(Player.getIntersecting(bumpBlocks[i].x,bumpBlocks[i].y,bumpBlocks[i].x+bumpBlocks[i].width,bumpBlocks[i].y+bumpBlocks[i].height)) > 0 then
                Block.spawn(752,bumpBlocks[i].x,bumpBlocks[i].y)
                bumpBlocks[i]:remove(false)
            end
        end
    end
    if raiseWater == true then
        if waterHeight > 98 then
            waterDir = -1
        elseif waterHeight < 0 then
            waterDir = 1
        end
        if waterDir == -1 then
            waterMove = waterMove-0.05
        elseif waterDir == 1 then
            waterMove = waterMove+0.05
        end
        if waterMove < -0.4 then waterMove = -0.4 end
        if waterMove > 0.4 then waterMove = 0.4 end
        waterHeight = waterHeight + waterMove
        local bg = BGO.get()
        for i=1, tablelength(bg) do
            if bg[i].id == 82 or bg[i].id == 83 or bg[i].id == 65 or bg[i].id == 165 then 
                if Section.getIdxFromCoords(bg[i].x, bg[i].y, 32, 32) == player.section then
                    bg[i].y = bg[i].y - waterMove
                end
            end
        end
        local bg = NPC.get()
        for i=1, tablelength(bg) do
            if bg[i].id == 993 or bg[i].id == 230 or bg[i].id == 229 then 
                if Section.getIdxFromCoords(bg[i].x, bg[i].y, 32, 32) == player.section then
                    bg[i].y = bg[i].y - waterMove
                    if bg[i].data.y ~= nil then
                        bg[i].data.y = bg[i].data.y - waterMove
                    end
                    if bg[i].startY ~= nil then
                        bg[i].startY = bg[i].startY-waterMove
                    end
                end
            end
        end
        local bg = Liquid.get()
        for i=1, tablelength(bg) do
            if Section.getIdxFromCoords(bg[i].x, bg[i].y, 32, 32) == player.section then
                bg[i].y = bg[i].y - waterMove
            end
        end
        
    end
    local fireballs = NPC.get(276)
    if tablelength(fireballs) > 0 then
        for i = 1, tablelength(fireballs) do
            fireballs[i].speedY = -1
        end
    end
    --[[local blocks = Block.get(997)
    if tablelength(blocks) > 0 then
        local intersected = false
        local v = Block.get(997)[1]
        local aa = 1
        for a=1, tablelength(Block.get(997)) do
            if aa > tablelength(Block.get(997)) then break end
            local intersecting = Player.getIntersecting(Block.get(997)[aa].x+Block.get(997)[aa].width+32,Block.get(997)[aa].y,Block.get(997)[aa].x+(2*Block.get(997)[aa].width),Block.get(997)[aa].y+Block.get(997)[aa].height)
            if tablelength(Player.get()) > 1 then
                
                if tablelength(intersecting) > 0 then
                    intersected = true
                    Block.spawn(74,Block.get(997)[aa].x,Block.get(997)[aa].y)
                    
                    if intersecting[1] == player then
                        player2.x = Block.get(995)[1].x
                        player2.y = Block.get(995)[1].y
                    elseif intersecting[1] == player2 then
                        player.x = Block.get(995)[1].x
                        player.y = Block.get(995)[1].y
                    end
                    if tablelength(Block.get(997)) > 0 then
                        v:delete()
                    end
                    for i =1, tablelength(Block.get(997))+1 do
                        if tablelength(Block.get(997)) > 0 then
                            Block.spawn(74,Block.get(997)[1].x,Block.get(997)[1].y)
                            Block.get(997)[1]:delete()
                        end
                    end
                else
                    aa = aa+1
                end
            else
                if tablelength(intersecting) > 0 then
                    Block.spawn(74,Block.get(997)[aa].x,Block.get(997)[aa].y)
                    intersected = true
                    if tablelength(Block.get(997)) > 0 then
                        v:delete()
                    end
                    for i =1, tablelength(Block.get(997)) do
                        if tablelength(Block.get(997)) > 0 then
                            Block.spawn(74,Block.get(997)[1].x,Block.get(997)[1].y)
                            Block.get(997)[1]:delete()
                        end
                    end
                else
                    aa = aa+1
                end
            end
        end
    end--]]
    -- Set the "can spin jump" flag, but only if not using a mount
    if player.mount == MOUNT_NONE then
        player:mem(0x120,FIELD_BOOL,false)
    end
    if (player2 == nil) == false then
        if player2.mount == MOUNT_NONE then
            player2:mem(0x120,FIELD_BOOL,false)
        end
        player2.reservePowerup = 0
        
    end
    player.reservePowerup = 0
end
function onHUDDraw(cameraID)
    local offSet = 0

    if tablelength(Camera.get()) > 1 and tablelength(Player.get()) > 1 then
        if cameraID == 1 and Camera.get()[1].renderX > Camera.get()[2].renderX and player:mem(0x13C, FIELD_BOOL) == false then
            offSet = Camera.get()[cameraID].width
        elseif cameraID == 2 and Camera.get()[2].renderX > Camera.get()[1].renderX and player2:mem(0x13C, FIELD_BOOL) == false then
            offSet = Camera.get()[cameraID].width
        end
        --[[if cameraID == 2 and Camera.get()[1].renderY > Camera.get()[2].renderY then
            return
        elseif cameraID == 1 and Camera.get()[2].renderY > Camera.get()[1].renderY then
            return
        end--]]
    end
    local score = Misc.score();
	local lives = mem(0x00B2C5AC, FIELD_FLOAT);
	local coins = mem(0x00B2C5A8, FIELD_WORD);
    local canFly = player:mem(0x16C, FIELD_BOOL);
    local isFlying = player:mem(0x16E, FIELD_BOOL);
    local speedTime = player:mem(0x168, FIELD_FLOAT);
    local speed = player.speedX;
    local pl = player--[[
    if tablelength(Player.get()) > 1 then
        if player:mem(0x13C, FIELD_BOOL) == true and player2:mem(0x13C, FIELD_BOOL) == false then
          canFly = player2:mem(0x16C, FIELD_BOOL);
          isFlying = player2:mem(0x16E, FIELD_BOOL);
          speedTime = player2:mem(0x168, FIELD_FLOAT);
          speed = player2.speedX;
          pl = player2
        else
            canFly = player:mem(0x16C, FIELD_BOOL);
            isFlying = player:mem(0x16E, FIELD_BOOL);
            speedTime = player:mem(0x168, FIELD_FLOAT);
            speed = player.speedX;
            pl = player
        end
    else
        canFly = player:mem(0x16C, FIELD_BOOL);
        isFlying = player:mem(0x16E, FIELD_BOOL);
        speedTime = player:mem(0x168, FIELD_FLOAT);
        speed = player.speedX;
    end
    --[[local timeLeft = Misc.getBeatClock()
	local levelname = Level.name();
	local level_length = string.len(levelname);
	
    if(levelname == "") or (level_length > 11) then
		levelname = "Level";
	end
    Graphics.drawBox{
        color = Color.black,
        priority = renderPriority,
        x = 0, 
        y = camera.height-64*(4/3), 
        w = camera.width, 
        h = (64*(4/3))+64,
        sourceX = 0,
	    sourceY = 0,
		sourceWidth = camera.width,
		sourceHeight = 64*(4/3),
    }
    Graphics.draw{
        type = RTYPE_IMAGE,
        image = uibox,
        x = 0-offSet,
        y = camera.height-620,
        priority = renderPriority,
        sourceX = 0,
        
        sourceY = 0,
        sourceWidth = 800,
        sourceHeight = 600,
    }]]
    Graphics.draw{
                type = RTYPE_IMAGE,
                image = powerbar,
                x = 304-offSet,
                y = 584-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 128,
                sourceHeight = 16,
    }--[[
    Graphics.draw{
                type = RTYPE_IMAGE,
                image = coinicon,
                x = 500-offSet,
                y = 524-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 46,
                sourceHeight = 16,
    }
    Graphics.draw{
                type = RTYPE_IMAGE,
                image = lifeicon,
                x = 110-offSet,
                y = 544-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 28,
                sourceHeight = 16,
    }
    Graphics.draw{
                type = RTYPE_IMAGE,
                image = timeicon,
                x = 495-offSet,
                y = 544-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 32,
                sourceHeight = 16,
    }--]]
    --[[Text.print(string.format("%02d",coins), 1,546-offSet, 524-(600-camera.height));
    Text.print(string.format("%08d", score),1,304-offSet, 524-(600-camera.height));
    Text.print(tostring(lives), 1,144-offSet, 544-(600-camera.height));
    Text.print(levelname,109-offSet, 523-(600-camera.height));
    Text.print(string.format("%03d",timeLeft), 1, 528-offSet, 544-(600-camera.height));--]]
    --Text.print(playerHit,1,400,500)
    --Text.print(speed, 1, 528-offSet, 544-(600-camera.height))
    local mx = 35
    if pl.character == CHARACTER_MARIO then mx = 35 
    elseif pl.character == CHARACTER_LINK then mx = 10 
    elseif pl.character == CHARACTER_LUIGI then mx = 40 
    elseif pl.character == CHARACTER_TOAD then mx = 60
    elseif pl.character == CHARACTER_PEACH then mx = 80 
    elseif pl.character == CHARACTER_WARIO then mx = 35 
    elseif pl.character == CHARACTER_KLONOA then mx = 60 
    elseif pl.character == CHARACTER_NINJABOMBERMAN then mx = 80 
    elseif pl.character == CHARACTER_ROSALINA then mx = 80 
    elseif pl.character == CHARACTER_SNAKE then mx = 10 
    elseif pl.character == CHARACTER_ZELDA then mx = 40 
    elseif pl.character == CHARACTER_ULTIMATERINKA then mx = 60
    else mx = -1 end
    if((canFly == true) or (isFlying == true)) and mx >= 0 then
        speedTime = mx
        if pwingsndp == nil then
		    pwingsndp = SFX.play(pwingsnd)
        end
        Graphics.draw{
                type = RTYPE_IMAGE,
                image = powerbaricon,
                x = 402-offSet,
                y = 584-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 30,
                sourceHeight = 16,
        }
    else
        if pwingsndp ~= nil then
            pwingsndp:stop()
            pwingsndp = nil
        end
	end
    if(speedTime > 0) and mx >= 0 then
      Graphics.draw{
          type = RTYPE_IMAGE,
          image = powerbararrow,
          x = 304-offSet,
          y = 584-(600-camera.height),
          priority = renderPriority,
          sourceX = 0,
          sourceY = 0,
          sourceWidth = 14,
          sourceHeight = 16,
      } 
      reduceTimer = reduceTimer - 1;   
    end
    if(speedTime > (mx/5)*1) and mx >= 0 then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = powerbararrow,
            x = 320-offSet,
            y = 584-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 16,
        }
        reduceTimer = reduceTimer - 1;
    end

    if(speedTime > (mx/5)*2) and mx >= 0 then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = powerbararrow,
            x = 336-offSet,
            y = 584-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 16,
        }
        reduceTimer = reduceTimer - 1;
    end

    if(speedTime > (mx/5)*3) and mx >= 0 then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = powerbararrow,
            x = 352-offSet,
            y = 584-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 16,
        }
        reduceTimer = reduceTimer - 1;  
    end

    if(speedTime > (mx/5)*4) and mx >= 0 then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = powerbararrow,
            x = 368-offSet,
            y = 584-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 16,
        }
        reduceTimer = reduceTimer - 1;
    end

    if(speedTime >= (mx/5)*5) and mx >= 0 then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = powerbararrow,
            x = 384-offSet,
            y = 584-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 16,
        }
        reduceTimer = reduceTimer - 1;
    end 

    if(speed >= 6) or (speed <= -6) or (isFlying == false) then

		pbarCount = pbarCount + 1;
        if (pbarCount > 40) then
			pbarCount = 40;
        end
		
	else
		pbarCount = pbarCount - 1;
	end
    if gotStamp == true then
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = fullStamp,
            x = 16-offSet,
            y = 58-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 16,
            sourceHeight = 16,
        }
    else
        if tablelength(NPC.get(990)) > 0 then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = emptyStamp,
                x = 16-offSet,
                y = 58-(600-camera.height),
                priority = renderPriority,
                sourceX = 0,
                sourceY = 0,
                sourceWidth = 16,
                sourceHeight = 16,
            }
        end
    end
    --[[
    for i=1, StarCoinCount do
        Graphics.draw{
            type = RTYPE_IMAGE,
            image = starCoinEmptyicon,
            x = 109+190-offSet+(i*15)-(StarCoinCount*15),
            y = 523-(600-camera.height),
            priority = renderPriority,
            sourceX = 0,
            sourceY = 0,
            sourceWidth = 14,
            sourceHeight = 14,
        }
    end ]]
	if(pbarCount <= 0) then
		pbarCount = 0;
	end
    addCards(cameraID,renderPriority,tablelength(Camera.get()) > 1)
end
function onEvent(eventName)
    if eventName == "P Switch - Start" then
		local npcs = NPC.get(995)
        if tablelength(npcs) > 0 then
            for i=1, tablelength(npcs) do
                npcs[i]:transform(996)
            end
        end
        if tablelength(NPC.get(996)) > 0 then
            for i=1, tablelength(NPC.get(996)) do
                NPC.get(996)[i].isHidden = false
            end
        end
	end
    if eventName == "P Switch - End" then
		local npcs = NPC.get(996)
        if tablelength(npcs) > 0 then
            for i=1, tablelength(npcs) do
                npcs[i]:transform(995)
            end
        end
        if tablelength(NPC.get(995)) > 0 then
            for i=1, tablelength(NPC.get(995)) do
                NPC.get(995)[i].isHidden = true
            end
        end
        
	end
    if eventName == "mushroom" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(0, 1)
        Text.showMessageBox("You got a Mushroom!")
    end
    if eventName == "fireflower" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(1, 1)
        Text.showMessageBox("You got a FireFlower!")
    end
    if eventName == "leaf" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(2, 1)
        Text.showMessageBox("You got a Raccoon Leaf!")
    end
    if eventName == "tanooki" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(3, 1)
        Text.showMessageBox("You got a Tanooki Suit!")
    end
    if eventName == "hammer" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(4, 1)
        Text.showMessageBox("You got a Hammer Suit!")
    end
    if eventName == "ice" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(5, 1)
        Text.showMessageBox("You got a Hammer!")
    end
    if eventName == "starman" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(6, 1)
        Text.showMessageBox("You got a Star!")
    end
    if eventName == "pwing" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        inventory.addPowerUp(7, 1)
        Text.showMessageBox("You got a P-Wing!")
    end
    if eventName == "whistle" then
        if SaveData.levelEnterUnlocked == true then 
            Level.winState(LEVEL_END_STATE_SMB3ORB) 
            return 
        end
        inventory.addPowerUp(8, 1)
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        Text.showMessageBox("You got a Whistle to a new world!")
        Level.winState(LEVEL_END_STATE_SMB3ORB)
    end
    if eventName == "random" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = RNG.randomInt(0,2)
        if random == 0 then onEvent("mushroom") elseif random == 1 then onEvent("fireflower") elseif random == 2 then onEvent("leaf") end
    end
    if eventName == "random 1-3" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = RNG.randomInt(0,2)
        if random == 0 then onEvent("mushroom") elseif random == 1 then onEvent("fireflower") elseif random == 2 then onEvent("leaf") end
    end
    if eventName == "random 1-3 ver2" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = RNG.randomInt(0,2)
        if random == 0 then onEvent("fireflower") elseif random == 1 then onEvent("leaf") elseif random == 2 then onEvent("tanooki") end
    end
    if eventName == "random 1-up" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = RNG.randomInt(0,3)
        if random == 1 then random = 1
        elseif random == 2 then random = 3
        elseif random == 3 then random = 5 end
        if random > 0 then
            for i=1,random do
                NPC.spawn(90, player.x, player.y+16, player.section)
            end
        end
        Text.showMessageBox(random.."-Ups!")
    end
    if eventName == "0 1-up" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = 0
        Text.showMessageBox(random.."-Ups!")
    end
    if eventName == "3 1-up" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = 3
        for i=1,random do
            NPC.spawn(90, player.x, player.y+16, player.section)
        end
        Text.showMessageBox(random.."-Ups!")
    end
    if eventName == "5 1-up" then
        if SaveData.levelEnterUnlocked == true then return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        random = 5
        for i=1,random do
            NPC.spawn(90, player.x, player.y+16, player.section)
        end
        Text.showMessageBox(random.."-Ups!")
    end
    if eventName == "startBoxes" then
        randomizeBoxes = true
        randomizeBoxesCount = 5
    end
    if eventName == "autoscroll" then
        autoscroll.scrollRight(1)
    end
    if eventName == "bonusItems" then
        if starCoinTotal >= 3*8 and SaveData.bonusCount < 1 then
            inventory.addPowerUp(0, 3)
            Text.showMessageBox("You got 3 Mushrooms!")
            SaveData.bonusCount = SaveData.bonusCount+1
        end
        if starCoinTotal >= 3*(8+9) and SaveData.bonusCount < 2 then
            inventory.addPowerUp(1, 3)
            Text.showMessageBox("You got 3 FireFlowers!")
            SaveData.bonusCount = SaveData.bonusCount+1
        end
        if starCoinTotal >= 3*(8+9+12) and SaveData.bonusCount < 3 then
            inventory.addPowerUp(2, 3)
            Text.showMessageBox("You got 3 Raccoon Leafs!")
            SaveData.bonusCount = SaveData.bonusCount+1
        end
    end
    if eventName == "EndLevel" then
        NPC.spawn(16, player.x, player.y+16, player.section)
    end
    if eventName == "EndRock" then
        if SaveData.levelEnterUnlocked == true then NPC.spawn(16, player.x, player.y+16, player.section); return end
        local levelEntertitle = SaveData.LevelEntered
        local tale = SaveData.levelPassInfo
        if tale ~= nil then
            tale[table.ifind(tale,SaveData.LevelEntered)+1] = true
            SaveData.levelPassInfo = tale
        end
        if SaveData.playerTurn == 1 and player.powerup == PLAYER_ICE then
            Text.showMessageBox("Your lost your Hammer!")
            player.powerup = SaveData.past1Powerup
        elseif SaveData.playerTurn == 2 then
            if player.powerup == PLAYER_ICE then
                Text.showMessageBox("Your lost your Hammer!")
                player.powerup = SaveData.past2Powerup
            end
        elseif SaveData.playerTurn == 3 then
            if player.powerup == PLAYER_ICE then
                Text.showMessageBox("Your lost your Hammer!")
                player.powerup = SaveData.past3Powerup
            end
        elseif SaveData.playerTurn == 4 then
            if player.powerup == PLAYER_ICE then
                Text.showMessageBox("Your lost your Hammer!")
                player.powerup = SaveData.past4Powerup
            end
        end
        NPC.spawn(16, player.x, player.y+16, player.section)
    end
end
function onNPCKill(eventToken,killedNPC,harmtype)
    if killedNPC.id == 996 and harmtype == HARM_TYPE_VANISH then
        mem(0x00B2C5A8,FIELD_WORD,mem(0x00B2C5A8,FIELD_WORD)+1)
        if mem(0x00B2C5A8,FIELD_WORD) >= 100 then 
            mem(0x00B2C5AC,FIELD_FLOAT,mem(0x00B2C5AC,FIELD_FLOAT)+1)
            mem(0x00B2C5A8,FIELD_WORD,mem(0x00B2C5A8,FIELD_WORD)-100)
            SFX.play(upsnd)
        end
        Misc.givePoints(SCORE_10,vector(killedNPC.x,killedNPC.y),false)
    end
    if killedNPC.id == 800 and harmtype == HARM_TYPE_JUMP then
        NPC.spawn(799,killedNPC.x,killedNPC.y)
    end
    if killedNPC.id == 990 and gotStamp == false and harmtype == HARM_TYPE_VANISH and tablelength(Player.getIntersecting(killedNPC.x,killedNPC.y,killedNPC.x+killedNPC.width,killedNPC.y+killedNPC.height)) > 0 then
        gotStamp = true
        SFX.play(stampCollect)
        NPC.spawn(90, player.x, player.y+16, player.section)
    end
    if killedNPC.id == 989 and harmtype == HARM_TYPE_VANISH and tablelength(Player.getIntersecting(killedNPC.x,killedNPC.y,killedNPC.x+killedNPC.width,killedNPC.y+killedNPC.height)) > 0 then
        gotStamp = true
        SFX.play(stampCollect)
    end
    if killedNPC.id == 994 then 
        inventory.addPowerUp(7, 1)
        Text.showMessageBox("There is a letter here...")
        Text.showMessageBox(killedNPC.msg)
        Text.showMessageBox("You got a P-Wing!")
        NPC.spawn(16, player.x, player.y+16, player.section)
    end
end
function onExitLevel(win)
    if string.find(Level.filename(),"-toad") == nil and Level.filename() ~= "slotgame.lvlx" and Level.filename() ~= "rock path.lvlx" and Level.filename() ~= "pipeSection.lvlx" and Level.filename() ~= "midsection.lvlx" and Level.filename() ~= "1-fortress.lvlx" then
        updatePlayerTurn()
    end
    if Level.name() == "1-1" then
        local counting = 0
        if SaveData._basegame.starcoin[Level.filename()][1] == 1 then
            counting = counting+1
        end
        if SaveData._basegame.starcoin[Level.filename()][2] == 1 then
            counting = counting+1
        end
        if SaveData._basegame.starcoin[Level.filename()][3] == 1 then
            counting = counting+1
        end
    end
    if gotStamp == true then
        SaveData.stamps[Level.filename()][1] = true
    end
end
function updatePlayerTurn()
    if SaveData.playerTurn == 1 then 
        SaveData.player1Pow = player.powerup
        --SaveData.player1lv = mem(0x00B2C5AC,FIELD_FLOAT)
	elseif SaveData.playerTurn == 2 then 
        SaveData.player2Pow = player.powerup
        --SaveData.player2lv = mem(0x00B2C5AC,FIELD_FLOAT)
    elseif SaveData.playerTurn == 3 then 
        SaveData.player3Pow = player.powerup
        --SaveData.player3lv = mem(0x00B2C5AC,FIELD_FLOAT)
    elseif SaveData.playerTurn == 4 then 
        SaveData.player4Pow = player.powerup 
        --SaveData.player4lv = mem(0x00B2C5AC,FIELD_FLOAT)
    end
	if SaveData.playerTurn == 1 and SaveData.isMulti == true then 
		SaveData.playerTurn = 2
		player.powerup = SaveData.player2Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player2lv)
	elseif SaveData.playerTurn == 2 and SaveData.isMulti == true and SaveData.playerCount > 2 then 
		SaveData.playerTurn = 3
		player.powerup = SaveData.player3Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player3lv)
    elseif SaveData.playerTurn == 3 and SaveData.isMulti == true and SaveData.playerCount > 3 then 
		SaveData.playerTurn = 4 
		player.powerup = SaveData.player4Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player4lv)
    elseif SaveData.playerTurn == 4 and SaveData.isMulti == true then 
		SaveData.playerTurn = 1 
		player.powerup = SaveData.player1Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player1lv)
    elseif SaveData.isMulti == true then 
		SaveData.playerTurn = 1 
		player.powerup = SaveData.player1Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player1lv)
	end
	if SaveData.playerTurn > 1 and SaveData.isMulti == false then
		SaveData.playerTurn = 1 
		player.powerup = SaveData.player1Pow
        --mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player1lv)
	end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
