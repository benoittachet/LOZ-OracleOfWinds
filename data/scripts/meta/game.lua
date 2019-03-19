 local game_meta = sol.main.get_metatable("game")

function game_meta:on_map_changed(map)
  print("oui")
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, 16)
end  