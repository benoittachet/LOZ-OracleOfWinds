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
local firing_time = 50 --ms
local chance_to_throw = 80 --%
local speed = 40


local restart_movement = true
local distance = 0

local goal_direction = -1
local forbidden_direction = -1
local counter = 0

-- Event called when the enemy is initialized.
function enemy:on_created()

  -- Initialize the properties of your enemy here,
  -- like the sprite, the life and the damage.
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  enemy:set_life(2)
  enemy:set_damage(2)
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
  local dir = enemy:choose_direction()
  movement:set_path{2*dir, 2*dir}
  movement:start(enemy)

  if counter > 0 then
    counter = counter - 1
  else
    forbidden_direction = -1
    goal_direction = -1
  end

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
    sol.timer.start(enemy, idle_time/2, function()
      sprite:set_animation("firing")
      sol.timer.start(enemy,firing_time,throw_rock)
    end)
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
  sprite:set_animation("stopped")
  -- On recommence la séquence
  sol.timer.start(enemy, idle_time/2 - firing_time, function()
    enemy:restart()
  end)
end

function enemy:on_movement_changed(movement)
  -- Mise à jour de la direction du sprite en fonction de la direction du mouvement
  local direction4 = movement:get_direction4()
  sprite:set_direction(direction4)
end


-- Fonction utilitaire
-- On construit un tableau de 4 éléments qui contient les 4 directions dans l'ordre
-- de celle qui est la plus proche de l'angle donné à celle qui est la plus éloignée
function directions_from_angle(angle)
  local directions = {}
  -- On vérifie que l'angle est dans [0, 2π[
  angle = math.fmod(angle, 2*math.pi)
  -- On divise l'angle par π/2, on a quelque chose dans [0, 4[
  -- Entre 0.5 et 1.5, c'est la direction haut (1), entre 1.5 et 2.5 c'est gauche (2)...
  -- Cas particulier pour droite (0) qui est > 3.5 ou < 0.5
  -- Du coup on rajoute 0.5, on a donc : 
  --  < 1 -> droite : 0
  --  > 1 et < 2 ->haut : 1 ...
  -- On prend donc l'arrondi au dessous (floor) modulo 4 pour revenir à 0 quand on est à 4
  directions[0] = math.floor(angle / (math.pi / 2) + 0.5) % 4
  -- Selon de quel côté (> ou <) l'angle se trouve par rapport à la direction principale,
  -- la direcion secondaire n'est pas la même. Cas particulier où la direction principale est la droite
  if directions[0] == 0 then
    if angle > math.pi then
      -- Angle plus vers le bas
      directions[1] = 3
    else
      -- Angle plus vers le haut
      directions[1] = 1
    end
  else
    if angle - math.pi/2 * directions[0] > 0 then
      -- L'angle est plus grand que la direction ramenée à un angle
      directions[1] = (directions[0] + 1) % 4
      -- On est plus proche de direction suivante
    else
      -- Sinon, on est plus proche de la direction précédente
      directions[1] = (directions[0] - 1) % 4
    end
  end
  -- La troisième direction est l'opposée de la deuxième
  directions[2] = (directions[1] + 2) % 4
  -- La quatrième est l'opposée de la première
  directions[3] = (directions[0] + 2) % 4

  return directions
end

function enemy:choose_direction()


  -- On récupère les directions 
  local dirs = directions_from_angle(enemy:get_angle(map:get_hero()))
  local continue = true
  local i = 0
  while continue and i < 4 do
    -- On teste s'il y a un obstacle à côté de l'ennemi dans la direction dims[i]
    if not enemy:test_obstacles((1-dirs[i])*((dirs[i]+1) % 2), (dirs[i]-2)*(dirs[i] % 2)) then
      if  i == 2 or i == 3 or dirs[i] ~= forbidden_direction then
        continue = false
      else
        i = i+1
      end
    else
      i = i+1
    end
  end

  if i ==0 and dirs[0] == goal_direction then
    goal_direction = -1
    forbidden_direction = -1
  end
  if i == 1 then
    goal_direction = dirs[0]
    forbidden_direction = dirs[2]
    counter = 2
  end
  if i == 2 and dirs[2] == (goal_direction + 2) % 4 then
    i = 3
  end

  return dirs[i % 4]
end

function enemy:on_position_changed(x, y, layer)
  distance = distance + 1
  if restart_movement and distance >= 8 then
    local dir = enemy:choose_direction()
    movement:set_path{2*dir, 2*dir}
    distance = 0
  end
end
