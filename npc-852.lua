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

function npc.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end

	if not data.initialized then
		v.speedX=4*v.direction
		data.initialized = true
	end

end

function npc.onNPCHarm(_,v,_,_)
    if v.id == npcID then
	    local effect = Animation.spawn(752, v.x, v.y)
    end		
end

function npc.onInitAPI()
	npcManager.registerEvent(npcID, npc, "onTickNPC")	
	registerEvent(npc, "onNPCHarm")	
end

return npc