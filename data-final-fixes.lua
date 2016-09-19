require("util")

for k, v in pairs(data.raw["fluid"]) do
	local side = v.base_color
	local line = v.flow_color
	side["a"] = 0.7
	line["a"] = 0.8
	data:extend({
   {
    type = "tool",
    name = v.name.."-storage-tank",
	localised_name = {"item-name.pocket-tank", {"fluid-name." .. v.name}},	
	icons = {
		{
			icon = "__base__/graphics/icons/storage-tank.png"
		},
		{
			icon = "__better-storage-tanks__/graphics/icons/mask-orig.png",
			tint = side
		},
		{
			icon = "__better-storage-tanks__/graphics/icons/mask-outline-orig.png",
			tint = line
		}
	},
    
    flags = {"goes-to-quickbar"},
    subgroup = "storage",
    order = "b[fluid]-a[storage-tank]",
    place_result = "storage-tank",
	stack_size = 1,
    stackable = false,
	durability = 2500
  }
  })
end