require "util"
require "lib"

script.on_event(defines.events.on_put_item, function(event)
	local player = game.players[event.player_index]
	local item = player.cursor_stack
	local f = Liquid:new()
	if item.valid_for_read then
		local _ch = string.find(item.name, "storage-tank", 1, true)
		if _ch ~= nil then
			if _ch > 1 then
				tank_had_fluid = true
				liquid_transfer = Liquid:new()
				liquid_transfer.type = string.sub(item.name, 1, _ch-2)
				liquid_transfer.amount = item.durability
			end
		player_transfer = player
		end
	else
		player.print("Error while placing item ? .")
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	if entity.name == "storage-tank" then
		if tank_had_fluid == true then
			entity.fluidbox[1] = liquid_transfer
			tank_had_fluid = false
		end
		player_transfer.cursor_stack.count = player_transfer.cursor_stack.count - 1	
	end
end)

if debug_flag == true then
	script.on_event(defines.events.on_player_created, function(event)
		for _, item in pairs(debug_items) do
			game.players[event.player_index].insert(item)
		end
	end)
end

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	local entity = event.entity
	local player = game.players[event.player_index]
	if entity.name == "storage-tank" then
		local fluid = entity.fluidbox[1]
		if fluid ~= nil and math.floor(fluid.amount) > 0 then
			tank_had_fluid = true
			entity_transfer = MyEntity:new()
			entity_transfer.name = entity.name
			entity_transfer.position = entity.position
			entity_transfer.direction = entity.direction
			entity_transfer.force = entity.force
			entity_surface = entity.surface.index
			liquid_transfer = Liquid:new(fluid)
			liquid_transfer.amount = math.floor(liquid_transfer.amount)
		end
	else tank_had_fluid = false end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
	local player = game.players[event.player_index]
	local inv = player.get_inventory(defines.inventory.player_main)
	local quick = player.get_inventory(defines.inventory.player_quickbar)
	if tank_had_fluid == true then
		if checkInv(quick, "storage-tank") then
			if not removeItem(quick) then removeItem(inv) end
			addItem(quick, liquid_transfer)
		elseif checkInv(inv, "storage-tank") then
			if not removeItem(quick) then removeItem(inv) end
			addItem(inv, liquid_transfer)
		elseif quick.find_item_stack("storage-tank") == nil and inv.find_item_stack("storage-tank") == nil then
			if player.cursor_stack.valid_for_read and player.cursor_stack.name == "storage-tank" then
				player.cursor_stack.count = player.cursor_stack.count - 1
				replaceEntity(entity_transfer, entity_surface, liquid_transfer)
				player.print("Cannot insert "..liquid_transfer.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
			else
				killItem(entity_surface, entity_transfer.position)--remove item from ground
				replaceEntity(entity_transfer, entity_surface, liquid_transfer)
				player.print("Cannot insert "..liquid_transfer.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
			end
		else
			if not removeItem(quick) then removeItem(inv) end
			replaceEntity(entity_transfer, entity_surface, liquid_transfer)
			player.print("Cannot insert "..liquid_transfer.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
		end
		tank_had_fluid = false
	end
end)