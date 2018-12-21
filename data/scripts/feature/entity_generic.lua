eg = {}

function eg.cone_detect(detector,detected,distance,direction,angle)
  distance = distance or -1
  angle = angle or 90
  direction = direction or 0
  if detector:get_distance(detected) > distance then
   return false
  else 
    local angleR = detector:get_angle(detected)
    angleR = angleR - ((math.pi/2) * direction)
    if angleR > math.pi then
      angleR = angleR - (math.pi * 2)
    end
    if angleR > angle/2 or angleR < -angle/2 then
      return false
    else 
      return true    
    end
  end
end

local dangerous_grounds = {
  hole = true,
  lava = true
}

function eg.is_ground_dangerous(entity, x, y, l)
  local map
  if sol.main.get_type(entity) == "map" then
    map = entity
  else
    map = entity:get_map()
  end
  if not map then return end
  
  local ground = map:get_ground(x, y, l)
  return dangerous_grounds[ground]
  
end

function eg.get_corner_position(entity)
  local x, y = entity:get_position()
  ox, oy = entity:get_origin()  
  return x - ox, y - oy
end