function cone_detect(detector,detected,distance,direction,angle)
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