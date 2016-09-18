require("util")

for k, v in pairs(data.raw["fluid"]) do
	data:extend({
   {
    type = "tool",
    name = v.name.."-storage-tank",
	localised_name = {"item-name.pocket-tank", {"fluid-name." .. v.name}},	
    icon = "__base__/graphics/icons/storage-tank.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "storage",
    order = "b[fluid]-a[storage-tank]",
    place_result = "storage-tank",
	stack_size = 1,
    stackable = false,
	durability = 2500
  }
  })
end