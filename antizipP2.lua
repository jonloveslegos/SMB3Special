local az = {}

az.enabled = true
local playerx
local stuckTimer = 0
local stuckx
az.lastPlayerX = 0
local hasPressedDown = false
local wasOnSlope = false
local unduckCollider = Colliders.Box(0,0,0,0)
local regularPlayerHeight = 0
local duckingPlayerHeight = 0
local lastCharacter = nil
local lastPowerup = nil
local lastForcedState = 0
local isDuckPowering = false
local previousY = 0
local freezeState = {
    [1] = true,
    [2] = true,
    [4] = true,
    [5] = true,
    [11] = true,
    [12] = true,
    [41] = true,
}

local function blockcheck(offset)
	local y = playerx.y
	local blocks = Block.getIntersecting(playerx.x, y + offset, playerx.x + playerx.width, y + offset + playerx.height)
	local goodblocks = {}
	for k,v in ipairs(blocks) do
		if (Block.SOLID_MAP[v.id] or Block.PLAYERSOLID_MAP[v.id]) and (not v.isHidden) and v:mem(0x5C, FIELD_WORD) == 0 then
			if Colliders.collide(playerx, v) then
				table.insert(goodblocks, v)
			end
		end
	end
	return #goodblocks > 0, goodblocks
end

local function miniBlockCheck(x1, y1, blocks)
	local collisionZone = Colliders.Box(x1, y1, playerx.width, playerx.height)

	for k,v in ipairs(blocks) do
		if (not Block.SLOPE_MAP[v.id]) and Colliders.collide(collisionZone, v) then
			return true
		end
	end
	return false
end

local function expandBlockChecks()
    if wasOnSlope ~= 0 then return false end

    local x1 = playerx.x - 8
    local y1 = playerx.y - 8
    local x2 = playerx.x + playerx.width + 8
    local y2 = playerx.y + playerx.height + 8
    local blocks = Colliders.getColliding{
        a = Colliders.Box(x1, y1, playerx.width + 16, playerx.height + 16),
        b = Block.SOLID .. Block.PLAYERSOLID,
        btype = Colliders.BLOCK,
        filter = function(other)
            if other.isHidden then return false end
            if other:mem(0x5A, FIELD_WORD) == -1 then return false end
            if other:mem(0x1C, FIELD_WORD) == -1 then return false end
            if other:mem(0x1C, FIELD_WORD) == -1 then return false end
            return true
        end
    }
    x1 = x1 - playerx.width
    y1 = y1 - playerx.height
    --[[local dodged = false
    for i=x1, x2, 2 do
        for j=y1, y2, 2 do
            if not miniBlockCheck(i, j, blocks) then
                if dodged then
                    local xw, yh = playerx.x, playerx.y
                    local vec = vector(i-xw, j-yh)
                    if vec.sqrlength < vector(dodged.x-xw, dodged.y-yh).sqrlength then
                        dodged = vector(i,j)
                    end
                else
                    dodged = vector(i,j)
                end
            end
        end
    end
    if not dodged then
        return true
    else
        
        playerx.x = dodged.x
        playerx.y = dodged.y
        isStuckAtAll = false
        return true
    end-]]
	return true
end

local function unstuck(px)
	local isStuckAtAll, defaults = blockcheck(0)
	if not isStuckAtAll and playerx.deathTimer == 0 then
		stuckx = nil
		return false
	end
	return expandBlockChecks()
end

function az.onInitAPI()
    registerEvent(az, "onTickEnd")
    registerEvent(az, "onDrawEnd")
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function az.onDrawEnd()
        if player2 == nil then return else playerx = player2 end
        previousY = playerx.y
        if isDuckPowering then
            previousY = previousY - duckingPlayerHeight
        end
end

function az.onTickEnd()
        if player2 == nil then return else playerx = player2 end
        if not az.enabled then return end
        if freezeState[playerx.forcedState] then
            if hasPressedDown then
                playerx.y = previousY + duckingPlayerHeight
                playerx:mem(0xD0, FIELD_DFLOAT, 14)
                hasPressedDown = true
                isDuckPowering = true
            end
            playerx.downKeyPressing = hasPressedDown
        end

        if playerx.character ~= lastCharacter or (playerx.powerup ~= lastPowerup and lastForcedState ~= playerx.forcedState) then
            local ps = playerx:getCurrentPlayerSetting()
            lastCharacter = playerx.character
            lastPowerup = playerx.powerup
            regularPlayerHeight = ps.hitboxHeight
            unduckCollider.width = playerx.width
            unduckCollider.height = ps.hitboxDuckHeight
        end

        lastForcedState = playerx.forcedState
        if hasPressedDown and playerx.forcedState == 0 then
            unduckCollider.x = playerx.x
            unduckCollider.y = playerx.y + playerx.height - regularPlayerHeight
            local _, _, blocks = Colliders.collideBlock(unduckCollider, Colliders.BLOCK_SOLID)
            local cancel = false
            for k,v in ipairs (blocks) do
                if not v.isHidden then
                    cancel = true
                    break
                end
            end
            if cancel then
                playerx.keys.down = true
                playerx:mem(0x12E, FIELD_WORD, -1)
            end
        end
        --[[if (not Defines.cheat_shadowmario) and playerx.deathTimer == 0 and playerx.forcedState == 0 and #Colliders.getColliding{
		    a = playerx,
		    b = Block.SOLID,
		    btype = Colliders.BLOCK,
		    filter = function(other)
			    if other.isHidden then return false end
			    if other:mem(0x5A, FIELD_WORD) == -1 then return false end
			    if other:mem(0x1C, FIELD_WORD) == -1 then return false end
			    if other:mem(0x5C, FIELD_WORD) == -1 then return false end
			    return true
		    end
        } > 0 then
		    if stuckx == nil then
			    stuckx = lastPlayerX
		    end
		    stuckTimer = stuckTimer + 1
		    local px = playerx.x
		    playerx.x = stuckx
		    if stuckTimer >= 1 then
			    if not unstuck(px) then
				    playerx.x = px
			    end
		    end
	    else
		    stuckTimer = 0
		    stuckx = nil
	    end--]]
	    lastPlayerX = playerx.x
        wasOnSlope = playerx:mem(0x48, FIELD_WORD)
		
        if playerx.forcedState == 0 then
            if isDuckPowering then
                playerx.y = playerx.y - duckingPlayerHeight
            end
            isDuckPowering = false
            hasPressedDown = playerx.downKeyPressing
        end
        
end

return az