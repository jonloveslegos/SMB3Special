local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local bass = {}
startY = nil
local AnimOffset = 0
local touchedWater = false
function bass.register(id)
    npcManager.registerEvent(id, bass, "onTickNPC")
	npcManager.registerEvent(id, bass, "onDrawNPC")
end
function bass.onStart(v)
	
end
function bass.onTickNPC(v)
	data = v.data
	data.x = data.x or v.x
	data.y = data.y or v.y
	startY = startY or v.y
	data.timer = data.timer or 0
	data.JumpTimes = data.JumpTimes or 0
	settings = NPC.config[v.id]
	data.speedX = data.speedX or 0
	TargetPlayer = nil
	for p=1,tablelength(Player.get()) do
        if Section.getIdxFromCoords(data.x, data.y, 16, 16) == Player.get()[p].section then
			if TargetPlayer == nil then TargetPlayer = Player.get()[p]
			elseif math.abs(Player.get()[p].x-data.x) < math.abs(TargetPlayer.x-data.x) then
				TargetPlayer = Player.get()[p]
			end
		end
	end
	if TargetPlayer == nil then return end
	if v.speedY == 0 then
		if TargetPlayer.x > data.x then data.speedX = data.speedX + settings.ChaseSpeed end
		if TargetPlayer.x < data.x then data.speedX = data.speedX - settings.ChaseSpeed end
		AnimOffset = 0
	elseif data.JumpTimes == settings.maxJumps-1 then
		if TargetPlayer.x > data.x then data.speedX = settings.MaxSpeed end
		if TargetPlayer.x < data.x then data.speedX = -settings.MaxSpeed end
		AnimOffset = 4
	end
	if v.speedY == 0 then AnimOffset = 0 else AnimOffset = 4 end
	if data.speedX > settings.MaxSpeed then data.speedX = settings.MaxSpeed end
	if data.speedX < -settings.MaxSpeed then data.speedX = -settings.MaxSpeed end
	if data.timer > settings.JumpTimer or data.JumpTimes > 0 then 
		data.timer = 0
		if data.JumpTimes == 0 then data.JumpTimes = settings.maxJumps end
		data.JumpTimes = data.JumpTimes -(1)
		v.speedY = v.speedY - (0.5 * data.JumpTimes)
		touchedWater = false
	end
	data.timer = data.timer + (1/60)
	v.speedY = v.speedY + 0.5
	data.x = data.x + data.speedX
	data.y = data.y + v.speedY
	if touchedWater == true then
		data.y = data.y-v.speedY
		v.speedY = 0
	end
	if tablelength(BGO.getIntersecting(data.x,data.y,data.x+v.width,data.y+(v.height/4))) > 0 and touchedWater == false then 
		for i=1,tablelength(BGO.getIntersecting(data.x,data.y,data.x+v.width,data.y+(v.height/4))) do
			if BGO.getIntersecting(data.x,data.y,data.x+v.width,data.y+(v.height/4))[i].id == 83 then 
				data.y = data.y-v.speedY
				v.speedY = 0
				touchedWater = true
				break
			end
		end
	end
	v.speedX = data.speedX
	v.x = data.x
	v.y = data.y
	if player == nil then return end
	if player.forcedState ~= FORCEDSTATE_DOOR and player.forcedState ~= FORCEDSTATE_PIPE and tablelength(Player.getIntersecting(data.x,data.y,data.x+v.width,data.y+v.height)) > 0 and player.deathTimer <= 0 and player:isInvincible() == false and player:mem(0x13C,FIELD_BOOL) == false then 
		player:kill()
		AnimOffset = 4 
	end
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function bass.onDrawNPC(v)
	local anim = v.animationFrame+AnimOffset
	v.animationFrame = anim
	
end
return bass;