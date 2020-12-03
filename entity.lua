
minetest.register_entity("holoemitter:entity", {
	initial_properties = {},

	on_step = function(self)
		-- sanity checks
		if not self.data or not self.data.emitterpos then
			self.object:remove()
			return
		end

		local now = os.time()
		if self.lastcheck and (now - self.lastcheck) < 2 then
			-- don't check every time
			return
		end

		-- set last check time
		self.lastcheck = now

		local meta = minetest.get_meta(self.data.emitterpos)
		if meta:get_int("session") ~= self.data.session then
			self.object:remove()
			return
		end
	end,

	on_punch = function(self, puncher)
		if not self.data or not self.data.emitterpos then
			self.object:remove()
			return
		end

		digilines.receptor_send(self.data.emitterpos, holoemitter.digiline_rules, "holoemitter", {
			playername = puncher:get_player_name(),
			action = "punch",
			id = self.data.id
		})

		return true
	end,

	on_rightclick = function(self, clicker)
		if not self.data or not self.data.emitterpos then
			self.object:remove()
			return
		end

		digilines.receptor_send(self.data.emitterpos, holoemitter.digiline_rules, "holoemitter", {
			playername = clicker:get_player_name(),
			action = "rightclick",
			id = self.data.id
		})
	end,

	get_staticdata = function(self)
		return minetest.serialize(self.data)
	end,

	on_activate = function(self, staticdata)
		self.data = minetest.deserialize(staticdata)

		if not self.data then
			self.object:remove()
			return
		end

		self.object:set_properties(self.data.properties)

	end
});
