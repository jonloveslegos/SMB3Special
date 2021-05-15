local smb3cardRemake = {}

-- Configurable Stuff
local useCard = true

-- TextPlus
local textplus = require("textplus")

-- GoalCard Variables
local lives = mem(0x00B2C5AC, FIELD_FLOAT)
local addlives = false
local addpoints = false
local postLevel = 0
local endLives = false
local doesMatch = false
local howMuchLives = 0

-- Graphics Stuff
local uicard = Graphics.loadImage(Misc.resolveFile("HUDCard/smb3card.png"))
local timericon = Graphics.loadImage(Misc.resolveFile("HUDCard/timer.png"))
local yFont = textplus.loadFont("HUDCard/1.ini")

local oneup = Graphics.loadImage(Misc.resolveFile("HUDCard/1up.png"))
local twoup = Graphics.loadImage(Misc.resolveFile("HUDCard/2up.png"))
local threeup = Graphics.loadImage(Misc.resolveFile("HUDCard/3up.png"))
local fiveup = Graphics.loadImage(Misc.resolveFile("HUDCard/5up.png"))

local font = textplus.loadFont("textplus/font/7.ini")


function smb3cardRemake.onInitAPI()
    registerEvent(smb3cardRemake, "onTick")
    registerEvent(smb3cardRemake, "onDraw")
    registerEvent(smb3cardRemake, "onHUDDraw")

    -- Saving Data
    if not SaveData.setCards then
        SaveData.Card = {0, 0, 0, count = 0}
        SaveData.setCards = true
    end
end

function smb3cardRemake.onTick()
    if Level.winState() == 1 then
        local endLevel = false

        local cardNPC = NPC.get(11, -1)

        if not endLevel then
            if cardNPC[1] ~= nil then
                local cardframe = cardNPC[1]:mem(0xE4, FIELD_WORD)

                if SaveData.Card.count == 0 then
                    SaveData.Card[1] = tonumber(cardframe) + 1
                    SaveData.Card.count = 1

                elseif SaveData.Card.count == 1 then
                    SaveData.Card[2] = tonumber(cardframe) + 1
                    SaveData.Card.count = 2

                elseif SaveData.Card.count == 2 then
                    SaveData.Card[3] = tonumber(cardframe) + 1
                    SaveData.Card.count = 3
                end

                if SaveData.Card.count == 3 then
                    addlives = true
                end
            end

            endLevel = true
        end
        if addlives then
            postLevel = postLevel + 1
            if postLevel >= 65 and not endLives then
                if SaveData.Card[1] == 1 and SaveData.Card[2] == 1 and SaveData.Card[3] == 1 then
                    doesMatch = true
                    mem(0x00B2C5AC, FIELD_FLOAT, (lives + 5))
                    SFX.play(15)
                    howMuchLives = 5
                elseif SaveData.Card[1] == 2 and SaveData.Card[2] == 2 and SaveData.Card[3] == 2 then
                    doesMatch = true
                    mem(0x00B2C5AC, FIELD_FLOAT, (lives + 2))
                    SFX.play(15)
                    howMuchLives = 2
                elseif SaveData.Card[1] == 3 and SaveData.Card[2] == 3 and SaveData.Card[3] == 3 then
                    doesMatch = true
                    mem(0x00B2C5AC, FIELD_FLOAT, (lives + 3))
                    SFX.play(15)
                    howMuchLives = 3
                else
                    mem(0x00B2C5AC, FIELD_FLOAT, (lives + 1))
                    SFX.play(15)
                    howMuchLives = 1
                end
                endLives = true
            end

            if postLevel >= 145 and SaveData.Card.count >= 3 then
                SaveData.Card.count = 0
                SaveData.Card[1] = 0
                SaveData.Card[2] = 0
                SaveData.Card[3] = 0
            end
        end
    end
end


function addCards(cameraID, renderPriority, isSplitscreen)
    -- Drawing the Base UI
    local offSet = 0
    local Yoffset = Camera.get()[cameraID].height-150
    if isSplitscreen == true then
        if cameraID == 1 and Camera.get()[1].renderX < Camera.get()[2].renderX then
            offSet = -Camera.get()[cameraID].width
        elseif cameraID == 2 and Camera.get()[2].renderX < Camera.get()[1].renderX then
            offSet = -Camera.get()[cameraID].width
        end
    end
    Graphics.draw{
        type = RTYPE_IMAGE,
        image = uicard,
        x = camera.width - (803-629)-offSet,
        y = camera.height - (619-1020)-Yoffset,
        priority = renderPriority,
        sourceX = 48 * SaveData.Card[1],
        sourceY = 0,
        sourceWidth = 48,
        sourceHeight = 48,
    }

    Graphics.draw{
        type = RTYPE_IMAGE,
        image = uicard,
        x = camera.width - (803-677)-offSet,
        y = camera.height - (619-1020)-Yoffset,
        priority = renderPriority,
        sourceX = 48 * SaveData.Card[2],
        sourceY = 0,
        sourceWidth = 48,
        sourceHeight = 48,
    }

    Graphics.draw{
        type = RTYPE_IMAGE,
        image = uicard,
        x = camera.width - (803-725)-offSet,
        y = camera.height - (619-1020)-Yoffset,
        priority = renderPriority,
        sourceX = 48 * SaveData.Card[3],
        sourceY = 0,
        sourceWidth = 48,
        sourceHeight = 48,
    }
end



function smb3cardRemake.onDraw()  
    if Level.winState() > 0 then
        textplus.print{text="LEVEL CLEARED!", x=400, y=150, font=font, priority=5, xscale=2, yscale=2, pivot = Sprite.align.CENTER}
        
        if useCard then
            if Level.winState() == 1 then
                textplus.print{text="YOU GOT A CARD!", x=370, y=220, font=font, priority=5, xscale=2, yscale=2, pivot = Sprite.align.CENTER}
                for i = 1, SaveData.Card.count, 1 do
                    Graphics.draw{
                        type = RTYPE_IMAGE,
                        image = uicard,
                        x = 505,
                        y = 190,
                        priority = 5,
                        sourceX = 48 * SaveData.Card[i],
                        sourceY = 0,
                        sourceWidth = 48,
                        sourceHeight = 48,
                    }
                end
            end
        end

        if Timer.isActive() then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = timericon,
                x = 220,
                y = 270,
                priority = 5
            }
            textplus.print{text=tostring(Timer.getValue()).. " X 50 = ".. tostring(Timer.getValue() * 50), x=240, y=270, font=yFont, priority=5}
            if not addpoints then
                SaveData._basegame.hud.score = SaveData._basegame.hud.score + Timer.getValue() * 50
                addpoints = true
            end
        end
        
        if howMuchLives == 5 then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = fiveup,
                x = 400,
                y = 300,
                priority = 6
            }
        elseif howMuchLives == 2 then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = twoup,
                x = 400,
                y = 300,
                priority = 6
            }
        elseif howMuchLives == 3 then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = threeup,
                x = 400,
                y = 300,
                priority = 6
            }
        elseif howMuchLives == 1 then
            Graphics.draw{
                type = RTYPE_IMAGE,
                image = oneup,
                x = 400,
                y = 300,
                priority = 6
            }
        end
    end
end


function smb3cardRemake.useCard(me)
    useCard = me
end

return smb3cardRemake