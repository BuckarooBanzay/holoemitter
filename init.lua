
holoemitter = {
}

-- sanity checks
assert(minetest.features.add_entity_with_staticdata, "add_entity_with_staticdata not supported")

local MP = minetest.get_modpath("holoemitter")
dofile(MP.."/digiline.lua")
dofile(MP.."/node.lua")
dofile(MP.."/entity.lua")
