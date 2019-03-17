local sensor_meta = sol.main.get_metatable("sensor")

function sensor_meta:on_activated()
  self.activated = true
end

function sensor_meta:on_left()
  if not self.persistent then 
    self.activated = false
  end
end

function sensor_meta:is_activated()
  return self.activated
end