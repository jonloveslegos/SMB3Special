local npcManager = require("npcManager")
local rng = require("rng")
local colliders = require("colliders")

local npc = {}
local npc_list = {1,2,71,244,3,379,389,616,618,4,5,6,7,72,73,76,161,303,304,36,307,89,27,466,467,172,173,174,175,176,177,29,390,13,291,265,171,155,165,166,167,162,163,285,286,48,380,431,416,382,383,409,408,77,407,109,110,111,112,113,114,115,116,117,118,119,120,194,154,155,156,157,134,19,20,25,130,131,132,470,471,129,530,374,135,261,144,92,141,139,140,142,145,143,146,241,249,22,202,352,39,262,201,15,86,267,268,617,136,137,9,90,612,611,30,184,186,153,200,280,281,357,368,369,301,426,189,415,296,309,446,448,365,185,26,31,32,457,187,190,125,127,126,128,531,532,623,624,242,243,578,579,54,53,168,472,666,273,59,61,63,65,451,454,452,453,238,158,425,58,35,191,193,433,434,278,279,562,563,375,293,358,164,320,321,311,312,313,314,315,316,317,318,271,195,427,107,403,102,404,405,489,254,250,94,75,101,198,95,98,99,100,148,149,150,228,325,326,327,328,329,330,331,332,182,183,277,264,14,169,170,34}
local hurt_list = {437,295,435,432,540,428,429}
local coin_list = {10,103,33,258,274,138,88,251,252,253,152}
local npcID = NPC_ID

local npcSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 32,
	width = 32,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 8,
	framestyle = 0,
	framespeed = 5,
	speed = 0.9,
    cliffturn = true,
	npcblock = false,
	
	nohurt=true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,	
    noiceball = true,
	noyoshi= true,
	nowaterphysics = false,
	jumphurt = true,
	wheight=160,
	Wdir=0
}

local config = npcManager.setNpcSettings(npcSettings)
npcManager.registerDefines(npcID, {NPC.HITTABLE})

function npc.onInitAPI()
	npcManager.registerEvent(npcID, npc, "onTickNPC")
end

function npc.onTickNPC(v)
	if Defines.levelFreeze then return end
	local config = NPC.config[v.id]
	local settings = v.data._settings
	local configSettings = settings
	local data = v.data._basegame
	local wheight = settings.wheight
	if not wheight then
		wheight = config.wheight
	end
	local Wdir = settings.Wdir
	if not Wdir then
		Wdir = config.Wdir
	end
	data.Wdir = Wdir
	data.wheight = wheight
	if v:mem(0x12A, FIELD_WORD) <= 0 then
		data.initialized = false
		return
	end
	
	if not data.initialized then
		v.friendly = true
		data.initialized = true
	end
	v.speedX = 0
    local effect = Animation.spawn(761, v.x, v.y)
	if data.Wdir == 0 then
		effect.speedY = rng.randomInt(-data.wheight / 20, -data.wheight / 15)
		effect.x = rng.randomInt(v.x-24,v.x+32)
		effect.y = effect.y+28
		effect.speedX = rng.randomInt(data.wheight / rng.randomInt(320,220), -data.wheight / rng.randomInt(320,220))
	end
	if data.Wdir == 2 then
		effect.speedY = -rng.randomInt(-data.wheight / 20, -data.wheight / 15)
		effect.x = rng.randomInt(v.x-24,v.x+32)
		effect.y = effect.y-12
		effect.speedX = rng.randomInt(data.wheight / rng.randomInt(320,220), -data.wheight / rng.randomInt(320,220))
	end
	if data.Wdir == 3 then
		effect.speedX = rng.randomInt(-data.wheight / 20, -data.wheight / 15)
		effect.y = rng.randomInt(v.y-24,v.y+32)
		effect.x = effect.x+36
		effect.speedY = rng.randomInt(data.wheight / rng.randomInt(320,220), -data.wheight / rng.randomInt(320,220))
	end
	if data.Wdir == 1 then
		effect.speedX = -rng.randomInt(-data.wheight / 20, -data.wheight / 15)
		effect.y = rng.randomInt(v.y-24,v.y+32)
		effect.x = effect.x-20
		effect.speedY = rng.randomInt(data.wheight / rng.randomInt(320,220), -data.wheight / rng.randomInt(320,220))
	end
	local yOff = 0
	local yWidth = 0
	local xWidth = 0
	local xOff = 0
	if data.Wdir == 0 then yOff = data.wheight end
	if data.Wdir == 2 then yOff = 0 end
	if data.Wdir == 1 then xOff = 0 end
	if data.Wdir == 3 then xOff = data.wheight end
	if data.Wdir == 0 then yWidth = data.wheight end
	if data.Wdir == 2 then yWidth = data.wheight end
	if data.Wdir == 1 then xWidth = data.wheight end
	if data.Wdir == 3 then xWidth = data.wheight end
	for _,p in ipairs(Player.get()) do
	    if SaveData.useSWing == false and colliders.collide(p, colliders.Box(v.x-xOff,v.y-yOff,v.width+xWidth,v.height+yWidth)) then
			if data.Wdir == 0 then p.speedY=p.speedY-0.5 end
			if data.Wdir == 2 then p.speedY=p.speedY+0.5 end
			if data.Wdir == 1 then p.speedX=p.speedX+0.5 end
			if data.Wdir == 3 then p.speedX=p.speedX-0.5 end
			if p.speedY < -6 then p.speedY = -6 end;
			if p.speedX < -6 then p.speedX = -6 end;
			if p.speedY > 6 then p.speedY = 6 end;
			if p.speedX > 6 then p.speedX = 6 end;
		end
	end
	
end

return npc