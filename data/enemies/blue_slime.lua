-- Lua script of enemy blue_slime.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest

local dash_values = {
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}, {16, 16, 8, 13}},
  {{8, 24, 8, 17}, {24, 8, 12, 5}, {8, 24, 0, 17}, {24, 8, 12, 5}},
  {{8, 24, 8, 17}, {24, 8, 12, 5}, {8, 24, 0, 17}, {24, 8, 12, 5}},
  {{8, 32, 8, 21}, {32, 8, 16, 5}, {8, 32, 0, 21}, {32, 8, 16, 5}},
}

local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite
local movement
enemy.cone_detect = cone_detect

local detect_angle = math.pi/2
local detect_distance = 64
local dash = sol.movement.create("straight")

-- Dash methods

function dash:on_position_changed()
  local x, y = dash.enemy:get_position()
  local d = math.sqrt(math.pow(x - dash.xs, 2) + math.pow(y - dash.ys, 2))
  local i = 0         
  if d > 16 then i = 1 end
  if d > 32 then i = 2 end 
  if d > 48 then i = 3 end
  if d > 64 then i = 4 end
  if d > 80 then i = 5 end
  if d > 96 then i = 6 end
  if not (enemy.dash_state == i) then 
    enemy:set_dash_state(i)
  end 
end

function dash:on_obstacle_reached() 
  dash:dEnd()
end

function dash:dEnd()
  dash:stop()
  enemy:set_size(16, 16)
  enemy:set_origin(8,13)
  enemy:set_position(dash.xs, dash.ys)
  enemy:restart() 
end

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(5)
  enemy:set_damage(1)
  enemy:set_obstacle_behavior("swimming")
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  enemy:set_attacks_state(1) 
  enemy.on_attacking_hero = nil
  sol.timer.start(enemy, 100, function()
    for i = 0,3 do
      if enemy:cone_detect(hero, detect_distance, i, detect_angle) then
        enemy:dash(i)
        return false
      end   
    end
    return true
  end)
end

local function get_dash_values(i, d)
  return 
    dash_values[i + 1][d + 1][1],
    dash_values[i + 1][d + 1][2],
    dash_values[i + 1][d + 1][3],
    dash_values[i + 1][d + 1][4]
end

function enemy:set_dash_state(i)
  sprite:set_animation('dash'..i)
  local w, h, x, y = get_dash_values(i, sprite:get_direction())
  enemy:set_size(w, h)
  enemy:set_origin(x, y)
  enemy.dash_state = i
end

function enemy:set_attacks_state(state)
  enemy:set_attack_consequence("sword", state)
  enemy:set_attack_consequence("arrow", state)
  enemy:set_attack_consequence("hookshot", state)
  enemy:set_attack_consequence("boomerang", state)
end

local hit_callback = function()
  local m = sol.movement.create("straight")
  m:set_angle(sprite:get_direction() * math.pi / 2)
  m:set_speed(240)
  m:set_max_distance(400)
  function m:on_obstacle_reached()
    m:stop()
    hero:start_hurt(enemy:get_damage())
  end
  hero:set_invincible(true)
  hero:set_blinking(true)
  m:start(hero)
  dash:dEnd()
end

function enemy:dash(d)
  self:stop_movement()
  enemy:set_dash_state(0)
  sprite:set_direction(d)
  enemy.dash_state = 0
  sol.timer.start(self, 400, 
    function()    
      enemy:set_attacks_state("protected")
      dash.xs, dash.ys = enemy:get_position()
      dash.enemy = enemy      
      dash:set_speed(64)
      dash:set_angle(d * (math.pi / 2))

      enemy.on_attacking_hero = hit_callback

      dash:start(enemy)
    end
  )
end
