-- Lua script of map test.
-- This script is executed every time the hero enters this map.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation:
-- http://www.solarus-games.org/doc/latest

local map = ...
local game = map:get_game()

-- Event called at initialization time, as soon as this map becomes is loaded.
function map:on_started()
  game.clock.outside = true
  game.clock:run()

  --map:get_camera():set_size(320, 224)
  --map:get_camera():set_position_on_screen(0, 16)
  -- You can initialize the movement and sprites of various
  -- map entities here.
end

-- Event called after the opening transition effect of the map,
-- that is, when the player takes control of the hero.
function map:on_opening_transition_finished()

end

function georges:on_interaction()
  if game.clock:isDay() then
    game:start_dialog("georges.jour")
  else
    game:start_dialog("georges.nuit")
  end
end