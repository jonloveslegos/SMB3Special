-------------------------------------------------------
--[[ anotherPowerDownLibrary.lua v1.0 by KBM-Quine ]]--
--[[              with code help from:             ]]--
--[[         rixithechao, Enjl, and Hoeloe         ]]--
-------------------------------------------------------
local anotherPowerDownLibrary = {}
local pm = require("playermanager")
local bowser = require("characters/bowser")
anotherPowerDownLibrary.enabled = true
anotherPowerDownLibrary.customForcedState = 751

local usableCharacters = { --most characters either don't work with it or have unique enough gameplay that warrants exclusion
    [CHARACTER_MARIO] = true,
    [CHARACTER_LUIGI] = true,
    [CHARACTER_PEACH] = false,
    [CHARACTER_TOAD] = false,
    [CHARACTER_LINK] = false,
    [CHARACTER_MEGAMAN] = false,
    [CHARACTER_WARIO] = true,
    [CHARACTER_BOWSER] = true, --bowser is coded to work, but will be disabled by default
    [CHARACTER_KLONOA] = false,
    [CHARACTER_NINJABOMBERMAN] = false,
    [CHARACTER_ROSALINA] = false,
    [CHARACTER_SNAKE] = false,
    [CHARACTER_ZELDA] = true,
    [CHARACTER_ULTIMATERINKA] = false,
    [CHARACTER_UNCLEBROADSWORD] = true,
    [CHARACTER_SAMUS] = false
}

function anotherPowerDownLibrary.setCharacterActive(charID, bool)
    usableCharacters[charID] = bool
end

function anotherPowerDownLibrary.onInitAPI()
    registerEvent(anotherPowerDownLibrary, "onTickEnd", "onTick", true)
end

local playerData = {}

function anotherPowerDownLibrary.onTick()
    if not isOverworld and anotherPowerDownLibrary.enabled then
        for _, p in ipairs(Player.get()) do
            local ps = PlayerSettings.get(pm.getCharacters()[p.character].base, p.powerup)
            playerData[p] = playerData[p] or {}
            playerData[p].curState = playerData[p].curState or 0

            if not usableCharacters[p.character] then --stops characters with false set in this list from using this system
                return
            end
            if p.BlinkTimer == 120 and p.character == CHARACTER_UNCLEBROADSWORD and playerData[p].curState ~= 2 then --allows uncle broadsword to use this libaray without overwriting his unique mechanics
                p.powerup = 2
                return
            end
            if p.BlinkTimer > 0 and p.character == CHARACTER_BOWSER then --allows bowser to use this libaray without overwriting his unique mechanics
                if playerData[p].curState > 2 then
                    bowser.setHP(2)
                end
                return
            end
            if p.forcedTimer == 0 then --if a forcedState timer isn't active, track player powerup
                playerData[p].curState = p.powerup
            end
            if p.forcedState == 2 then --if powering down, change it the custom state
                if playerData[p].curState == 2 and SaveData.useSWing == false then return end --cancel if the player is big
                if p.character == CHARACTER_BOWSER then return end --cancel if the player is big
                p.forcedState = anotherPowerDownLibrary.customForcedState
            end
            if p.forcedState == anotherPowerDownLibrary.customForcedState then --taken from modPlayer.bas, line 7477
                if p:mem(0x12E, FIELD_BOOL) == true then --ducking state, seemingly wouldn't work if using player.InDuckingPosition?
                    p:mem(0x132, FIELD_BOOL, true) --standing value?? seems to corrilates to .stand in modPlayer.bas, is player.Unknown132
                    p:mem(0x12E, FIELD_BOOL, false) --ducking state
                    p.height = ps.hitboxDuckHeight
                    p.y = p.y-32
                end
                p.forcedTimer = p.forcedTimer + 1
                if p.character ~= CHARACTER_BOWSER then --stops it from overwritting bowsers custom hurt animations
                    p.CurrentPlayerSprite = 1
                end
                if p.forcedTimer % 5 == 0 then
                    if p.powerup == 2 then
                        p.powerup = playerData[p].curState
                    else
                        p.powerup = 2
                    end
                end
                if p.forcedTimer >= 50 then
                    if p.powerup == playerData[p].curState then
                        p.powerup = 2
                    end
                    SaveData.useSWing = false
                    p.BlinkTimer = 150
                    p.BlinkState = true
                    p.forcedState = 0
                    p.forcedTimer = 0
                end
            end
        end
    end
end

return anotherPowerDownLibrary