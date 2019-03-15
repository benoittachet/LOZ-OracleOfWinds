gen = {}

gen.dirCoef = {
  {x = 1, y = 0},
  {x = 0, y = -1},
  {x = -1, y = 0},
  {x = 0, y = 1}
}

function gen.shift_direction4(x, y, dir, dist)
  return x + dist * gen.dirCoef[dir + 1].x, y + dist * gen.dirCoef[dir + 1].y
end

function gen.import(dest, src, ...)
  if not (dest and src) then return end
  for _, p in ipairs({...}) do
    if src[p] then
      dest[p] = src[p]
    end
  end

end

return gen