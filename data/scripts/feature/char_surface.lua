local char_surface = {}  --the object contaning everything related to char surfaces (like sol.surface)
local meta = {}          --the metatable of char surface objects

--===== CHAR SURFACES METATABLE (METHODS and METAMETHODS) ======
function meta:set_font(font)
  assert(type(font) == "string", "Bad argumennt #1 to set_font : font must be a font name (string)")
  self.font = font
end

function meta:set_height(h)
  self.h = h
end

function meta:add_char(char, font)
  assert(type(char) == "string", "Bad argument #1 to add_char: char must be a string")
  
  local code = code:byte()
  assert(code < 128, "char_surfaces only support ASCII atm.")

  font = font or self.font
  assert(type(font) == "string", "Bad argument #2 to add char : font must be a font name (string)")
  
  local font_surf = sol.surface.create("fonts"..font)
  assert(font_surf, "Can't find the specified font")

  local font_w, font_h = font_surf:get_size()
  local char_w, char_h = font_w / 128, font_h / 16

  local origin_x = char_w * code
  local dst_x = self.x

  surface:set_size(dst_x + char_w, self.h)
  font_surf:draw_region(origin_x, 0, char_w, char_h, self.surface, dst_x, 0)
  self.x = dst_x + char_w

end

function meta.__index(t, k) --The only actual metamethod here
--When we try to index a char surface object, lua will search for properties in the meta object itself and then in the surface object
  return meta[k] or t.surface[k]
end

--==========

--Binding making the metatable acessible as a property of char_surface
char_surface.mt = meta

--The creation function
function char_surface.create(font, h)
  local surf = {}
  surf.surface = sol.surface.create() --Initializes the actual surface as a property of the char surface objects
  surf.font = font
  surf.x = 0
  surf.h = 8
  setmetatable(surf, meta)  --Sets meta (aka char_surface.mt) as the metatable for the new object

  return surf
end