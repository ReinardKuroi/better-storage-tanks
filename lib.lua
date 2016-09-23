require "util"

--					New class for copying various entity parameters. Currently, standart deepcopy breaks Factorio

MyEntity = {
	name = "",
	position = {},
	direction = 0,
	force = "",
	health = 0,
	surface = {},
	fluidbox = {},
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end,
	copy = function(self, o)
		self.name = o.name
		self.position.x = o.position.x
		self.position.y = o.position.y
		self.direction = o.direction
		self.force = o.force
		self.health = math.floor(o.health)
		self.surface.index = o.surface.index
		if o.fluidbox[1] then
			self.fluidbox.type = o.fluidbox[1].type
			self.fluidbox.amount = math.floor(o.fluidbox[1].amount)
			self.fluidbox.temperature = o.fluidbox[1].temperature
		end
	end
}

--					Some stuff for testing

debug_flag = false
debug_items = {{name = "wooden-chest", count = 1},
	{name = "iron-axe", count = 1},
	{name = "storage-tank", count = 1},
	{name = "offshore-pump", count = 1},
	{name = "pipe", count = 50}}
	
--					Looks for an empty spot in the inventory

function checkInv(inv, name)
	local name = name or "storage-tank"
	local item = inv.find_item_stack(name) or nil
	for i = 1, #inv do
		if not inv[i].valid_for_read then
			return true
		end
	end
	if item then
		if item.count == 1 then
			return true
		end
	end
	return false
end

--					Deletes c items with name from inventory, returns true if successful

function removeItem(inv, name, c)
	local name = name or "storage-tank"
	local c = c or 1
	for i = #inv, 1, -1 do
		if inv[i].valid_for_read and inv[i].name == name then
			inv[i].count = inv[i].count - 1
			return true
		end
	end
	return false
end

--					Adds c items with fluid into inventory, returns true if successful

function addItem(inv, entity, name, c)
	local name = name or "storage-tank-"
	local c = c or 1
	local itemStack = {}
	itemStack.name = name..entity.fluidbox.type
	itemStack.count = c
	for i = 1, #inv do
		if not inv[i].valid_for_read then
			inv[i].set_stack(itemStack)
			inv[i].durability = entity.fluidbox.amount
			inv[i].health = entity.health/500
			return true
		end
	end
end

--					Places entity back onto the surface with given parameters, returns true if successful

function replaceEntity(entity)
	local contents = entity.fluidbox or nil
	local health = entity.health
	local new = game.surfaces[entity.surface.index].create_entity(entity)
	if new then
		if contents then
			new.fluidbox[1] = contents
		end
		new.health = health
		return true
	else
		return false
	end
end

--					Destroys one ItemEntity of a given name, returns true if successful

function killItem(entity, name)
	local pos = entity.position
	local item = game.surfaces[entity.surface.index].find_entities_filtered({name = "item-on-ground", area = {left_top = {pos.x-3, pos.y-3}, right_bottom = {pos.x+3, pos.y+3}}})
	local name = name or "storage-tank"
	for k, v in pairs(item) do
		if v.stack.name == name then
			v.destroy()
			return true
		end
	end
end