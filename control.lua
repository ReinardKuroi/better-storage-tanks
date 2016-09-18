require "util"

Liquid = {
	type = "",
	amount = 0,
	temperature = 25,
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		self.type = ""
		self.amount = 0
		self.temperature = 25
		return o
	end
}

liquid_transfer = Liquid:new()
tank_had_fluid = false
debug_flag = true
player_transfer = nil
debug_items = {{name = "wooden-chest", count = 1},
	{name = "iron-axe", count = 1},
	{name = "storage-tank", count = 1},
	{name = "offshore-pump", count = 1},
	{name = "pipe", count = 50}}

script.on_event(defines.events.on_put_item, function(event)
	local player = game.players[event.player_index]
	local item = player.cursor_stack
	local f = Liquid:new()
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
			liquid_transfer = Liquid:new(fluid)
			liquid_transfer.amount = math.floor(liquid_transfer.amount)
		end
	else tank_had_fluid = false end
end)

script.on_event(defines.events.on_player_mined_item, function(event)
	local player = game.players[event.player_index]
	local inv = player.get_inventory(defines.inventory.player_main)
	local quick = player.get_inventory(defines.inventory.player_quickbar)
	local trash = player.get_inventory(defines.inventory.player_trash)
	local flag_insert = false
	if tank_had_fluid == true then
		local itemStack = {}
		itemStack.name = liquid_transfer.type.."-storage-tank"
		itemStack.count = 1
		if quick.find_item_stack("storage-tank") ~=nil then
			quick.find_item_stack("storage-tank").count = quick.find_item_stack("storage-tank").count - 1
		elseif inv.find_item_stack("storage-tank") ~=nil then
			inv.find_item_stack("storage-tank").count = inv.find_item_stack("storage-tank").count - 1
		elseif trash.find_item_stack("storage-tank") ~=nil then
			trash.find_item_stack("storage-tank").count = trash.find_item_stack("storage-tank").count - 1
		else
			error("Error while removing extra storage tank from inventory")
		end
		for i = 1, #quick+#inv do
			if i<=#quick then
				if not quick[i].valid_for_read then
					quick[i].set_stack(itemStack)
					quick[i].durability = liquid_transfer.amount
					flag_insert = true
					break
				end
			else
				if not inv[i-#quick].valid_for_read then
					inv[i-#quick].set_stack(itemStack)
					inv[i-#quick].durability = liquid_transfer.amount
					flag_insert = true
					break
				end
			end
		end
		if flag_insert == false then
			if not player.cursor_stack.valid_for_read then
				player.cursor_stack.set_stack(itemStack)
				player.cursor_stack.durability = liquid_transfer.amount
			else
				error("Expected error. You've tried to mine a tank with full inventory and cursor stack. We are working on a handler for this event.")
			end
		end
		tank_had_fluid = false
	end
end)