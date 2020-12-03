
minetest.register_entity("holoemitter:entity", {
		initial_properties = {
      visual = "upright_sprite",
      visual_size = {x=0.5,y=0.5},
      textures = {
        "default_sand.png",
        "default_sand.png"
      },
      glow = 10,
      physical = false,
      collide_with_objects = false,
      pointable = true
    },
		on_step = function(self)
      --print("on_step")
		end,

    on_punch = function(self, puncher)
      print("on_punch", puncher:get_player_name())
      --return true
    end,

    on_rightclick = function(self, clicker)
      print("on_rightclick", clicker:get_player_name())
    end,

    get_staticdata = function(self)
      return minetest.serialize(self.data)
    end,

    on_activate = function(self, staticdata)
      print("on_activate", dump(staticdata))
      self.data = minetest.deserialize(staticdata)

      if not self.data then
        self.object:remove()
        return
      end

      if self.data.name then
        local properties = self.object:get_properties()
        properties.nametag = self.data.name
        self.object:set_properties(properties)
      end

    end
	});
