-- Lua script of enemy moblin_sword.
-- This script is executed every time an enemy with this model is created.

-- Feel free to modify the code below.
-- You can add more events and remove the ones you don't need.

-- See the Solarus Lua API documentation for the full specification
-- of types, events and methods:
-- http://www.solarus-games.org/doc/latest


local enemy = ...
local game = enemy:get_game()
local map = enemy:get_map()
local hero = map:get_hero()
local sprite

local movement
local movement_distance = 48
movement = sol.movement.create("straight")
movement:set_speed(48)


enemy.choose_random_direction = choose_random_direction
enemy.test_obstacles_dir = test_obstacles_dir

-- Event called when the enemy is initialized.

function enemy:movement_cycle()
  print("idle")
  enemy.timer = sol.timer.start(3000,function()
    print("request movement")
    enemy:move(movement_distance)
    return false
  end)
end

function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(10)
  enemy:set_damage(1)
  
  enemy:movement_cycle()
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
end

function enemy:move(distance)
  
  print("movement starting")
  
  local mdir = enemy.choose_random_direction(enemy,
   function(enemy,dir) return not enemy:test_obstacles_dir(dir,movement_distance) end)
  movement:set_angle(mdir*math.pi/2)
  movement:set_max_distance(distance) 
  print(movement:get_angle().."|"..movement:get_max_distance())  
  movement:start(enemy,function()enemy:movement_cycle()end)

  print("movement started : " .. mdir)

end

