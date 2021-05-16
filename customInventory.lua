--██╗███╗░░██╗██╗░░░██╗███████╗███╗░░██╗████████╗░█████╗░██████╗░██╗░░░██╗
--██║████╗░██║██║░░░██║██╔════╝████╗░██║╚══██╔══╝██╔══██╗██╔══██╗╚██╗░██╔╝
--██║██╔██╗██║╚██╗░██╔╝█████╗░░██╔██╗██║░░░██║░░░██║░░██║██████╔╝░╚████╔╝░
--██║██║╚████║░╚████╔╝░██╔══╝░░██║╚████║░░░██║░░░██║░░██║██╔══██╗░░╚██╔╝░░
--██║██║░╚███║░░╚██╔╝░░███████╗██║░╚███║░░░██║░░░╚█████╔╝██║░░██║░░░██║░░░
--╚═╝╚═╝░░╚══╝░░░╚═╝░░░╚══════╝╚═╝░░╚══╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░


local inventory = {}

-- Customizable Stuff --
-- This defines with how many items do you want to start --
inventory.startingItems = 0
local rng = require("rng")
local particles = require("particles")
local hOverride = require("hudoverride")
local shader = Misc.multiResolveFile("starman.frag", "shaders\\npc\\starman.frag")
local playerManager = require("playerManager")
-- Variables --
local invIsOpen = false
local sparkleTimer = 0
local sparkleStartTimer = 45
local chooseIsOpen = false
local invBack =  Graphics.loadImageResolved("OverworldHUD/Back.png")
local invIcons =  Graphics.loadImageResolved("OverworldHUD/InvIcons.png")
local invChoose =  Graphics.loadImageResolved("OverworldHUD/Choose.png")
local invChar =  Graphics.loadImageResolved("OverworldHUD/characters.png")
local selector = Graphics.loadImageResolved("OverworldHUD/Selector.png")
local pIcon = Graphics.loadImageResolved("OverworldHUD/p.png")
local sIcon = Graphics.loadImageResolved("OverworldHUD/s.png")
local isSelected = 0
local bScale = 0
local cScale = 0
local selectedOffset = 0
local selectedPlayer = 1
local ps
local pGet

-- The Sprite Class --
local backSprite = Sprite{
    image = invBack,
    x = 70,
	y = 530,
	align = Sprite.align.BOTTOMLEFT
}

local chooseSprite = Sprite{
    image = invChoose,
    x = 400,
	y = 342,
	align = Sprite.align.CENTER,
}

-- Textplus Font --
local textplus = require("textplus")
local font = textplus.loadFont("textplus/font/1.ini")

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
-- The Data Saving --
-- The Item order is: Mushroom, FireFlower, Leaf, Tanooki, Hammer, IceFlower, Starman, PWing, Whistle, SWing --
if SaveData.inventoryTable == nil or tablelength(SaveData.inventoryTable) < 10 then
	SaveData.inventoryTable = {}
	for i = 0, 10 do
        SaveData.inventoryTable[i+1] = inventory.startingItems
    end
end
if SaveData.lastWarp == nil then
	SaveData.lastWarp = 0
end
if not SaveData.useStarman then
	SaveData.useStarman = false
end
if not SaveData.past1Powerup then
	SaveData.past1Powerup = 1
end
if not SaveData.past2Powerup then
	SaveData.past2Powerup = 1
end
if not SaveData.past3Powerup then
	SaveData.past3Powerup = 1
end
if not SaveData.past4Powerup then
	SaveData.past4Powerup = 1
end
if not SaveData.usePWing then
	SaveData.usePWing = false
end
if not SaveData.useSWing then
	SaveData.useSWing = false
end

function inventory.onInitAPI()
	registerEvent(inventory, "onStart")
	if isOverworld then
		registerEvent(inventory, "onDraw", "onDrawWorld")
		registerEvent(inventory, "onDrawEnd", "onDrawEndWorld")
		registerEvent(inventory, "onInputUpdate", "onInputWorld")
	else
		registerEvent(inventory, "onTick")
		registerEvent(inventory, "onExitLevel")
	end
end


function inventory.onStart()
	pGet = Player.get()

	if not isOverworld and SaveData.useStarman then
		NPC.spawn(293, player.x, player.y, player.section)
		if player2 then
			NPC.spawn(293, player2.x, player2.y, player2.section)
		end
		SaveData.useStarman = false
	end
end


function inventory.onDrawEndWorld()
	-- Opening the Inventory --
	if player.keys.altRun == KEYS_PRESSED then
		if not Misc.isPaused() and not invIsOpen then
			Misc.pause()
			invIsOpen = true
			SFX.play(Misc.resolveFile("OverworldHUD/Enter.spc"))
		else
			Misc.unpause()
			invIsOpen = false
			SFX.play(Misc.resolveFile("OverworldHUD/Exit.spc"))
		end
	end

	if invIsOpen == false then chooseIsOpen = false end
end


function inventory.onDrawWorld()
	-- Animation --
	if invIsOpen then
		if bScale < 1 then bScale = bScale + 0.1 end
	else
		if bScale > 0 then bScale = bScale - 0.1 end
	end

	if chooseIsOpen then
		if cScale < 1 then cScale = cScale + 0.1 end
	else
		if cScale > 0 then cScale = cScale - 0.1 end
	end

	-- Lets cap the scale --
	if bScale < 0 then bScale = 0 end
	if bScale > 1 then bScale = 1 end

	if cScale < 0 then cScale = 0 end
	if cScale > 1 then cScale = 1 end

	-- Scaling the sprites --
	if bScale > 0 then
		Graphics.draw{
			type = RTYPE_IMAGE,
			image = invBack,
			x = 66,
			y = 478-37,
			sourceY = 0,
			sourceHeight = 90,
			sourceX = 0,
			sourceWidth = 668
		}
	end

	if cScale > 0 then
		chooseSprite:draw{priority = 5}
		chooseSprite.transform.scale = vector(cScale, cScale)
	end

	-- Drawing the Item Icons --
	if bScale >= 1 then
		for i = 1, 10, 1 do
			if selectedOffset == (i-1) then isSelected = 1 else isSelected = 0 end
			textplus.print{text=string.format("%02d", SaveData.inventoryTable[i]), x=((i-1)*82+94)*0.8, y=452, font=font, plaintext=true}
			Graphics.draw{
				type = RTYPE_IMAGE,
				image = invIcons,
				x = ((i-1) * 82 + 94)*0.8,
				y = 478,
				sourceY = (i-1) * 36,
				sourceHeight = 36,
				sourceX = isSelected * 36,
				sourceWidth = 36
			}
		end
	end

	if cScale == 1 then
		Graphics.draw{
			type = RTYPE_IMAGE,
			image = invChar,
			x = 330,
			y = 320,
			sourceX = tonumber(player.character - 1) * 40,
			sourceWidth = 40,
			priority = 5.1
		}
		
		Graphics.draw{
			type = RTYPE_IMAGE,
			image = invChar,
			x = 430,
			y = 320,
			sourceX = tonumber(player2.character - 1) * 40,
			sourceWidth = 40,
			priority = 5.1
		}

		Text.printWP("Choose a", 330, 278, 5.3)
		Text.printWP("Player", 346, 298, 5.3)

		Graphics.draw{
			type = RTYPE_IMAGE,
			image = selector,
			x = 100 * (selectedPlayer - 1) + 316,
			y = 350,
			priority = 5.2
		}
	end

	if(type(shader) == "string") then
		local s = Shader()
		s:compileFromFile(nil, shader)
		shader = s
	end

	if SaveData.useStarman then
		local x,y = 400+hOverride.overworld.offsets.player.x-(player.width*0.5), hOverride.overworld.offsets.player.y-player.height;
		player:render{x = x, y = y, ignorestate = true, sceneCoords = false, priority = 6, color = Color.white, mountcolor = Color.white, shader = shader, uniforms = {time = lunatime.tick()*2},}
	end

	if SaveData.usePWing then
		Graphics.draw{type=RTYPE_IMAGE, image=pIcon, x=84, y=96, priority = 6.1}
	end
	if SaveData.useSWing then
		Graphics.draw{type=RTYPE_IMAGE, image=sIcon, x=84, y=96, priority = 6.1}
	end
end


function inventory.onInputWorld()
	-- Lets disable character changing --
	if Misc.isPaused and invIsOpen then
		player.keys.left = false
		player.keys.right = false
	end

	-- Moving through the menu --
	if invIsOpen then
		if chooseIsOpen then
			if player.rawKeys.left == KEYS_PRESSED and selectedPlayer > 1 then
				selectedPlayer = selectedPlayer - 1
				SFX.play(29)
			elseif player.rawKeys.right == KEYS_PRESSED and selectedPlayer < 2 then
				selectedPlayer = selectedPlayer + 1
				SFX.play(29)
			end
		else
			if player.rawKeys.left == KEYS_PRESSED and selectedOffset > 0 then
				selectedOffset = selectedOffset - 1
				SFX.play(29)
			elseif player.rawKeys.right == KEYS_PRESSED and selectedOffset < 9 then
				selectedOffset = selectedOffset + 1
				SFX.play(29)
			end
		end
		-- Adding PowerUps! --
		if player.keys.jump == KEYS_PRESSED then
			if SaveData.inventoryTable[selectedOffset+1] > 0 then
				if selectedOffset < 6 then
					if player2 then
						chooseIsOpen = true
						SFX.play(29)
						if cScale >= 1 then
							
							if pGet[selectedPlayer].powerup == selectedOffset + 2 or pGet[selectedPlayer].powerup >= 2 and selectedOffset == 0 then SFX.play(3) return end
							SaveData.past2Powerup = pGet[selectedPlayer].powerup
							if SaveData.past2Powerup == PLAYER_HAMMER then SaveData.past2Powerup = 1 end
							if pGet[selectedPlayer].powerup == PLAYER_HAMMER then SaveData.inventoryTable[5] = SaveData.inventoryTable[5]+1 end
							pGet[selectedPlayer].powerup = selectedOffset + 2
							ps = PlayerSettings.get(playerManager.getBaseID(pGet[selectedPlayer].character), selectedOffset + 2)
							pGet[selectedPlayer].height = ps.hitboxHeight
							SFX.play(6)
							SaveData.inventoryTable[selectedOffset+1] = SaveData.inventoryTable[selectedOffset+1] - 1
							chooseIsOpen = false
						end
					else
						
						if player.powerup == selectedOffset + 2 or player.powerup >= 2 and selectedOffset == 0 then SFX.play(3) return end
						if SaveData.playerTurn == 1 and SaveData.past1Powerup ~= PLAYER_ICE then 
							SaveData.past1Powerup = player.powerup
						elseif SaveData.playerTurn == 2 and SaveData.past2Powerup ~= PLAYER_ICE then 
							SaveData.past2Powerup = player.powerup
						elseif SaveData.playerTurn == 3 and SaveData.past3Powerup ~= PLAYER_ICE then 
							SaveData.past3Powerup = player.powerup
						elseif SaveData.playerTurn == 4 and SaveData.past4Powerup ~= PLAYER_ICE then 
							SaveData.past4Powerup = player.powerup
						end
						if player.powerup == PLAYER_ICE then SaveData.inventoryTable[5] = SaveData.inventoryTable[5]+1 end
						player.powerup = selectedOffset + 2
						ps = PlayerSettings.get(playerManager.getBaseID(player.character), selectedOffset + 2)
						player.height = ps.hitboxHeight
						SFX.play(6)
						if SaveData.usePWing == true and selectedOffset + 2 ~= 4 then
							SaveData.inventoryTable[8] = SaveData.inventoryTable[8] + 1
							SaveData.usePWing = false
						end
						SaveData.inventoryTable[selectedOffset+1] = SaveData.inventoryTable[selectedOffset+1] - 1
					end
				elseif selectedOffset == 6 and not SaveData.useStarman then
					SaveData.useStarman = true
					SFX.play(6)
					SaveData.inventoryTable[7] = SaveData.inventoryTable[7] - 1
				elseif selectedOffset == 7 and not SaveData.usePWing then
					SaveData.usePWing = true
					if SaveData.useSWing == true then
						SaveData.inventoryTable[10] = SaveData.inventoryTable[10] + 1
						SaveData.useSWing = false
					end
					player.powerup = 4
					ps = PlayerSettings.get(playerManager.getBaseID(player.character), 4)
					player.height = ps.hitboxHeight

					if player2 then
						player2.powerup = 4
						ps = PlayerSettings.get(playerManager.getBaseID(player.character), 4)
						player2.height = ps.hitboxHeight
					end
					
					SFX.play(6)
					SaveData.inventoryTable[8] = SaveData.inventoryTable[8] - 1
				elseif selectedOffset == 8 then
					SaveData.inventoryTable[9] = SaveData.inventoryTable[9] - 1
					SaveData.lastWarp = SaveData.lastWarp+1
					SFX.play(6)
					if SaveData.lastWarp == 1 then
						world.playerX = 64
						world.playerY = -1952
					elseif SaveData.lastWarp == 2 then
						world.playerX = 64
						world.playerY = -1856
					elseif SaveData.lastWarp == 3 then
						world.playerX = 64
						world.playerY = -1760
					end
				elseif selectedOffset == 9 and not SaveData.useSWing then
					SaveData.useSWing = true
					if SaveData.usePWing == true then
						SaveData.inventoryTable[8] = SaveData.inventoryTable[8] + 1
						SaveData.usePWing = false
					end
					player.powerup = 2
					ps = PlayerSettings.get(playerManager.getBaseID(player.character), 4)
					player.height = ps.hitboxHeight

					if player2 then
						player2.powerup = 2
						ps = PlayerSettings.get(playerManager.getBaseID(player.character), 4)
						player2.height = ps.hitboxHeight
					end
					
					SFX.play(6)
					SaveData.inventoryTable[10] = SaveData.inventoryTable[10] - 1
				end
				SaveData.power = player.powerup
			else
				SFX.play(3)
			end
		end
	end	
end


function inventory.onTick()
	if SaveData.usePWing then
		player:mem(0x168, FIELD_FLOAT, 40)
		player:mem(0x170, FIELD_WORD, 100)
	end
	if SaveData.useSWing then
		if sparkleTimer <= 0 then
			local effect = Animation.spawn(761, player.x, player.y)
			effect.speedY = rng.randomInt(-60 / 20, 60 / 20)
			effect.speedX = rng.randomInt(-60 / 20, 60 / 20)
			sparkleTimer = sparkleStartTimer
		else
			sparkleTimer = sparkleTimer-lunatime.tick()
		end
	end
	if SaveData.useSWing and player:mem(0x36,FIELD_BOOL) == true then
		--player.speedY = player.speedY+1
		Defines.gravity	= 24
		Defines.player_runspeed	= 12
		Defines.player_walkspeed = 6
		Defines.jumpheight = 20
		Defines.jumpheight_bounce = 20
	else
		Defines.gravity	= 12
		if SaveData.useSWing == true then
			Defines.player_runspeed	= 3
			Defines.jumpheight = 30
			Defines.jumpheight_bounce = 30
			Defines.player_walkspeed = 2
		else
			Defines.player_runspeed	= 6
			Defines.jumpheight = 20
			Defines.jumpheight_bounce = 20
			Defines.player_walkspeed = 3
		end
	end
	if player2 then
		if player.powerup ~= 4 and player2.powerup ~= 4  then
			SaveData.usePWing = false
		end
	else
		if player.powerup ~= 4 then
			SaveData.usePWing = false
		end
		if player.powerup ~= 2 then
			SaveData.useSWing = false
		end
	end
end

function inventory.onExitLevel()
	SaveData.usePWing = false
	SaveData.useStarman = false
end


-- Utilizable functions --
-- This one adds Items to the inventory, select which item you want to add and the amount --
function inventory.addPowerUp(pID, amount)
	SaveData.inventoryTable[pID+1] = SaveData.inventoryTable[pID+1] + amount
end

-- This one sets the amount of Items that you have, select which item do you want to set and the number --
function inventory.setPowerUp(pID, number)
	SaveData.inventoryTable[pID+1] = number
end

return inventory