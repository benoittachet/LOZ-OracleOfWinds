-- Lua script of custom entity deep_water.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()

-- Event called when the custom entity is initialized.
function entity:on_created()

  -- Initialize the properties of your custom entity here,
  -- like the sprite, the size, and whether it can traverse other
  -- entities and be traversed by them.
  entity:set_size(16, 16)
  entity:set_origin(8, 13)
  entity:set_traversable_by(true)
  entity:create_sprite("entities/deep_water")
  entity:set_modified_ground("deep_water")
end
