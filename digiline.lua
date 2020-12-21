local has_font_api = minetest.get_modpath("font_api")

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

	if msg.command == "reset" then
		-- reset command
		meta:set_int("session", math.random(10000))
		return
	end

	-- emit commands below, extract and validate position
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
		return
	end

	if msg.command == "emittext" and msg.text and has_font_api then
		-- render font
		local font = font_api.get_font("metro")
		local size_x = tonumber(msg.size_x) or 2
		local size_y = tonumber(msg.size_y) or 1
		local lines = tonumber(msg.lines) or 1

		local textureh = font:get_height(size_y)
		local texturew = textureh * size_x / size_y

		print(textureh, texturew)

		local texture = font:render(msg.text, texturew, textureh, {
			lines = lines,
			halign = "center",
			valign = "top",
			color = msg.color or "#ff0000"
		})

		print(texture)

		local data = {
			properties = {
				visual = "upright_sprite",
	      visual_size = {x=size_x,y=size_y},
	      textures = { texture },
	      glow = tonumber(msg.glow) or 0,
	      physical = false,
	      collide_with_objects = false,
	      pointable = true
			},
			session = meta:get_int("session"),
			emitterpos = pos,
			id = msg.id
		}
		local entity = minetest.add_entity(epos, "holoemitter:entity", minetest.serialize(data))

		if msg.rotation then
			entity:set_rotation({
				x = tonumber(msg.rotation.x) or 0,
				y = tonumber(msg.rotation.y) or 0,
				z = tonumber(msg.rotation.z) or 0
			})
		end

	elseif msg.command == "emit" then
		-- emit custom entity

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

	end
end
