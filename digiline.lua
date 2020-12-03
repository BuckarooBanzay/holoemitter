
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
    local epos = vector.add(pos, msg.pos)
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
