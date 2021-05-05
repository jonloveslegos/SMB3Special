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

local spurtID = (npcID+1)

local volcanoLotusSettings = {
	id = npcID,
	
	gfxwidth = 32,
	gfxheight = 64,
	gfxoffsetx = 0,
	gfxoffsety = 0,

	width = 32,
	height = 64,

	frames = 4,
	framestyle = 1,
	framespeed = 8,

	speed = 1,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = false,
	nogravity = true,
	noblockcollision = true,
	nofireball = true,
	noiceball = true,
	noyoshi = false,
	nowaterphysics = true,
	
	jumphurt = true,
	spinjumpsafe = true,
	harmlessgrab = false,
	harmlessthrown = false,

	-- Volcano Lotus configuration options

	idleTime  = 170,          -- How long the NPC is in its idle state.
    flashTime = 70,           -- How long the NPC is in its flashing state.
    spurtTime = 50,           -- How long the NPC is in its spurting state.

    spurtNPCID     = spurtID, -- ID of the NPCs spawned when spurting.
    spurtNPCSpawns = 4,       -- How many NPCs are spawned when spurting.

	isHorizontal = true,      -- Whether or not this NPC is horizontal.
	isWinged = false,         -- Whether or not this NPC can fly around and chase the player.
}

npcManager.setNpcSettings(volcanoLotusSettings)
npcManager.registerDefines(npcID,{NPC.HITTABLE})
npcManager.registerHarmTypes(npcID,
	{
		HARM_TYPE_NPC,
		HARM_TYPE_HELD,
		HARM_TYPE_TAIL,
		HARM_TYPE_OFFSCREEN,
		HARM_TYPE_SWORD
	}, 
	{
		[HARM_TYPE_NPC]=10,
		[HARM_TYPE_HELD]=10,
		[HARM_TYPE_TAIL]=10,
	}
)

ai.registerVolcanoLotus(npcID)

return volcanoLotus