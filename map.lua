local inventory = require("customInventory")
levelEnterFileName = nil
levelEnter = nil
levelEnterX = nil
levelEnterY = nil
levelEnterfilename = nil
local LevelName
local starcoin
local stamps
local playerStart = true
local warned = false
SaveData.power = player.powerup
local starCoinEmptyicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/starCoinEmpty.png"))
local starCoinFullicon = Graphics.loadImage(Misc.resolveFile("smb3overhaul/starCoinFull.png"))
local emptyStamp = Graphics.loadImage(Misc.resolveFile("smb3overhaul/emptyStamp.png"))
local fullStamp = Graphics.loadImage(Misc.resolveFile("smb3overhaul/fullStamp.png"))
ALIGN_LEFT = 0;
ALIGN_RIGHT = 1;
ALIGN_MID = 0.5;
offsets = {}
local bannedChars = 
{
13,
}
offsets.starcoins = {x = -384, y = 27, cross = {x = 24, y = 0},	value = {x = 45, y = 0, align = ALIGN_LEFT}, grid = {x = 0, y = 40, width = 5, height = 3, offset = 0, table = {}, align = ALIGN_LEFT},	align = ALIGN_LEFT}
local function validCoin(t, i)
	return t[i] and (not t.alive or t.alive[i])
end
function max()
	return SaveData._basegame.starcoin[LevelName].maxID
end
function count(name)
	name = world.levelObj.filename
	local t = SaveData._basegame.starcoin[name]
	if not t then return 0 end
	local c = 0
	for i = 1, t.maxID do
		if validCoin(t,i) then
			c = c+1
		end
	end
	return c
end
if SaveData.isMulti == nil then SaveData.isMulti = false end
if SaveData.playerCount == nil then SaveData.playerCount = 1 end
if SaveData.playerTurn == nil then SaveData.playerTurn = 1 end
if SaveData.player1Pow == nil then SaveData.player1Pow = 1 end
if SaveData.player2Pow == nil then SaveData.player2Pow = 1 end
if SaveData.player3Pow == nil then SaveData.player3Pow = 1 end
if SaveData.player4Pow == nil then SaveData.player4Pow = 1 end
if SaveData.player1lv == nil then SaveData.player1lv = 5 end
if SaveData.player2lv == nil then SaveData.player2lv = 5 end
if SaveData.player3lv == nil then SaveData.player3lv = 5 end
if SaveData.player4lv == nil then SaveData.player4lv = 5 end
if SaveData.player1c == nil then SaveData.player1c = 1 end
if SaveData.player2c == nil then SaveData.player2c = 2 end
if SaveData.player3c == nil then SaveData.player3c = 3 end
if SaveData.player4c == nil then SaveData.player4c = 4 end
if SaveData.stamps == nil then SaveData.stamps = {} end

function onStart()
	warned = false
	if SaveData.player1lc == nil then SaveData.player1lc = vector(world.playerX,world.playerY) end
	if SaveData.player2lc == nil then SaveData.player2lc = vector(world.playerX,world.playerY) end
	if SaveData.player3lc == nil then SaveData.player3lc = vector(world.playerX,world.playerY) end
	if SaveData.player4lc == nil then SaveData.player4lc = vector(world.playerX,world.playerY) end
	if playerStart == true then
		playerStart = false
		if SaveData.playerTurn == 1 and SaveData.isMulti == true then 
			player.powerup = SaveData.player1Pow
			world.playerX = SaveData.player1lc.x
			world.playerY = SaveData.player1lc.y
			--mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player1lv)
		elseif SaveData.playerTurn == 2 and SaveData.isMulti == true then 
			player.powerup = SaveData.player2Pow
			world.playerX = SaveData.player2lc.x
			world.playerY = SaveData.player2lc.y
			--mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player2lv)
		elseif SaveData.playerTurn == 3 and SaveData.isMulti == true then 
			player.powerup = SaveData.player3Pow
			world.playerX = SaveData.player3lc.x
			world.playerY = SaveData.player3lc.y
			--mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player3lv)
		elseif SaveData.playerTurn == 4 and SaveData.isMulti == true then 
			player.powerup = SaveData.player4Pow
			world.playerX = SaveData.player4lc.x
			world.playerY = SaveData.player4lc.y
			--mem(0x00B2C5AC,FIELD_FLOAT,SaveData.player4lv)
		end
	end
	SetLevelVisible(13)
	SetLevelVisible(98)
	SetLevelVisible(8)
	SetLevelVisible(2)
	SetLevelVisible(86)
	SetLevelVisible(1)
	SetLevelVisible(12)
	SetLevelBack()
	SetLevelVisible(16)
	SetLevelVisible(4)
	SetLevelVisible(21)
	SetLevelVisible(22)
	SetLevelVisible(87)
	SetLevelVisible(26)
	SetLevelVisible(25)
	SetLevelVisible(10)
	SetLevelVisible(15)
	SetLevelVisible(19)
	SetLevelVisible(3)
	SetLevelVisible(7)
	SetLevelVisible(5)
	SetLevelVisible(3)
	SetLevelVisible(6)
	SetLevelVisible(97)
	SetLevelVisible(96)
	SetLevelVisible(95)
	SetLevelVisible(94)
	SetLevelVisible(93)
	SetLevelVisible(92)
	SetLevelVisible(91)
	SetLevelVisible(90)
	SetLevelVisible(89)
	SetLevelVisible(88)
	local amountOfLevels = 0
	
	amountOfLevels = amountOfLevels+tablelength(Level.findByFilename("slotgame"))
	amountOfLevels = amountOfLevels+tablelength(Level.findByFilename("1-toad1"))
	amountOfLevels = amountOfLevels+tablelength(Level.findByFilename("2-toad1"))
	amountOfLevels = amountOfLevels+tablelength(Level.findByFilename("2-toad2"))
	if not SaveData.levelPassInfo--[[ or tablelength(SaveData.levelPassInfo) < amountOfLevels--]] then 
		SaveData.levelPassInfo = {} 
		--[[local level = Level.findByFilename("slotgame")
		local tale = SaveData.levelPassInfo
		level = Level.findByFilename("slotgame")
		for i=1,tablelength(level) do
			if not table.contains(tale,(level[i].x)+(level[i].y*16000)) then
				tale[tablelength(tale)+1] = (level[i].x)+(level[i].y*16000)
				tale[tablelength(tale)+1] = false
			end
		end
		level = Level.findByFilename("1-toad1")
		for i=1,tablelength(level) do
			if not table.contains(tale,(level[i].x)+(level[i].y*16000)) then
				tale[tablelength(tale)+1] = (level[i].x)+(level[i].y*16000)
				tale[tablelength(tale)+1] = false
			end
		end
		level = Level.findByFilename("2-toad1")
		for i=1,tablelength(level) do
			if not table.contains(tale,(level[i].x)+(level[i].y*16000)) then
				tale[tablelength(tale)+1] = (level[i].x)+(level[i].y*16000)
				tale[tablelength(tale)+1] = false
			end
		end
		level = Level.findByFilename("2-toad2")
		for i=1,tablelength(level) do
			if not table.contains(tale,(level[i].x)+(level[i].y*16000)) then
				tale[tablelength(tale)+1] = (level[i].x)+(level[i].y*16000)
				tale[tablelength(tale)+1] = false
			end
		end
		SaveData.levelPassInfo = tale--]]
	end
end
function onTick()
	Progress.value = SaveData._basegame.starcoinCounter
	if SaveData.playerCount == 1 and SaveData.isMulti == true then
		SaveData.playerCount = 2 
	end
	
	if SaveData.playerTurn == 2 and SaveData.playerCount < 2 then
		SaveData.playerTurn = 3 
	end
	if SaveData.playerTurn == 3 and SaveData.playerCount < 3 then
		SaveData.playerTurn = 4
	end
	if SaveData.playerTurn == 4 and SaveData.playerCount < 4 then
		SaveData.playerTurn = 1
	end
	
	if SaveData.playerTurn == 1 then 
		player:transform(SaveData.player1c,false)
		--player.character = SaveData.player1c 
	elseif SaveData.playerTurn == 2 then 
		player:transform(SaveData.player2c,false)
		--player.character = SaveData.player2c 
	elseif SaveData.playerTurn == 3 then 
		player:transform(SaveData.player3c,false)
		--player.character = SaveData.player3c  
	elseif SaveData.playerTurn == 4 then
		player:transform(SaveData.player4c,false)
		--player.character = SaveData.player4c 
	end
	player.powerup = SaveData.power
	
	
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function onTickEnd()
		if world.levelObj ~= nil then LevelName = world.levelObj.filename end
end
function SetLevelBack()
	levels = Level.get()
	if tablelength(levels) > 0 then
		for i=1, tablelength(levels) do
			levels[i].isPathBackground = false
		end
	end
end
function SetLevelVisible(numb)
	levels = Level.get(numb)
	if tablelength(levels) > 0 then
		for i=1, tablelength(levels) do
			levels[i].visible = true
			levels[i].isAlwaysVisible = true
		end
	end
end
function onDrawEnd()
	if player == nil then return end
	if player.keys.dropItem == KEYS_PRESSED and not Misc.isPaused() then
		if SaveData.isMulti == false then 
			SaveData.isMulti = true
			SaveData.playerCount = 2
		else
			if SaveData.playerCount == 1 then
				SaveData.playerCount = 2 
			elseif SaveData.playerCount == 2 then
				SaveData.playerCount = 3 
			elseif SaveData.playerCount == 3 then
				SaveData.playerCount = 4 
			elseif SaveData.playerCount == 4 then
				SaveData.playerCount = 1 
				SaveData.isMulti = false
			end
		end
		if SaveData.isMulti == false then 
			SaveData.playerTurn = 1 
			player.powerup = SaveData.player1Pow
		end
	end
	if player.keys.altJump == KEYS_PRESSED and not Misc.isPaused() then
		
		if SaveData.playerTurn == 1 then
			local editable = SaveData.player1c+1
			for i=1,20 do
				if table.contains(bannedChars,editable) then editable = editable+1 end
				if editable > 16 then editable = 1 end
			end
			SaveData.player1c = editable
		end
		if SaveData.playerTurn == 2 then
			local editable = SaveData.player2c+1
			for i=1,20 do
				if table.contains(bannedChars,editable) then editable = editable+1 end
				if editable > 16 then editable = 1 end
			end
			SaveData.player2c = editable
		end
		if SaveData.playerTurn == 3 then
			local editable = SaveData.player3c+1
			for i=1,20 do
				if table.contains(bannedChars,editable) then editable = editable+1 end
				if editable > 16 then editable = 1 end
			end
			SaveData.player3c = editable
		end
		if SaveData.playerTurn == 4 then
			local editable = SaveData.player4c+1
			for i=1,20 do
				if table.contains(bannedChars,editable) then editable = editable+1 end
				if editable > 16 then editable = 1 end
			end
			SaveData.player4c = editable
		end
	end
end
function getLevelList(name)
	name = name or LevelName
	return SaveData._basegame.starcoin[name]
end
function getLevelCollected(name)
	local list = getLevelList(name)
	local LtotalNum = 0
	for i = 1,list.maxID do
		if validCoin(list,i) and list[i] ~= 0 then
			LtotalNum = LtotalNum + 1
		end
	end
	return LtotalNum
end
function onHUDDraw()
	
	if world.levelObj ~= nil then 
		LevelName = world.levelObj.filename
	end
	if world.levelObj ~= nil then
		local count = count()
		if count > 0 then
			local halfCam = 800/2
			local offsety = 0
			local offset = offsets.starcoins
			local grid = offset.grid
			local data = getLevelList(world.levelObj.filename)
			local collNum = getLevelCollected(world.levelObj.filename)
			local i = 1
			local idx = 1
			local img_coll = starCoinFullicon
			local img_uncoll = starCoinEmptyicon
			local list = getLevelList(name)
			for i=1, list.maxID do
				Graphics.draw{
					type = RTYPE_IMAGE,
					image = starCoinEmptyicon,
					x = (230)+(i*15),
					y = (135),
					priority = renderPriority,
					sourceX = 0,
					sourceY = 0,
					sourceWidth = 14,
					sourceHeight = 14,
				}
			end
			
			for i=1, list.maxID do
				if validCoin(list,i) and data[i] ~= 0 and data[i] ~= 3 then
					Graphics.draw{
						type = RTYPE_IMAGE,
						image = starCoinFullicon,
						x = (230)+(i*15),
						y = (135),
						priority = renderPriority,
						sourceX = 0,
						sourceY = 0,
						sourceWidth = 14,
						sourceHeight = 14,
					}
				end
			end
		end
		if SaveData.stamps[world.levelObj.filename] then
			if SaveData.stamps[world.levelObj.filename][1] == true then
				Graphics.draw{
					type = RTYPE_IMAGE,
					image = fullStamp,
					x = 245,
					y = 155,
					priority = renderPriority,
					sourceX = 0,
					sourceY = 0,
					sourceWidth = 16,
					sourceHeight = 16,
				}
			else
				if SaveData.stamps[world.levelObj.filename][1] == false then
					Graphics.draw{
						type = RTYPE_IMAGE,
						image = emptyStamp,
						x = 245,
						y = 155,
						priority = renderPriority,
						sourceX = 0,
						sourceY = 0,
						sourceWidth = 16,
						sourceHeight = 16,
					}
				end
			end
		end
	end
	if SaveData.isMulti == true then
		Text.print("Player "..SaveData.playerTurn,230,155)
	end
	if SaveData.playerCount > 1 then
		Text.print("Player count: "..SaveData.playerCount,230,175)
	end
end
function onExit()
	if world.levelObj == nil then return end
	if SaveData.playerTurn == 1 then
		SaveData.player1lc.x = world.playerX
		SaveData.player1lc.y = world.playerY
	elseif SaveData.playerTurn == 2 then
		SaveData.player2lc.x = world.playerX
		SaveData.player2lc.y = world.playerY
	elseif SaveData.playerTurn == 3 then
		SaveData.player3lc.x = world.playerX
		SaveData.player3lc.y = world.playerY
	elseif SaveData.playerTurn == 4 then
		SaveData.player4lc.x = world.playerX
		SaveData.player4lc.y = world.playerY
	end
	local tale = SaveData.levelPassInfo
	levelEnter = world.levelObj
	levelEnterX = world.playerX
	levelEnterY = world.playerY
	levelEnterfilename = levelEnter.filename
	levelEntertitle = levelEnter.title
	SaveData.LevelEntered = levelEntertitle
	SaveData.levelEnterUnlocked = false 
	SaveData.levelXY = -1
	datType = SaveData.levelEnteredType
	datType = "non"
	SaveData.levelEnteredType = datType
	SaveData.levelXY = (levelEnterX)+(levelEnterY*16000)
	if table.icontains(tale,levelEntertitle) then
		if tale[table.ifind(tale,levelEntertitle)+1] == true then 
			SaveData.levelEnterUnlocked = true 
			if SaveData.levelEnteredType == "hammer" then return end
		else 
			SaveData.levelEnterUnlocked = false 
			if SaveData.levelEnteredType == "hammer" then return end
		end
	else
		SaveData.levelEnterUnlocked = false
		tale[tablelength(tale)+1] = levelEntertitle
		tale[tablelength(tale)+1] = false
	end
	SaveData.levelPassInfo = tale
end