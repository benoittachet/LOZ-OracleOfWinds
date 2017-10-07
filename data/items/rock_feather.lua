-- Lua script of item rock_feather.
-- This script is executed only once for the whole game.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local item = ...
local game = item:get_game()
local hero = game:get_hero()


function item:on_created()

 self:set_savegame_variable("possession_rockfeather")
end 
-- Event called when the hero is using this item.
function item:on_using()
  hero:start_jump()
  
  item:set_finished()
end
