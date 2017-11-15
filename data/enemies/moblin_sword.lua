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
function movement:on_finished()
  print("idle")
  sol.timer.start(2000,function()
    enemy:move(movement_distance)
    print("move")
    return false
  end)
end


enemy.choose_random_direction = choose_random_direction
enemy.test_obstacles_dir = test_obstacles_dir

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(10)
  enemy:set_damage(1)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_started()
  print("idle (restarted)")
  sol.timer.start(5000,function()
    enemy:move(movement_distance)
    print("move")
    return false
  end)

end

function enemy:move(distance)
  
  movement:set_angle(enemy.choose_random_direction(enemy,function(enemy,dir) return not enemy:test_obstacles_dir(dir,movement_distance) end)*math.pi/2)
  
  movement:set_max_distance(distance)   
  movement:start(enemy)

 
end

