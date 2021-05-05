--------------------------------------------------------------------
--           Stone from Super Mario Maker 2 by Nintendo           --
--                    Recreated by IAmPlayer                      --
--------------------------------------------------------------------

local npcManager = require("npcManager")

local stone = {}
local npcID = NPC_ID

local stoneSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 4,
	framestyle = 0,
	framespeed = 8,
	speed = 1,
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = true,
	nogravity = false,
	noblockcollision = false,
	noiceball = true,
	noyoshi = false,
	grabside = true,
	grabtop = true,
}

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})
local configFile = npcManager.setNpcSettings(stoneSettings)

function stone.onInitAPI()
	npcManager.registerEvent(npcID, stone, "onStartNPC")
	npcManager.registerEvent(npcID, stone, "onTickNPC")
end

local originWalkSpeed
local originRunSpeed
local originJumpHeight
local originJumpBounce

function stone.onStartNPC(v)
	originWalkSpeed, originRunSpeed, originJumpHeight, originJumpBounce = Defines.player_walkspeed, Defines.player_runspeed, Defines.jumpheight, Defines.jumpheight_bounce
end

function stone.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
	if v:mem(0x12C, FIELD_WORD) > 0 then
		Defines.player_walkspeed = originWalkSpeed / 2
		Defines.player_runspeed = originRunSpeed / 2
		Defines.jumpheight = originJumpHeight / 6
		Defines.jumpheight_bounce = originJumpBounce / 6
	else
		Defines.player_walkspeed = originWalkSpeed
		Defines.player_runspeed = originRunSpeed
		Defines.jumpheight = originJumpHeight
		Defines.jumpheight_bounce = originJumpBounce
	end
	
	if v.collidesBlockBottom and v.speedX ~= 0 then
		if v.speedX > 0.1 then
			v.speedX = v.speedX - 1
		elseif v.speedX < 0.1 then
			v.speedX = v.speedX + 1
		end
	end
	
	--Interactions with P-Switch
	for _, s in ipairs(NPC.get(32)) do
		if Colliders.bounce(v, s) then
			s:kill()
			Misc.doPSwitch(true)
		end
	end
end

return stone