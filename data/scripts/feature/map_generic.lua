mpg = {}

function mpg.open_door(map, name)
  if type(name) == "number" then name = tostring(name) end
  if not map then return end
  map:open_doors("door_"..name)
end

local function trigger_event(map, event)
  if not type(event) == "string" then return end

  if event:starts("door_") then
    local doorID = event:sub(6)
    mpg.open_door(map, doorID)
  end
end

local function death_trigger_callback(enemy)
  print("triggered death event for enemy ", enemy:get_name())
  local map = enemy:get_map()
  local event = enemy:get_property("death_trigger")
  local last_to_die = true

  if not event then return end

  for e in map:get_entities_by_type("enemy") do
    local o_event = e:get_property("death_trigger")
    if o_event and o_event == event and not (e == enemy) then
      last_to_die = false
    end
  end
  if last_to_die then
    trigger_event(map, event)
  end

end

function mpg.init_enemies_event_triggers(map)
  local val
  if not map then return end
  
  for e in map:get_entities_by_type("enemy") do
    if e:get_property("death_trigger") then
      e:register_event("on_dead", death_trigger_callback)
    end
  end
end

return mpg