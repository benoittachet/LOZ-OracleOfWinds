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
local movement_distance = 32

local detect_angle = math.pi/2
local detect_distance = 48
local detect_state

enemy.choose_random_direction = choose_random_direction
enemy.test_obstacles_dir = test_obstacles_dir
enemy.cone_detect = cone_detect

-- Event called when the enemy is initialized.

function enemy:movement_cycle()
  print("Starting movement cycle")

  local m = sol.movement.create("target")
  m:set_target(hero)
  m:start(enemy)  

  sol.timer.start(enemy,3000,function()
    print("Calling the movement process")
    enemy:move(movement_distance)
    return false
  end)
 enemy:set_enabled(true)
end

function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:get_sprite():set_direction(math.random(0,3))
  enemy:set_life(5)
  enemy:set_damage(1)
  sol.timer.start(enemy,100,function()
    enemy:check_hero()
  end)
  enemy.detect_state = false

  enemy:movement_cycle()
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
end

function enemy:move(distance)
  
  movement = sol.movement.create("straight")
  movement:set_speed(48)
  print("Movement process starting")
  print("Choosing random direction")
  local mdir = enemy.choose_random_direction(enemy,
   function(enemy,dir) return not enemy:test_obstacles_dir(dir,movement_distance) end)
  print("Chosen dir : "..mdir)  
  enemy:get_sprite():set_direction(mdir)
  movement:set_angle(mdir*math.pi/2)
  movement:set_max_distance(distance) 
  print("Final movement parameters :"..movement:get_angle().."|"..movement:get_max_distance())  
  movement:start(enemy,function()enemy:movement_cycle()end)
  print("Started the movement")
end

function enemy:check_hero()
  if detect_state == false then
    if enemy:cone_detect(hero,detect_distance,enemy:get_sprite():get_direction(),detect_angle) then
      print("ALED LA LICRA M'A REPÉRÉ")
    end
  end
end

