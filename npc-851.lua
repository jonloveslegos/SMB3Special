local npcManager = require("npcManager")

local npc = {}
local npcID = NPC_ID

local npcSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	frames = 1,
	framestyle = 0,
	framespeed = 1,
	speed = 0,
	playerblock = true,
	playerblocktop = true,
	npcblock = true,
	npcblocktop = true,
	nohurt = true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = false,
	noyoshi= true,
	noshell= true,
	nohammer= true,
	nowaterphysics = false,
	jumphurt = true,
	timer = 150
}

local configuration = npcManager.setNpcSettings(npcSettings)
npcManager.registerDefines(npcID, {NPC.HITTABLE})

function npc.onStartNPC(v)
    v.dontMove = true
	if v:mem(0xDE, FIELD_WORD) == 0 then
	    v:mem(0xDE, FIELD_WORD, 752)
	end	
end

function npc.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		data.initialized = true
	end
	
    if data.waiter == nil then
	    data.waiter = 0
	end
	data.waiter=data.waiter+1
	if data.waiter == configuration.timer then
	    SFX.play(37)
        local effect = Animation.spawn(131,v.x+32*v.direction,v.y)
		local bullet = NPC.spawn(v:mem(0xDE, FIELD_WORD), v.x+32*v.direction, v.y, player.section)	
        bullet.direction = v.direction
        bullet.speedX = 4 * v.direction
	    if bullet.height > 32 then
			bullet.y=v.y-bullet.height/2
        end		
	    if v:mem(0xDE, FIELD_WORD) == 754 then
	        bullet.speedY=4
        elseif v:mem(0xDE, FIELD_WORD) == 755 then
		    bullet.speedY=-4
		end
        data.waiter = 0		
	end
	if data.state == nil then
	    data.state = 0
	end
	if data.state > 5 then
	    data.state = 5
	end
	if v.collidesBlockBottom == false then
	    data.state=data.state+1
	end
	if v.collidesBlockBottom and data.state == 5 then
	    SFX.play(37)
		data.state=0
		local effect1 = Animation.spawn(131,v.x,v.y)
		local effect2 = Animation.spawn(131,v.x,v.y)
		effect1.speedX=-3
		effect2.speedX=3
	end
end

function npc.onInitAPI()
	npcManager.registerEvent(npcID, npc, "onTickNPC")
	npcManager.registerEvent(npcID, npc, "onStartNPC")	
end

return npc