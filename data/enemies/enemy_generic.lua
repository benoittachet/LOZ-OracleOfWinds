function cone_detect(enemy,hero,angleR,distance)
  if hero:get_distance(enemy) < distance then
    local angle = hero:get_angle(enemy)
    if angle < angleR/2 and angle > 

     