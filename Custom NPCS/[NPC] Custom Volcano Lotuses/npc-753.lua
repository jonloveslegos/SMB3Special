--[[

	Written by MrDoubleA
	Please give credit!

	Flying Volcano Lotus concept from Darolac (https://www.smwcentral.net/?p=section&a=details&id=20527)

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local ai = require("volcanoLotus_ai")

local volcanoLotus = {}
local npcID = NPC_ID

local volcanoLotusSettings = {
	id = npcID,
	
	gfxwidth = 16,
	gfxheight = 16,
	gfxoffsetx = 0,
	gfxoffsety = 0,

	width = 16,
	height = 16,

	frames = 2,
	framestyle = 0,
	framespeed = 7,

	speed = 1,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = false,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = true,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,

	-- Volcano Lotus Fireball configuration options

    gravity = 0.02,       -- How fast the NPC gains downward speed.
    terminalVelocity = 2, -- Max downwards speed for the NPC.

    trembleSpeed = 0.8,   -- How fast the NPC moves back and forth.
}

npcManager.setNpcSettings(volcanoLotusSettings)
npcManager.registerDefines(npcID,{NPC.HITTABLE})
npcManager.registerHarmTypes(npcID,{HARM_TYPE_OFFSCREEN},{})

ai.registerFireball(npcID)

return volcanoLotus