 local game_meta = sol.main.get_metatable("game")

local function map_callback(game, map)
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, 16)
end  
game_meta:register_event("on_map_changed", map_callback)

require("scripts/input_manager")(game_meta)

--The following scripts also modify the game metatable :
-- - menus/dialog_box