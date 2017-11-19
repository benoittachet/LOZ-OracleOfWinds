local background_builder = {}

local background_img = sol.surface.create(320,24)
background_img:fill_color{245,245,220}

function background_builder:new(game,config)
  local background = {}
  function background:on_draw(dst_surface)
    background_img:draw(dst_surface,config.x,config.y)
  end
  
  return background
end

return background_builder
