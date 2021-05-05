local npcManager = require("npcManager")

local OneWayBillCannon = {}
local npcID = NPC_ID

local OneWayBillCannonSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 1,
	speed = 0,
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
	nowaterphysics = true,
	--Various interactions
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = true,
	shootrate = 130
}

npcManager.setNpcSettings(OneWayBillCannonSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})

function OneWayBillCannon.onInitAPI()
	npcManager.registerEvent(npcID, OneWayBillCannon,"onTickNPC")
end

function OneWayBillCannon.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.waitingframe = 0
		return
	end

	if data.waitingframe == nil then
		data.waitingframe = 0
	end

	if v:mem(0x12C, FIELD_WORD) > 0
	or v:mem(0x136, FIELD_BOOL)
	or v:mem(0x138, FIELD_WORD) > 0
	then
		data.waitingframe = 0
	else
		data.waitingframe = data.waitingframe + 1
	end
	if data.waitingframe > NPC.config[npcID].shootrate then
		v1 = NPC.spawn(17,v.x,v.y+2,player.section)
		if player2 then
			if player.section ~= player2.section then
				v2 = NPC.spawn(17,v.x,v.y+2,player2.section)
			end
		end
		v1.direction = v.direction
		Animation.spawn(10,v.x,v.y)
		SFX.play(22)
		data.waitingframe = 0
	end
end

return OneWayBillCannon