local input_manager = {}

function input_manager:on_key_pressed(key, modifiers)
  local handled = false
  if key == "f5" then
    -- F5: change the video mode.
    sol.video.switch_mode()
    handled = true
  elseif key == "f6" then
    sol.video.switch_scale()
  elseif key == "f11" or
    (key == "return" and (modifiers.alt or modifiers.control)) then
    -- F11 or Ctrl + return or Alt + Return: switch fullscreen.
    sol.video.set_fullscreen(not sol.video.is_fullscreen())
    handled = true
  elseif key == "f4" and modifiers.alt then
    -- Alt + F4: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "escape" and sol.main.game == nil then
    -- Escape in title screens: stop the program.
    sol.main.exit()
    handled = true
  elseif key == "f1" then
    sol.main.game:get_hero():teleport("Map1")
  elseif key == "f2" then
    sol.main.game:get_hero():teleport("donjon_rc")
  elseif key == "f3" then
    sol.main.game:set_life(12)  
  elseif key == "f7" then
    print(sol.main.game:get_value("small_keys"))
  end

  return handled
end

return input_manager