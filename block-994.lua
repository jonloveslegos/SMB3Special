local blockmanager = require("blockmanager")
local elementals = require("blocks/ai/elementalblocks")
local blockutils = require("blocks/blockutils")

local blockID = BLOCK_ID

local block = {}


blockmanager.setBlockSettings({
	id = blockID,
	customhurt = true
})


function block.onStartBlock(v)
	blockutils.storeContainedNPC(v)
end

elementals.register(blockID, "iscold")

function block.onInitAPI()
    blockmanager.registerEvent(blockID, block, "onStartBlock")
end

return block