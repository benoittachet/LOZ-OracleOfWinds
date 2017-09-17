-- Lua script of enemy octorok.
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

-- Quelques paramètres
local walking_time = 700 --ms
local idle_time = 500 --ms
local chance_to_throw = 20 --%
local speed = 40


local restart_movement = true
local distance = 0

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(2)
  enemy:set_damage(1)
end

-- Event called when the enemy should start or restart its movements.
-- This is called for example after the enemy is created or after
-- it was hurt or immobilized.
function enemy:on_restarted()
  -- Création du mouvement ciblé sur le héro
  restart_movement = true
  distance = 0
  movement = sol.movement.create("path")
  movement:set_speed(speed)
  movement:set_path{2*enemy:choose_direction()}
  movement:start(enemy)

  -- On le laisse marcher un certain temps
  sol.timer.start(enemy, walking_time, idle)
end

function idle()
  -- Puis on l'arrête
  restart_movement = false
  movement:stop()
  sprite:set_animation("stopped")
  -- Soit on lance un caillou
  if math.random(100) < chance_to_throw then
    sol.timer.start(enemy, idle_time/2, throw_rock)
  else -- Soit on recommence la séquence
    sol.timer.start(enemy, idle_time, function()
      enemy:restart()
    end)
  end
end

function throw_rock()
  -- Pour lancer un caillou, on prépare toutes les propriétés de l'entitée custom
  local properties = {}
  properties.model = "octorok_rock"
  properties.x, properties.y, properties.layer = enemy:get_position()
  properties.y = properties.y - 5
  properties.width = 16
  properties.height = 16
  properties.direction = sprite:get_direction()
  -- Puis on la crée
  map:create_custom_entity(properties)
  
  -- On recommence la séquence
  sol.timer.start(enemy, idle_time/2, function()
    enemy:restart()
  end)
end

function enemy:on_movement_changed(movement)
  -- Mise à jour de la direction du sprite en fonction de la direction du mouvement
  local direction4 = movement:get_direction4()
  sprite:set_direction(direction4)
end


-- Fonction utilitaire
function directions_from_angle(angle)
  local directions = {}
  angle = math.fmod(angle, 2*math.pi)
  directions[0] = math.mod(math.floor(angle / (math.pi / 2) + 0.5), 4)
  if directions[0] == 0 then
    if angle > math.pi then
      directions[1] = 3
    else
      directions[1] = 1
    end
  else
    if angle - math.pi/2 * directions[0] > 0 then
      directions[1] = math.mod(directions[0] + 1, 4)
    else
      directions[1] = math.mod(directions[0] - 1, 4)
    end
  end
  directions[2] = math.mod(directions[1] + 2, 4)
  directions[3] = math.mod(directions[0] + 2, 4)

  return directions
end

function enemy:choose_direction()
  local dirs = directions_from_angle(enemy:get_angle(map:get_hero()))
  local continue = true
  local i = 0
  while continue and i < 4 do
    if not enemy:test_obstacles((1-dirs[i])*math.mod(dirs[i]+1,2), (dirs[i]-2)*math.mod(dirs[i],2)) then
      continue = false
    else
      i = i+1
    end
  end

  return dirs[math.mod(i, 4)]
end

function enemy:on_position_changed(x, y, layer)
  distance = distance + 1
  if restart_movement and distance >= 7 then
    movement:set_path{2*enemy:choose_direction()}
    distance = 0
  end
end