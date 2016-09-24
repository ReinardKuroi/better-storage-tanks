require "util"
require "lib"

--					This runs when you mine a storage tank.

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	local entity = event.entity
	local player = game.players[event.player_index]
	if entity.name == "storage-tank" then
		local fluid = entity.fluidbox[1]
		if fluid and math.floor(fluid.amount) > 0 then
			local entity_transfer = MyEntity:new()
			entity_transfer:copy(entity)
			DataTable[event.player_index] = entity_transfer
		end
		entity.fluidbox[1] = nil
	end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
	local player = game.players[event.player_index]
	local inv = player.get_inventory(defines.inventory.player_main)
	local quick = player.get_inventory(defines.inventory.player_quickbar)
	local entity_transfer = DataTable[event.player_index]
	DataTable[event.player_index] = nil
	if entity_transfer then
		if checkInv(quick) then
			if not removeItem(quick) then removeItem(inv) end
			addItem(quick, entity_transfer)
		elseif checkInv(inv) then
			if not removeItem(quick) then removeItem(inv) end
			addItem(inv, entity_transfer)
		elseif not (quick.find_item_stack("storage-tank") or inv.find_item_stack("storage-tank")) then
			if player.cursor_stack.valid_for_read and player.cursor_stack.name == "storage-tank" then
				player.cursor_stack.count = player.cursor_stack.count - 1
				replaceEntity(entity_transfer)
				player.print("Cannot insert "..entity_transfer.fluidbox.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
			else
				killItem(entity_transfer)
				replaceEntity(entity_transfer)
				player.print("Cannot insert "..entity_transfer.fluidbox.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
			end
		else
			if not removeItem(quick) then removeItem(inv) end
			replaceEntity(entity_transfer)
			player.print("Cannot insert "..entity_transfer.fluidbox.type.." Storage Tank. Player's inventory full. Deconstruction cancelled.")
		end
	end
end)

--					This runs when the storage tank is placed.

script.on_event(defines.events.on_put_item, function(event)
	local player = game.players[event.player_index]
	local item = player.cursor_stack
	if item.valid_for_read then
		if string.find(item.name, "storage-tank", 1, true) then
			if string.len(item.name) > string.len("storage-tank") then
				local entity_transfer = MyEntity:new()
				tank_had_fluid = true
				entity_transfer.fluidbox.type = string.sub(item.name, string.len("storage-tank")+2, string.len(item.name))
				entity_transfer.fluidbox.amount = item.durability
				entity_transfer.health = math.floor(item.health*500)
				DataTable[event.player_index] = entity_transfer
			end
		end
	end
end)

script.on_event(defines.events.on_built_entity, function(event)
	local entity = event.created_entity
	local player = game.players[event.player_index]
	local entity_transfer = DataTable[event.player_index]
	DataTable[event.player_index] = nil
	if entity.name == "storage-tank" then
		if entity_transfer then
			entity.fluidbox[1] = entity_transfer.fluidbox
			entity.health = entity_transfer.health
			if player.cursor_stack.valid_for_read then
				player.cursor_stack.count = player.cursor_stack.count - 1
			end
		end
	end
end)

--					This runs when you order deconstruction on a non-empty storage tank - this is a makeshift code

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	local entity = event.entity
	local player = game.players[event.player_index]
	if entity.name == "storage-tank" and entity.fluidbox[1] and math.floor(entity.fluidbox[1].amount) > 0 then
		local fluid = entity.fluidbox[1]
		entity.cancel_deconstruction(player.force)
		player.print(string.format("Cannot deconstruct: Storage Tank has %d units of %s.", fluid.amount, fluid.type))
	end
end)

--					This runs when a construction bot tries to pick up a storage tank.

--[[
script.on_event(defines.events.on_robot_pre_mined, function(event)
	local bot = event.robot
	local entity = event.entity
	if entity.name == "storage-tank" then
		local fluid = entity.fluidbox[1]
		if fluid and math.floor(fluid.amount) > 0 then
			tank_had_fluid = true
			entity_transfer = MyEntity:new()
			entity_transfer:copy(entity)
			game.players[1].print(entity_transfer.name..', '..entity_transfer.fluidbox.type..', '..entity_transfer.fluidbox.amount)
		end
		entity.fluidbox[1] = nil
	else tank_had_fluid = false end
end)
script.on_event(defines.events.on_robot_mined, function(event)
	local item = event.item_stack
	game.players[1].print('Picked up item stack of '..item.name..' #'..item.count)
	if tank_had_fluid and item then
		local itemStack = {}
		itemStack.name = "storage-tank-"..entity_transfer.fluidbox.type
		itemStack.count = 1
		game.players[1].print('Created item stack of '..itemStack.name..' #'..itemStack.count)
		item.clear()
		game.players[1].print("Replaced "..item.name.." with")
		item.set_stack(itemStack)
		item.durability = entity_transfer.fluidbox.amount
		item.health = entity_transfer.health/500
		game.players[1].print(item.name..", "..item.durability)
		tank_had_fluid = false
	end
end)
--]]

--					GUI. Creates custom gui.top when you open storage tank GUI. Has info about storage tank and DUMP button.

script.on_event(defines.events.on_tick, function(event)
	if event.tick % 20 ~= 0 then
		for i,player in pairs(game.players) do
			local gui = player.gui.top
			if player.opened and player.opened.name == 'storage-tank' and player.opened.fluidbox[1] and math.floor(player.opened.fluidbox[1].amount) > 0 then
				local fluid = player.opened.fluidbox[1]
				if gui.dumpcontents == nil then -- if it doesn't exits, create GUI with one button
					gui.add({type = "frame", direction="vertical", name = "dumpcontents"})
					gui.dumpcontents.add({type = "frame", name = "info"})
					gui.dumpcontents.info.add({type = "label", name = "n"})
					gui.dumpcontents.info.add({type = "label", name = "a"})
					gui.dumpcontents.info.caption = ("Storage tank contents:")
					gui.dumpcontents.add({type = "button", name = "dump"})
					gui.dumpcontents.dump.caption = ("Dump contents")
				else -- while open - update info
					gui.dumpcontents.info.n.caption = ("Name: "..string.upper(fluid.type))
					gui.dumpcontents.info.a.caption = (" Amount: "..math.floor(fluid.amount))
				end
			else -- if closed - delete GUI
				if gui.dumpcontents then
					gui.dumpcontents.destroy()
				end
			end
		end
	end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	local element = event.element
	if player.opened.name == "storage-tank" and element.name == "dump" then -- if this is the correct gui button
		player.opened.fluidbox[1] = nil -- delete storage tank contents
	end
end)

--					Gives some items in the new world for testing if debug flag is enabled.

if debug_flag == true then
	script.on_event(defines.events.on_player_created, function(event)
		for _, item in pairs(debug_items) do
			game.players[event.player_index].insert(item)
		end
	end)
end