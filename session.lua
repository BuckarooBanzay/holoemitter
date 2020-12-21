
function holoemitter.is_active(emitterpos, session)
	local meta = minetest.get_meta(emitterpos)
	return meta:get_int("session") == session
end
