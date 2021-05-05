local npcManager = require("npcManager")

local GreenSpringboard = {}
local npcID = NPC_ID

local GreenSpringboardSettings = {
	id = npcID,
	gfxwidth = 32,
	gfxheight = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	speed = 0,
	framespeed = 10,
	npcblock = true,
	npcblocktop = true,
	playerblock = true,
	playerblocktop = true,
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
	harmlessthrown = false,
	reverseBounced = false,
	bounced = false,
	blockID = 293,
	hitSound = SFX.open("block-hit.ogg"),
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
	v.data.xStart = v.data.xStart or v.x
	v.x = v.data.xStart
	v.data.frames = v.data.frames or 0
	settings = NPC.config[v.id]
	v.data.bounced = v.data.bounced or false
	v.data.reverseBounced = v.reverseBounced or false
	v.data.reverseframe = v.reverseframe or false
	if v.data.setup == false then
		local blk = Block.spawn(854,v.x,v.y)
		blk.contentID = -1
		v.isHidden = false
		v.data.setup = true
	end
	if v.data.frames == 0 then
		v.data.frames = 0
		v.data.bounced = false
		v.data.reverseBounced = false
		v.data.reverseframe = false
		
	end
	if v.data.bounced == false and Colliders.speedCollide(player,v) and player.speedX > 1 and player.x <= v.x - (player.width/2) and player.y+player.height-2 >= v.y then
		v.data.bounced = true
		player.speedX = -1.2
		SFX.play(SFX.open("block-hit.ogg"))
	end
	if v.data.reverseBounced == false and Colliders.speedCollide(player,v) and player.speedX < -1 and player.x >= v.x and player.y+player.height-2 >= v.y then
		v.data.reverseBounced = true
		player.speedX = 1.2
		SFX.play(SFX.open("block-hit.ogg"))
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
				v.isHidden = true
				if tablelength(Block.getIntersecting(v.x,v.y,v.x+8,v.y+8)) > 0 then
						Block.getIntersecting(v.x,v.y,v.x+8,v.y+8)[1].isHidden = false
				end
				v:delete()
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
					v.isHidden = true
					if tablelength(Block.getIntersecting(v.x,v.y,v.x+8,v.y+8)) > 0 then
						Block.getIntersecting(v.x,v.y,v.x+8,v.y+8)[1].isHidden = false
					end
					v:delete()
				end
			end
	end
	v.reverseBounced = v.data.reverseBounced or false
	v.reverseframe = v.data.reverseframe or false
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function GreenSpringboard.onDrawNPC(v)
	local data = v.data
	v.data.xStart = v.data.xStart or v.x
	v.data.frames = v.data.frames or 0
	v.x = v.data.xStart+(v.data.frames*4)
end

return GreenSpringboard
