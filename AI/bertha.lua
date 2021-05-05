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
	local data = v.data
	data.x = data.x or v.x
	data.y = data.y or v.y
	data.changeTimer = data.changeTimer or 0
	data.timer = data.timer or 0
	settings = NPC.config[v.id]
	data.speedX = data.speedX or 0
	data.spawned = data.spawned or nil
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
	if TargetPlayer.x > data.x then data.speedX = data.speedX + settings.ChaseSpeed end
	if TargetPlayer.x < data.x then data.speedX = data.speedX - settings.ChaseSpeed end
	if data.speedX > settings.MaxSpeed then data.speedX = settings.MaxSpeed end
	if data.speedX < -settings.MaxSpeed then data.speedX = -settings.MaxSpeed end
	data.timer = data.timer + (1/60)
	if data.changeTimer > 0 then
		data.changeTimer = data.changeTimer - (1/60)
	end
	if AnimOffset >= 4 and data.changeTimer <= 0 then
		AnimOffset = 0
	end
	if data.timer >= settings.spawnTimer then
		if table.contains(NPC.get(),data.spawned) ~= true then
			data.spawned = NPC.spawn(991,v.x+(settings.gfxwidth/2),v.y+(settings.gfxheight/2))
			data.spawned.direction = v.direction
			data.speedX = 0
			data.timer = 0
			AnimOffset = 4
			data.changeTimer = 0.2
		else
			TargetPlayer = data.spawned
			if TargetPlayer.x > data.x then data.speedX = data.speedX + (settings.ChaseSpeed*2) end
			if TargetPlayer.x < data.x then data.speedX = data.speedX - (settings.ChaseSpeed*2) end
			if data.speedX > settings.MaxSpeed then data.speedX = settings.MaxSpeed end
			if data.speedX < -settings.MaxSpeed then data.speedX = -settings.MaxSpeed end
			if table.contains(NPC.getIntersecting(data.x,data.y,data.x+v.width,data.y+v.height),data.spawned) then
				data.spawned:kill(HARM_TYPE_VANISH)
				data.spawned = nil
				data.timer = 0
				AnimOffset = 4
				data.changeTimer = 0.2
			end
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
	local anim = v.animationFrame+AnimOffset
	v.animationFrame = anim
	
end
return bass;