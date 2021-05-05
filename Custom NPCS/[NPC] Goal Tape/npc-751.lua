--[[

	Written by MrDoubleA
    Please give credit!
    
    Credit to Novarender for vastly improving the font used for character names

	Part of MrDoubleA's NPC Pack

]]

local npcManager = require("npcManager")
local ai = require("goalTape_ai")


local goalTape = {}
local npcID = NPC_ID

local COLLISION_TYPE_TOUCH        = 0 -- (SMM)  Needs to touch the actual NPC to trigger the level exit.
local COLLISION_TYPE_TOUCH_REGION = 1 -- (SMM2) Needs to touch its "patrolling" region to trigger the level exit.
local COLLISION_TYPE_TOUCH_ABOVE  = 2 -- (SMW)  Needs to touch anywhere above the bottom of the "patrolling" region to trigger the level exit.

local goalTapeSettings = {
	id = npcID,
	
	gfxwidth = 64,
	gfxheight = 16,

	gfxoffsetx = 0,
	gfxoffsety = 0,
	
	width = 48,
	height = 16,
	
	frames = 1,
	framestyle = 1,
	framespeed = 8,
	
	speed = 1,
	
	npcblock = false,
	npcblocktop = false,
	playerblock = false,
	playerblocktop = false,

	nohurt = true,
	nogravity = true,
	noblockcollision = true,
	nofireball = false,
	noiceball = false,
	noyoshi = true,
	nowaterphysics = true,
	
	jumphurt = false,
	spinjumpsafe = false,
	harmlessgrab = false,
    harmlessthrown = false,
    
    --notcointransformable = true,
    --iscollectablegoal = true,
    
    movementSpeed = 2, -- How fast the goal tape moves up and down.
    requiredCollisionType = COLLISION_TYPE_TOUCH_ABOVE, -- Where the player must touch the goal tape to activate it. It can be 0 to act like SMM, it can be 1 to act like SMM2, or it can be 2 to act like SMW.

    doDarken = true,  -- Whether or not everything is darkened during the exit animation.
    doIrisOut = true, -- Whether or not there's an iris out effect to exit the level.

    victoryPose = nil,        -- The "victory pose" used. Can be nil for none, or a number for a specific frame (see http://i.imgur.com/1dnW3g3.png for a list).
    victoryPoseOnYoshi = nil, -- The "victory pose" used when on a yoshi.

    mainSFX = SFX.open(Misc.resolveFile("goalTape_main.ogg")),       -- The sound played when hitting the goal tape. Can be nil for none, a number for a vanilla sound, or a sound effect object/string for a custom sound.
    irisOutSFX = SFX.open(Misc.resolveFile("goalTape_irisOut.ogg")), -- The sound used for the iris out. Can be nil for none, a number for a vanilla sound, or a sound effect object/string for a custom sound.

    heldNPCsTransform = true, -- Whether or not an NPC being held will transform when hitting the goal.
    
    -- Results
    displayCharacterName = true, -- Whether or not the character's name is displayed with the results.
    displayCourseClear = true,   -- Whether or not the "course clear" text is displayed with the results.
    doTimerCountdown = true,     -- Whether or not to do the countdown of the timer, if the timer is enabled.

    timerScoreMultiplier = 50, -- How many points each timer second is worth.
    timerCountdownSpeed = 128, -- How many frames it takes to count down the timer.

    -- The sound effects using for the timer countdown. Can be nil for none, a number for a vanilla sound, or a sound effect object/string for a custom sound.
    countdownStartSFX = SFX.open(Misc.resolveFile("goalTape_countdown_start.wav")),
    countdownLoopSFX  = SFX.open(Misc.resolveFile("goalTape_countdown_loop.wav")),
    countdownEndSFX   = SFX.open(Misc.resolveFile("goalTape_countdown_end.wav")),
}

npcManager.setNpcSettings(goalTapeSettings)
npcManager.registerDefines(npcID,{NPC.UNHITTABLE})
npcManager.registerHarmTypes(npcID,{HARM_TYPE_OFFSCREEN},{})

ai.register(npcID)

return goalTape