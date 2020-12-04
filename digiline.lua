
holoemitter.digiline_rules = {
	-- digilines.rules.default
	{x= 1,y= 0,z= 0},{x=-1,y= 0,z= 0}, -- along x side
	{x= 0,y= 0,z= 1},{x= 0,y= 0,z=-1}, -- along z side
	{x= 1,y= 1,z= 0},{x=-1,y= 1,z= 0}, -- 1 node above along x diagonal
	{x= 0,y= 1,z= 1},{x= 0,y= 1,z=-1}, -- 1 node above along z diagonal
	{x= 1,y=-1,z= 0},{x=-1,y=-1,z= 0}, -- 1 node below along x diagonal
	{x= 0,y=-1,z= 1},{x= 0,y=-1,z=-1}, -- 1 node below along z diagonal
	{x= 0,y= 1,z= 0},{x= 0,y=-1,z= 0}, -- along y above and below
}

local allowed_properties = {
	"visual",
	"visual_size",
	"mesh",
	"textures",
	"automatic_rotate",
	"glow",
	"physical",
	"collide_with_objects",
	"pointable",
	"nametag"
}

local allowed_visuals = {
	["cube"] = true,
	["mesh"] = true,
}

local function sanitize_properties(properties)
	if not properties then
		return false, "properties is nil"
	end

	local newprops = {}
	-- map allowed properties
	for _, key in ipairs(allowed_properties) do
		newprops[key] = properties[key]
	end

	if not allowed_visuals[newprops.visual] then
		return false, "visual not allowed"
	end

	return true, newprops
end

function holoemitter.digiline_effector(pos, _, channel, msg)
	local msgt = type(msg)
	if msgt ~= "table" then
		return
	end

	local meta = minetest.get_meta(pos)

	local set_channel = meta:get_string("channel")
	if channel ~= set_channel then
		return
	end

	if msg.command == "emit" then

		if not msg.pos or not msg.pos.x or not msg.pos.y or not msg.pos.z then
			-- bad position
			digilines.receptor_send(pos, holoemitter.digiline_rules, "holoemitter", {
				error = true,
				message = "invalid position"
			})
			return
		end

		local epos = vector.add(pos, msg.pos)

		if vector.distance(pos, epos) > 32 then
			digilines.receptor_send(pos, holoemitter.digiline_rules, "holoemitter", {
				error = true,
				message = "position out of range"
			})
		end

		local ok, result = sanitize_properties(msg.properties)
		if not ok then
			-- sanitation failed
			digilines.receptor_send(pos, holoemitter.digiline_rules, "holoemitter", {
				error = true,
				message = result
			})
			return
		end

		local data = {
			properties = msg.properties,
			session = meta:get_int("session"),
			emitterpos = pos,
			id = msg.id
		}
		minetest.add_entity(epos, "holoemitter:entity", minetest.serialize(data))

	elseif msg.command == "reset" then
		meta:set_int("session", math.random(10000))
	end
end
