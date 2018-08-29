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
local movement_speed = 48
local movement_speed_target = 48

local detect_angle = math.pi/2
local detect_distance = 16
local detect_state

enemy.choose_random_direction = choose_random_direction
enemy.test_obstacles_dir = test_obstacles_dir
enemy.cone_detect = cone_detect

-- Event called when the enemy is initialized.

function enemy:movement_cycle()
  --print("Starting movement cycle")

  sol.timer.start(enemy,1500,function()
   -- print("Calling the movement process")
    enemy:move(movement_distance)
    return false
  end)
 enemy:set_enabled(true)
end

function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  --sprite = enemy:create_sprite("enemies/moblin")
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:get_sprite():set_direction(math.random(0,3))
  enemy:set_life(4)
  enemy:set_damage(2)
  enemy.detect_state = false
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  enemy:get_sprite():set_paused()  
  if self.detect_state == false then
    sol.timer.start(enemy,100,function()
      enemy:check_hero()
      return true
    end)

    enemy:movement_cycle()
  else
    enemy:target_hero()
  end
end

function enemy:move(distance)
  
  movement = sol.movement.create("straight")
  movement:set_speed(48)
  local mdir = enemy.choose_random_direction(enemy,
   function(enemy,dir) return not enemy:test_obstacles_dir(dir,8) end)
  enemy:get_sprite():set_direction(mdir)
  movement:set_angle(mdir*math.pi/2)
  movement:set_max_distance(distance)  
  movement:start(enemy,function()enemy:movement_cycle()end)

  movement.on_position_changed = function()
    local dir = movement:get_direction4()
    if enemy:test_obstacles(dirCoef[dir + 1].x * 8, dirCoef[dir + 1].y * 8) then
      movement:set_max_distance(-1)
    end
  end

end

function enemy:check_hero()
  if self.detect_state == false then
    if enemy:cone_detect(hero,detect_distance,sprite:get_direction(),detect_angle) then
       enemy:target_hero()
    end
  end
end

function enemy:target_hero()
  enemy:stop_movement()
  self.detect_state = true   
  local m = sol.movement.create("target")
  sol.timer.stop_all(enemy)
  m:set_target(hero)
  m:set_speed(movement_speed_target)

  m.on_position_changed = function()
   sprite:set_direction(dir_from_angle(enemy:get_angle(hero)))
  end

  m:start(enemy)
end

function enemy:on_hurt(atk)
  if atk == "sword" then
    sol.timer.start(enemy,200,function()  
      enemy:target_hero()
    end)
  end
end

function enemy:on_movement_started()
 sprite:set_paused(false)  
end

function enemy:on_movement_finished()
 sprite:set_paused()
end
