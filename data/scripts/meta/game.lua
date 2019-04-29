 local game_meta = sol.main.get_metatable("game")

function game_meta:on_map_changed(map)
  local camera = map:get_camera()
  camera:set_size(160,128)
  camera:set_position_on_screen(0, 16)
end  

function game_meta:set_custom_command_effect(command, fun)
  self.custom_command[command] = fun
end

function game_meta:get_custom_command_effect(command)
  return self.custom_command[command]
end

local function custom_command_callback(game, command)
  if type(game.custom_command[command]) == "function" then
    return game.custom_command[command](game)
  end
end
game_meta:register_event("on_command_pressed", custom_command_callback)


local function start_callback(game)
  game.custom_command = {
    action = nil,
    attack = nil,
    pause = nil,
    item_1 = nil,
    item_2 = nil,
    right = nil,
    up = nil, 
    left = nil,
    down = nil,
  }
end
game_meta:register_event("on_started", start_callback)

--The following scripts also modify the game metatable :
-- - menus/dialog_box