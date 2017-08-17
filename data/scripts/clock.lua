require('scripts/multi_events')

-- Création de notre table qui contient tout ce qui est nécéssaire
local clock = {}

-- On retient l'état, la valeur et la vitesse de notre horloge
clock.running = false
clock.time = 8000
clock.speed = 3000 -- nombre de ticks par secondes
-- Variables utilisées si la vitesse est grande
clock.realFrequency = clock.speed
clock.increm = 1
-- Initialisation du timer
clock.timer = nil
-- Définit des moment clés dans la journée avec des valeurs associées
clock.timings = {6000,  -- 6h
                 8000,  -- 8h
                 17000, -- 18h
                 19000,
                 21000} -- 21h
clock.maskColors = {{128, 128, 255}, -- à 6h, le masque est un masque de couleur 128, 128, 255 (bleu)
                    {255, 255, 255}, -- à 8h, c'est un masque blanc
                    {255, 255, 255}, -- ainsi de suite
                    {255, 128, 128},
                    {128, 128, 255}}
-- Pour les heures intermédiaires, on interpole
-- Ex: 7h -> (128+255)/2, (128+255)/2, (255+255)/2 car on est pile entre 6 et 8h
clock.lightOpacities = {80, -- Opacité de la lumière à 6h
                        0,  -- à 8h
                        0,  -- ainsi de suite
                        80,
                        80, }
-- C'est interpolé comme les couleurs
-- Définit l'interval jour
clock.dayInter = {7000, 19000} -- entre 7 et 19h, isDay renverra true, en dehors elle renvoie false
-- Définit si on est à l'extérieur ou non (s'il faut afficher le masque)
clock.outside = false
-- Pour avoir accès à la map
clock.game = nil


-- Récupérer le temps
function clock:getTime()
    return self.time
end

-- Changer la valeur du temps en vérifiant qu'il s'agit 
-- bien d'un nombre entier entre 0 et 23999
function clock:setTime(newTime)
    if type(newTime) == "number" then
        self.time = math.floor(newTime % 24000)
    elseif debug then
        print("Error: clock:setTime() expects a number. newTime was a ", type(newTime))
    end
end


-- Mettre en route ou arrêter l'horloge
-- paramètre optionnel, mise en route par défaut
function clock:run(state)
    if state == nil or state then -- si pas d'argument ou true
        if not self.running then
            self.timer = sol.timer.start(1000 / self.realFrequency, function()
                self.time = (self.time + self.increm) % 24000
                return true
            end)
            self.running = true
        end
    elseif self.running then
        self.running = false
        self.timer:stop()
    end
end

-- Arrêter l'horloge
function clock:stop()
    self:run(false)
end


-- Récupérer la vitesse de l'horloge
function clock:getSpeed()
    return self.speed
end

-- Changer la vitesse à laquelle le temps s'écoule en nombre de tick par seconde
function clock:setSpeed(newSpeed)
    if type(newSpeed) == "number" then
        self.speed = newSpeed
        if newSpeed > 50 then
            -- Si la vitesse demandée est importante, on diminue la fréquence et on augmente la valeur de l'incrémentation
            -- Pour 100 ticks par secondes par exemple, le timer aura une fréquence de 50 mais incrémentera le timer de 2
            self.realFrequency = 50
            self.increm = newSpeed / 50
        else
            self.realFrequency = newSpeed
            self.increm = 1
        end
    elseif debug then
        print("Error: clock:setSpeed() expects a number. newTime was an", type(newTime))
    end
end


-- Renvoi true si c'est le jour
function clock:isDay()
  if self.dayInter[1] <= self.dayInter[2] then
    return self.dayInter[1] <= self.time and self.time < self.dayInter[2]
  else
    return self.dayInter[1] <= self.time or self.time < self.dayInter[2]
  end
end

-- Renvoi true si c'est la nuit
function clock:isNight()
  return not self:isDay()
end


function clock:getCurrentColors()
    local timingNumber = table.getn(self.timings) -- combien de moments clés
    local infBoundary, supBoundary = 0, 0 -- les index dans le tableau des instant clé précédent et suivant
    local min, max = 0, 0 -- Les index dans le tableau des moments clé min et max
    local time = self.time -- Pour pas que le temps change durant le traitement
    
    local i = 1
    for i = 1, timingNumber do
        -- Chercher la borne inférieure
        if self.timings[i] <= time and -- Si on est inférieur au temps
           -- On prend l'index de la valeur max
           (infBoundary == 0 or self.timings[infBoundary] < self.timings[i]) then
            infBoundary = i
        end
        
        -- Chercher la borne supérieure
        -- Inversement, on cherche l'index de la valeur minimale des valeurs supérieures au temps
        if self.timings[i] >= time and 
           (supBoundary == 0 or self.timings[supBoundary] > self.timings[i]) then
            supBoundary = i
        end
        
        -- Chercher le minimum
        if min == 0 or self.timings[min] > self.timings[i] then
            min = i
        end
        
        -- Chercher le maximum
        if max == 0 or self.timings[max] < self.timings[i] then
            max = i
        end
    end
    
    -- La borne inférieure n'est pas trouvée, on prend la plus grande valeur
    -- car c'est la dernière valeur du jour précédent
    if infBoundary == 0 then
        infBoundary = max
    end
    
    -- Inversement si la borne supérieure n'est pas trouvée
    if supBoundary == 0 then
        supBoundary = min
    end
    
    local infValue, supValue = self.timings[infBoundary], self.timings[supBoundary]
    
    -- S'il y a un décalage de jour
    if supValue < infValue then
        -- Le temps doit-il aussi être décalé ?
        if time < infValue then
            time = time + 24000
        end
        
        supValue = supValue + 24000
    end
    
    -- Un nombre entre 0 et 1 qui définit la progression entre deux stades
    local progression = (time - infValue) / (supValue - infValue)
    if infValue == supValue then
        progression = 0
    end
    
    local initialMaskColor, finalMaskColor = self.maskColors[infBoundary], self.maskColors[supBoundary]
    
    local currentMaskColor = {progression*finalMaskColor[1] + (1-progression)*initialMaskColor[1],
                              progression*finalMaskColor[2] + (1-progression)*initialMaskColor[2],
                              progression*finalMaskColor[3] + (1-progression)*initialMaskColor[3]}

    local initialLightOpacity, finalLightOpacity = self.lightOpacities[infBoundary], self.lightOpacities[supBoundary]
    
    local currentLightOpacity = progression*finalLightOpacity + (1-progression)*initialLightOpacity
    
    return currentMaskColor, currentLightOpacity
end


-- On récupère toutes les lumières de la map pour les dessiner sur une surface
function clock:makeLightSurface(lightSurface)
  local map = self.game:get_map()
  local camera = map:get_camera()
  
  -- On utilise la caméra pour savoir quelle région de la map est visible à l'instant t et donc pouvoir recaler correctement
  local xCam, yCam = camera:get_position()
  local deltaXCam, deltaYCam = camera:get_origin()
  xCam, yCam = xCam - deltaXCam, yCam - deltaYCam
  
  -- On nettoie la surface
  lightSurface:clear()
  lightSurface:fill_color({0, 0, 0})

  for entity in map:get_entities() do
    if sol.main.get_type(entity) == "custom_entity" and entity.isOutsideLight then
      -- Pour chaque entité custom de la map qui est une lumière extérieure
      local width, height = entity.lightSprite:get_size()
      local surf = sol.surface.create(width, height)
      local xOrig, yOrig = entity.lightSprite:get_origin()  
      entity.lightSprite:draw(surf, xOrig, yOrig)
      -- On dessine le sprite de lumière de cette entité sur une surface intermédiaire
      -- Pour appliquer une transparence sur cette surface (pas possible de changer la transparence d'un sprite)

      surf:set_opacity(128)

      -- Dessine la surface précédemment créée à la bonne position (recadrage par rapport à la cam et à l'origine du sprite)
      local xLight, yLight = entity:get_position()
      surf:draw(lightSurface, xLight - xCam - xOrig, yLight - yCam - yOrig)
    end
  end

  -- On met la suface en blend mode add pour donner l'effet d'éclairage
  lightSurface:set_blend_mode("add")
end


-- Fonction d'iniialisation appelée au démarrage du jeu
function initialize_night(game)
  clock:setSpeed(clock:getSpeed()) -- Pour que realFrequency et increm soit bien calculés

  -- Les deux surfaces utilisées, le masque et la lumière
  local surf = sol.surface.create()
  local light = sol.surface.create()

  -- La fonction appelée à l'evènement on_draw de la map
  function draw_map(map, dst_surface)
    -- S'il s'agit d'un extérieur, on fait notre travail
    if clock.outside then
      -- On récupère les couleurs qu'on doit afficher
      local color, lightOpacity = clock:getCurrentColors()
      -- On utilise la caméra pour savoir où se limite la zone d'affichage de la map
      local camera = map:get_camera()
      local x, y = camera:get_position_on_screen()
      local width, height = camera:get_size()
      surf:set_blend_mode("multiply") -- Pour donner l'effet d'asssombrissement
      surf:fill_color(color) -- La couleur calculée
      surf:draw_region(0, 0, width, height, dst_surface, x, y)
      clock:makeLightSurface(light) -- Préparation de la surface de lumière
      light:set_opacity(2*lightOpacity) -- On donne la bonne opacité
      light:draw_region(0, 0, width, height, dst_surface, x, y)
    end
  end

  -- Lie la fonction draw_map à l'évènement on_draw de toutes les maps
  local map_meta = sol.main.get_metatable("map")
  map_meta:register_event("on_draw", draw_map)

  -- Pour pouvoir travailler sur clock depuis ailleurs (notemment les maps)
  game.clock = clock
  -- Pour avoir accès notemment à la map courante lors de la recherche des entités de lumière
  clock.game = game
end

-- Initialisation au lancement du jeu
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", initialize_night)

return true