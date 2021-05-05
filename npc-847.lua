local npcManager = require("npcManager")
local rng = require("rng")
local smallSwitch = require("npcs/ai/smallswitch")
local whistle = require("npcs/ai/whistle")

local TouchFallPlat = {}
local npcID = NPC_ID
local DIR_NEG = -1
local DIR_BOTH = 0
local DIR_POS = 1
local stompSound = SFX.create{x=0,y=0,falloffRadius=128,sound="thwomp.ogg",loops=1}
local TouchFallPlatSettings = {
	id = npcID,
	width = 48,
	height = 64,
	gfxwidth = 48,
	gfxheight = 64,
	nogravity = true,
	frames = 1,
	framestyle = 0,
	speed = 1,
	nohurt = false,
	jumphurt = true,
	spinjumpsafe = true,
	nofireball = true,
	noiceball = true,
	noyoshi = true,
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,
	nowaterphysics = true,

	isheavy = 2,

	moveSpeed = 2,
	cooldown = 100
}

npcManager.setNpcSettings(TouchFallPlatSettings)
npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

local collidesBlockBottom = 0x0A --"collidesBlockBottom"
local collidesBlockUp     = 0x0E --"collidesBlockUp"

local collidesBlockRight = 0x120 --"collidesBlockRight"
local collidesBlockLeft     = 0x120 --"collidesBlockLeft"

function TouchFallPlat.onInitAPI()
	npcManager.registerEvent(npcID, TouchFallPlat, "onTickNPC")
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function TouchFallPlat.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	data.stomped = data.stomped or false
	data.stompTimer = data.stompTimer or 0
	data.dir = data.dir or 1
	data.MoveDir = data.MoveDir or v.direction

	if data.stompTimer <= 0 then
		if data.dir == 1 then
			v.speedX = (TouchFallPlatSettings.moveSpeed)*data.MoveDir
			v.speedY = TouchFallPlatSettings.moveSpeed
			local castbox = Colliders.getHitbox(v)
			castbox.height = castbox.height + math.abs(v.speedY)
			if v.speedY < 0 then
				castbox.y = castbox.y + v.speedY
			end
			castbox.width = castbox.width + math.abs(v.speedX)
			if v.speedX < 0 then
				castbox.x = castbox.x + v.speedX
			end
			local blocks = Colliders.getColliding{
				a = castbox,
				b = Block.SOLID,
				btype = Colliders.BLOCK
			}
			if tablelength(blocks) > 0 then
				v.speedX = 0
				v.speedY = 0
				data.stompTimer = TouchFallPlatSettings.cooldown
				SFX.play(stompSound)
				data.dir = -1
			end
		elseif data.dir == -1 then
			v.speedX = (-TouchFallPlatSettings.moveSpeed)*data.MoveDir
			v.speedY = -TouchFallPlatSettings.moveSpeed
			local castbox = Colliders.getHitbox(v)
			castbox.height = castbox.height + math.abs(v.speedY)
			if v.speedY < 0 then
				castbox.y = castbox.y + v.speedY
			end
			castbox.width = castbox.width + math.abs(v.speedX)
			if v.speedX < 0 then
				castbox.x = castbox.x + v.speedX
			end
			local blocks = Colliders.getColliding{
				a = castbox,
				b = Block.SOLID,
				btype = Colliders.BLOCK
			}
			if tablelength(blocks) > 0 then
				v.speedX = 0
				v.speedY = 0
				data.stompTimer = TouchFallPlatSettings.cooldown
				SFX.play(stompSound)
				data.dir = 1
			end
		end
	else
		data.stompTimer = data.stompTimer-1
	end

end

return TouchFallPlat