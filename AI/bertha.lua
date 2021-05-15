local npcManager = require("npcManager")
local npcutils = require("npcs/npcutils")
local bass = {}
startY = nil
local touchedWater = false
function bass.register(id)
	npcManager.registerEvent(id, bass, "onStartNPC")
    npcManager.registerEvent(id, bass, "onTickNPC")
	npcManager.registerEvent(id, bass, "onDrawNPC")
end
function bass.onStartNPC(v)
	local data = v.data
	data.startX = v.x
	data.startY = v.y
end
function bass.onTickNPC(v)
	local data = v.data
	data.x = data.x or v.x
	data.lastFrame = data.lastFrame or 0
	data.y = data.y or v.y
	data.changeTimer = data.changeTimer or 0
	data.timer = data.timer or RNG.random(0,3)
	settings = NPC.config[v.id]
	data.targetOff = data.targetOff or data.startX-64
	data.speedX = data.speedX or 0
	data.spawned = data.spawned or nil
	data.AnimOffset = data.AnimOffset or 0
	TargetPlayer = {
		x=data.targetOff,
		y=data.startY,
	}
	if TargetPlayer == nil then return end
	if TargetPlayer.x > data.x then data.speedX = data.speedX + settings.ChaseSpeed end
	if TargetPlayer.x < data.x then data.speedX = data.speedX - settings.ChaseSpeed end
	if data.speedX < 0 and data.targetOff >= data.startX then data.targetOff = data.startX-64 end
	if data.speedX > 0 and data.targetOff <= data.startX then data.targetOff = data.startX+64 end
	if data.speedX > settings.MaxSpeed then data.speedX = settings.MaxSpeed end
	if data.speedX < -settings.MaxSpeed then data.speedX = -settings.MaxSpeed end
	data.timer = data.timer + (1/60)
	if data.changeTimer > 0 then
		data.changeTimer = data.changeTimer - (1/60)
	end
	if data.AnimOffset >= 4 and data.changeTimer <= 0 then
		data.AnimOffset = 0
	end
	if data.timer >= settings.spawnTimer then
		if data.spawned == nil then
			if data.AnimOffset == 4 then
				data.spawned = NPC.spawn(991,v.x+(settings.gfxwidth/2),v.y+(settings.gfxheight/2))
				data.spawned.direction = v.direction
				data.speedX = 0
				data.timer = settings.spawnTimer-1
			else
				data.AnimOffset = 4
				data.changeTimer = 0.5
			end
		elseif data.spawned.isValid ~= true and data.AnimOffset == 4 then
			data.spawned = NPC.spawn(991,v.x+(settings.gfxwidth/2),v.y+(settings.gfxheight/2))
			data.spawned.direction = v.direction
			data.speedX = 0
			data.timer = settings.spawnTimer-1
		elseif data.spawned.isValid == true then
			TargetPlayer = data.spawned
			data.AnimOffset = 4
			data.changeTimer = 0.5
			if TargetPlayer.x > data.x then data.speedX = data.speedX + (settings.ChaseSpeed*2) end
			if TargetPlayer.x < data.x then data.speedX = data.speedX - (settings.ChaseSpeed*2) end
			if data.speedX > settings.MaxSpeed then data.speedX = settings.MaxSpeed end
			if data.speedX < -settings.MaxSpeed then data.speedX = -settings.MaxSpeed end
			if table.contains(NPC.getIntersecting(data.x,data.y,data.x+v.width,data.y+v.height),data.spawned) then
				data.spawned:kill(HARM_TYPE_VANISH)
				data.spawned = nil
				data.timer = 0
				data.AnimOffset = 4
				data.changeTimer = 0.5
			end
		else
			data.AnimOffset = 4
			data.changeTimer = 0.5
		end
	end
	data.x = data.x + data.speedX
	v.speedX = data.speedX
	v.x = data.x
	v.y = data.y
end
function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end
function bass.onDrawNPC(v)
	local data = v.data
	local anim = v.animationFrame
	if data.AnimOffset == 4 then
		if anim == 0 then anim = 4
		elseif anim == 1 then anim = 5
		elseif anim == 2 then anim = 6
		elseif anim == 3 then anim = 7 
		else anim = 4 end
	end
	v.animationFrame = anim
	
end

return bass;