local npcManager = require("npcManager")

local burnerLeft = {}
local npcID = NPC_ID
local AnimOffset = 0
local burnerLeftSettings = {
	id = npcID,
	gfxheight = 32,
	gfxwidth = 64,
	width = 64,
	height = 32,
	gfxoffsetx = 0,
	gfxoffsety = 0,
	frames = 4,
	framestyle = 0,
	framespeed = 0,
	speed = 1,
	
	npcblock = true,
	npcblocktop = true,
	playerblock = false,
	playerblocktop = false,

	nohurt=true,
	nogravity = true,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi= true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	staticdirection	=true,
}

local configFile = npcManager.setNpcSettings(burnerLeftSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

function burnerLeft.onInitAPI()
	npcManager.registerEvent(npcID, burnerLeft, "onStartNPC")
	npcManager.registerEvent(npcID, burnerLeft, "onTickNPC")
	npcManager.registerEvent(npcID, burnerLeft, "onDrawNPC")
end

local DIR_ON = -1
local DIR_OFF = 1
function burnerLeft.onDrawNPC(v)
	v.animationFrame = math.floor(AnimOffset)
	
end
function burnerLeft.onStartNPC(v)
	local data = v.data
end

function burnerLeft.onTickNPC(v)
	if Defines.levelFreeze then return end
	
	local data = v.data
	data.width = data.width or NPC.config[v.id].gfxwidth
	data.height = data.height or NPC.config[v.id].gfxheight
	data.speedX = data.speedX or v.speedX
	if data.speedX > 0 then
		data.speedX = data.speedX-0.2
		if data.speedX < 0 then data.speedX = 0 end
	elseif data.speedX < 0 then
		data.speedX = data.speedX+0.2
		if data.speedX > 0 then data.speedX = 0 end
	end
	if tablelength(Player.getIntersecting(v.x,v.y-1,v.x+data.width,v.y+data.height)) > 0 and player.speedY >= 0 then
		data.speedX = data.speedX+0.4
		if player.speedY > 0 then player.speedY = 0 end
		player.y = player.y+1
		if data.speedX > 3 then data.speedX = 3 end
		if data.speedX < -3 then data.speedX = -3 end
		AnimOffset = AnimOffset+(0.1*data.speedX)
		if AnimOffset > 3.4 then AnimOffset = 0 end
	end
	if tablelength(Player.getIntersecting(v.x,v.y-1,v.x+data.width,v.y+data.height)) > 0 and player.speedY < 0 then
		data.speedX = data.speedX-0.4
		if data.speedX > 3 then data.speedX = 3 end
		if data.speedX < -3 then data.speedX = -3 end
		AnimOffset = AnimOffset+(0.1*data.speedX)
		if AnimOffset > 3.4 then AnimOffset = 0 end
	end
	if AnimOffset < 0 then AnimOffset = 3.4 end
	if data.speedX > 3 then data.speedX = 3 end
	if data.speedX < -3 then data.speedX = -3 end
	v.speedX = data.speedX
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
--Gotta return the library table!
return burnerLeft