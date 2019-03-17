--global object containing all public functions created here.
gen = {}

--coeficients linked to all 4 dirs = coordinates of an unitary vector pointing in that direction.
gen.dirCoef = {
  {x = 1, y = 0},
  {x = 0, y = -1},
  {x = -1, y = 0},
  {x = 0, y = 1}
}

--Transpose a point following a specified direction, with a specified direction.
function gen.shift_direction4(x, y, dir, dist)
  return x + dist * gen.dirCoef[dir + 1].x, y + dist * gen.dirCoef[dir + 1].y
end

--Adds properties of the src object to the dest object. Useful to import functions from feature objects (gen, eg, mg, mpg) to game objects.
function gen.import(dest, src, ...)
  if not (dest and src) then return end
  
  local args = {...}
  if not next(args) then
    args = src
  end

  for _, p in ipairs(args) do
    if src[p] then
      dest[p] = src[p]
    end
  end

end

return gen