--[[

	Written by MrDoubleA
	Please give credit!

    Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local lineguide = require("lineguide")

local ai = require("seesaw_ai")

local seesaw = {}
local npcID = NPC_ID

local solidBlockID      = 1007
local leftSlopeBlockID  = 851
local rightSlopeBlockID = 852

local seesawSettings = {
	id = npcID,
	
	gfxwidth = 32,
	gfxheight = 32,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 32,
	height = 32,
	
	frames = 4,
	framestyle = 0,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = false,
	npcblocktop = false, --Misnomer, affects whether thrown NPCs bounce off the NPC.
	playerblock = false,
	playerblocktop = false, --Also handles other NPCs walking atop this NPC.

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi = true,
	nowaterphysics = true,

	ignorethrownnpcs = true,
	
	jumphurt = true, -- Since nohurt is set, this just prevents the player from jumping on it
	spinjumpsafe = false,
	harmlessgrab = false,
	harmlessthrown = false,


	isWeightBased = false, -- Whether or not the NPC's rotation is affected by objects on top of it.

	solidBlockID      = solidBlockID     , -- The ID of the block used when the platform is completely straight.
	leftSlopeBlockID  = leftSlopeBlockID , -- The ID of the block used when the platform is titled to the left.
	rightSlopeBlockID = rightSlopeBlockID, -- The ID of the block used when the platform is tilted to the right.

	debug = false, -- Enables a few debug features.
}

npcManager.setNpcSettings(seesawSettings)
npcManager.registerHarmTypes(npcID,{HARM_TYPE_OFFSCREEN},{})

lineguide.registerNpcs(npcID)
lineguide.properties[npcID] = {
	activeByDefault = true,
	extendedDespawnTimer = true,
	lineSpeed = 2,
	jumpSpeed = 4,
}

ai.register(npcID)

return seesaw