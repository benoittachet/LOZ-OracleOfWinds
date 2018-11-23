-- Lua script of custom entity platform.
-- This script is executed every time a custom entity with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero = map:get_hero()
local px, py, x, y, dx, dy, hx, hy = 0, 0, 0, 0, 0, 0

-- Event called when the custom entity is initialized.
function entity:on_created()
  entity:set_size(32,32)
  entity:set_origin(16,16)
  entity:set_modified_ground("traversable")
  self:set_can_traverse_ground("hole", true)
  self:set_can_traverse_ground("deep_water", true)
  self:set_can_traverse_ground("traversable", false)
  self:set_can_traverse_ground("shallow_water", false)
  self:set_can_traverse_ground("wall", false)
  local m = sol.movement.create("straight")
  m:set_speed(16)
  m:set_angle(math.pi / 2)
  m:start(entity)
  
  entity:add_collision_test("overlapping", entity.collision_callback)
  entity.on_position_changed = entity.movement_callback
  px, py = entity:get_position()
end

function entity:collision_callback(other)
  
  if other:get_type() == "hero" then
    hero.is_on_nonsolid_ground = true
  end
end

local function hero_can_be_moved()
  local s = hero:get_state()
  return s ~= "falling" and s ~= "jumping" and s ~= "plunging"
end 

function entity:movement_callback()
  x, y = entity:get_position()
  if entity:overlaps(hero) and hero_can_be_moved() then
    dx, dy = x - px, y - py
    hx, hy = hero:get_position()
    if not hero:test_obstacles(dx, dy) then hero:set_position(hx + dx, hy + dy) end

    if entity:overlaps(hero, "overlapping") then
      hero.is_on_nonsolid_ground = true
    end
  end
  px, py = x, y
end