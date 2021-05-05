--[[

	Written by MrDoubleA
	Please give credit!

	Concept from WhiteYoshiEgg (https://www.smwcentral.net/?p=section&a=details&id=20835)
	Graphics for red/flower pipe improved by Novarender

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local clearpipe = require("blocks/ai/clearpipe")

local ai = require("carryablePipe_ai")

local carryablePipe = {}
local npcID = NPC_ID

local carryablePipeSettings = {
	id = npcID,
	
	gfxwidth = 32,
	gfxheight = 32,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 32,
	height = 32,
	
	frames = 1,
	framestyle = 0,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = true,
	npcblocktop = false,
	playerblock = true,
	playerblocktop = true,

	nohurt = true,
	nogravity = false,
	noblockcollision = false,
	nofireball = true,
	noiceball = true,
	noyoshi = false,
	nowaterphysics = false,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = true,
	harmlessthrown = true,

	grabside = true,
	grabtop = false,

	-- Carryable Pipe Configurations
	enterSpeed = 8,
	exitSpeed = 8,

	launchSpeed = 4,

	cameraMovementSpeed = 24,
	
	conserveXSpeed = false,
}

npcManager.setNpcSettings(carryablePipeSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})
npcManager.registerHarmTypes(npcID,{},{})

clearpipe.registerNPC(npcID)

ai.registerCarryablePipe(npcID)

return carryablePipe