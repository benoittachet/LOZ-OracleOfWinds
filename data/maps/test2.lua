-- Lua script of map test2.
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
  game.clock:stop()
  
  fee_mov = sol.movement.create("random")
  fee_mov:set_speed(16)
  fee_mov:start(fee)

  -- exemple de lumière qui suit un élément mobile
  light_mov = sol.movement.create("target")
  light_mov:set_target(fee)
  light_mov:set_speed(1000)
  light_mov:set_ignore_obstacles(true)
  light_mov:start(lumiere_fee)
 
  heroX, heroY = hero:get_position()
  hero_light:set_position(heroX, heroY)
  hero_light_mov = sol.movement.create("target")
  hero_light_mov:set_target(hero)
  hero_light_mov:set_speed(1000)
  hero_light_mov:set_ignore_obstacles(true)
  hero_light_mov:start(hero_light)
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