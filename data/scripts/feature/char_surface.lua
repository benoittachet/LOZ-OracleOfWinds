local char_surface = gen.class(sol.main.get_metatable("text_surface"), true)

function char_surface:create(...)
  local surf = sol.surface.create(...)
end

function char_surface:add_char()
  print("oui")
end

local test = char_surface:new()

test:add_char()