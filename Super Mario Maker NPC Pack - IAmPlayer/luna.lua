local bgoColliders

function onStart()
	for k,b in ipairs(BGO.get(72)) do
		bgoColliders[k] = Colliders.Box(b.x, b.y, b.width, b.height)
	end
end

function onTick()
	for k,b in ipairs(BGO.get(72)) do
		bgoColliders[k]:Debug(true)
		if Colliders.collide(player, bgoColliders[k]) and not b.isHidden then
			if player.forcedState == 0 and player.deathTimer == 0 then
				player:harm()
			end
		end
	end
end