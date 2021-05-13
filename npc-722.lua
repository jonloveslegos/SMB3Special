local npcManager = require("npcManager")

local burnerLeft = {}
local npcID = NPC_ID
local AnimOffset = 0
local burnerLeftSettings = {
	id = npcID,
	gfxheight = 20,
	gfxwidth = 16,
	width = 16,
	height = 16,
	gfxoffsetx = 8,
	gfxoffsety = 8,
	frames = 2,
	framestyle = 1,
	framespeed = 8,
	speed = 1,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt=false,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi= false,
	nowaterphysics = false,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,
	staticdirection	=true,
	target = self,
	offset = 3,
}

local configFile = npcManager.setNpcSettings(burnerLeftSettings)

npcManager.registerDefines(npcID, {NPC.UNHITTABLE})

function burnerLeft.onInitAPI()
	npcManager.registerEvent(npcID, burnerLeft, "onTickNPC")
	npcManager.registerEvent(npcID, burnerLeft, "onDrawNPC")
end

function burnerLeft.onTickNPC(v)
	if Defines.levelFreeze then return end
	v.direction = -1
	local data = v.data
	data.locationsX = data.locationsX or {}
	data.locationsY = data.locationsY or {}
	data.x = data.x or v.x
	data.y = data.y or v.y
	v.target = v.target or v
	v.offset = v.offset or 3
	if v.target.isValid == false then 
		v:kill() 
		return
	end
	table.insert(data.locationsX,v.target.x)
	table.insert(data.locationsY,v.target.y)
	data.x = data.locationsX[tablelength(data.locationsX)-v.offset] or v.x
	data.y = data.locationsY[tablelength(data.locationsY)-v.offset] or v.y
	if data.x == nil then data.x = v.x end
	if data.y == nil then data.y = v.y end
	v.x = data.x
	v.y = data.y
end
function burnerLeft.onDrawNPC(v)
	if v.target.isValid == false then 
		v:kill() 
		return
	end
	v.animationFrame = v.target.animationFrame
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
--Gotta return the library table!
return burnerLeft