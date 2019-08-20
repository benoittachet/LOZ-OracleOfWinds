local item = ...

function item:on_created()

  self:set_savegame_variable("possession_sword")
  self:set_sound_when_picked(nil)
end

function item:on_variant_changed(variant)
  -- The possession state of the sword determines the built-in ability "sword".
  self:get_game():set_ability("sword", variant)
end

function item:on_obtained(variant, variable)
  if variable == "obtained_sword_1" then
    local sensor = self:get_game():get_map():get_entity("message_1")
    sensor:set_enabled(true)
  end
end
