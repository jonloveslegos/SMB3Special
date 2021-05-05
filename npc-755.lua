local npcManager = require("npcManager")

local GreenSpringboard = {}
local npcID = NPC_ID
local hitPlayer = false
local GreenSpringboardSettings = {
	id = npcID,
	gfxwidth = 32,
	gfxheight = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 4,
	speed = 0,
	framespeed = 10,
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = false,
	nohurt=true,
	nogravity = true,
	noblockcollision = false,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false
}
npcManager.setNpcSettings(GreenSpringboardSettings)
npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

npcManager.registerHarmTypes(npcID,{HARM_TYPE_LAVA},{[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5}})

function GreenSpringboard.onInitAPI()
	npcManager.registerEvent(npcID, GreenSpringboard, "onTickNPC")
	npcManager.registerEvent(npcID, GreenSpringboard, "onDrawNPC")
end

function GreenSpringboard.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	v.data.setup = v.data.setup or false
	v.data.block = v.data.block or nil
	v.data.yStart = v.data.yStart or v.y
	v.y = v.data.yStart
	v.data.frames = v.data.frames or 0
	v.data.bounced = v.data.bounced or false
	v.data.reverseBounced = v.data.reverseBounced or false
	v.data.reverseframe = v.data.reverseframe or false
	if v.data.setup == false then
		v.data.block = Block.spawn(55,v.x,v.y)
		v.data.block:mem(0x5A,FIELD_BOOL,true)
		v.isHidden = true
		v.data.setup = true
	end
	if v.data.block ~= nil then
		if v.data.block:mem(0x5A,FIELD_BOOL) == false then
			v.data.block.isHidden = true
			v.data.block = nil
			v.data.frames = 0
			v.data.bounced = false
			v.data.reverseBounced = false
			v.data.reverseframe = false
			v.isHidden = false
		end
	end
	if v.data.frames == 0 then
		v.data.frames = 0
		v.data.bounced = false
		v.data.reverseBounced = false
		v.data.reverseframe = false
	end
	if (not NPC.config[npcID].playerblocktop) then
		if Colliders.speedCollide(player,v) and player.speedY > 1 and player.y <= v.y - (player.height/2) then
			if player.jumpKeyPressing or player.altJumpKeyPressing then
				player.speedY = -60
				player.speedX = 0
				player.x = v.x
				hitPlayer = true
			else
				player.speedY = -10
			end
			v.data.bounced = true
			SFX.play(24)
		end
		if Colliders.speedCollide(player,v) and player.speedY <= 0 and player.y >= v.y then
			v.data.reverseBounced = true
			SFX.play(24)
		end
	end
	if hitPlayer == true and player.section == Section.getFromCoords(v.x, v.y, 32, 32) then 
		player.speedX = 0
		player.x = v.x
	end
	if v.data.bounced then
		if not v.data.reverseframe then
			if v.data.frames < 3 then
				v.data.frames = v.data.frames + 1
			else
				v.data.reverseframe = true
			end
		else
			if v.data.reverseframe and v.data.frames > 0 then
				v.data.frames = v.data.frames - 1
			else
				v.data.reverseframe = false
				v.data.bounced = false
			end
		end
		
	end
	if v.data.reverseBounced then
			if not v.data.reverseframe then
				if v.data.frames > -3 then
					v.data.frames = v.data.frames - 1
				else
					v.data.reverseframe = true
				end
			else
				if v.data.reverseframe and v.data.frames < 0 then
					v.data.frames = v.data.frames + 1
				else
					v.data.reverseframe = false
					v.data.reverseBounced = false
				end
			end
	end
end

function GreenSpringboard.onDrawNPC(v)
	v.y = v.data.yStart+(v.data.frames*4)
end

return GreenSpringboard
