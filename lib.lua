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

MyEntity = {
	name,
	position,
	direction,
	force,
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end
}

debug_flag = false
debug_items = {{name = "wooden-chest", count = 1},
	{name = "iron-axe", count = 1},
	{name = "storage-tank", count = 1},
	{name = "offshore-pump", count = 1},
	{name = "pipe", count = 50}}

--add function to check if inventory is full

function checkInv(inv, name)
	local item = inv.find_item_stack(name) or nil
	for i = 1, #inv do
		if not inv[i].valid_for_read then
			return true
		end
	end
	if item ~= nil then
		if item.count == 1 then
			return true
		end
	end
	return false
end

--add function to remove one storage tank from Y inventory

function removeItem(inv, name)
	local name = name or "storage-tank"
	if inv.find_item_stack(name) ~=nil then
		inv.find_item_stack(name).count = inv.find_item_stack(name).count - 1
		return true
	else
		return false
	end
end

--add function to add X Storage Tank to Y inventory and set durability

function addItem(inv, stack, name)
	local name = name or "-storage-tank"
	local itemStack = {}
	itemStack.name = stack.type..name
	itemStack.count = 1
	for i = 1, #inv do
		if not inv[i].valid_for_read then
			inv[i].set_stack(itemStack)
			inv[i].durability = stack.amount
			break
		end
	end
end

--add function to replace entity

function replaceEntity(entity, surf, contents)
	local contents = contents or nil
	local new = game.surfaces[surf].create_entity(entity)
	new.fluidbox[1] = contents
end

--add function to remove dropped item

function killItem(surf, pos)
	item = game.surfaces[surf].find_entities_filtered({name = "item-on-ground", area = {left_top = {pos.x-3, pos.y-3}, right_bottom = {pos.x+3, pos.y+3}}})
	for k, v in pairs(item) do
		v.destroy()
	end
end