
minetest.register_entity("holoemitter:entity", {
	initial_properties = {},

	on_step = function(self, dtime)
		-- sanity checks
		if not self.data or not self.data.emitterpos then
			self.object:remove()
			return
		end

		if not self.dtime then
			-- set dtime
			self.dtime = dtime
		else
			-- increment
			self.dtime = self.dtime + dtime
		end

		if self.dtime < 2 then
			-- skip check
			return
		end

		if not holoemitter.is_active(self.data.emitterpos, self.data.session) then
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
