


minetest.register_node("holoemitter:holoemitter", {
  description = "Holoemitter",

  tiles = {
    "default_stone.png"
  },

  on_construct = function(pos)
		-- inventory
		local meta = minetest.get_meta(pos)
		-- default digiline channel
		meta:set_string("channel", "holoemitter")
  end,

  groups = {
    cracky = 3,
    oddly_breakable_by_hand = 3
  },

  digiline = {
		receptor = {
			rules = holoemitter.digiline_rules,
			action = function() end
		},
		effector = {
			rules = holoemitter.digiline_rules,
			action = holoemitter.digiline_effector
		}
	},
})
