local npcManager = require("npcManager")

local npc = {}
local npcID = NPC_ID

local npcSettings = {
	id = npcID,
	gfxheight = 28,
	gfxwidth = 32,
	width = 32,
	height = 28,
	frames = 1,
	framestyle = 1,
	framespeed = 1,
	speed = 1,
	nohurt = false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = false,
	noyoshi= false,
	noshell= false,
	nohammer= false,
	nowaterphysics = false
}

npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_JUMP,
		--HARM_TYPE_FROMBELOW,
		--HARM_TYPE_NPC,
		--HARM_TYPE_PROJECTILE_USED,
		--HARM_TYPE_LAVA,
		--HARM_TYPE_HELD,
		--HARM_TYPE_TAIL,
		--HARM_TYPE_SPINJUMP,
		--HARM_TYPE_OFFSCREEN,
		--HARM_TYPE_SWORD
	}, 
	{
		--[HARM_TYPE_JUMP]=10,
		--[HARM_TYPE_FROMBELOW]=10,
		--[HARM_TYPE_NPC]=10,
		--[HARM_TYPE_PROJECTILE_USED]=10,
		--[HARM_TYPE_LAVA]={id=13, xoffset=0.5, xoffsetBack = 0, yoffset=1, yoffsetBack = 1.5},
		--[HARM_TYPE_HELD]=10,
		--[HARM_TYPE_TAIL]=10,
		--[HARM_TYPE_SPINJUMP]=10,
		--[HARM_TYPE_OFFSCREEN]=10,
		--[HARM_TYPE_SWORD]=10,
	}
);
npcManager.setNpcSettings(npcSettings)
npcManager.registerDefines(npcID, {NPC.HITTABLE})

function npc.onStartNPC(v)
    v.speedX=4*v.direction
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
    --Chase player
	if player.x > v.x then
		v.speedX = v.speedX + 0.2*1
	elseif player.x < v.x then
		v.speedX = v.speedX + 0.2*-1
	end
	if v.speedX > 4 then
	    v.speedX=4
	elseif v.speedX < -4 then
	    v.speedX=-4	
	end
	--Smoke Effect
	if data.waiter == nil then
	    data.waiter = 0
	end
	data.waiter = data.waiter+1
	if data.waiter == 5 then
	    if v.direction == -1 then
	        local effect = Animation.spawn(74, v.x+24, v.y+10)
		    effect.speedX=1
        else
	        local effect = Animation.spawn(74, v.x-1, v.y+10)
		    effect.speedX=-1		
	    end
		data.waiter=0
	end
end

function npc.onNPCHarm(_,v,_,_)
    if v.id == npcID then
	    local effect = Animation.spawn(753, v.x, v.y)
    end		
end

function npc.onInitAPI()
	npcManager.registerEvent(npcID, npc, "onStartNPC")	
	npcManager.registerEvent(npcID, npc, "onTickNPC")	
	registerEvent(npc, "onNPCHarm")	
end

return npc