function string.starts(s, tofind)
  if not type(s) == "string" then return end
  
  return s:find(tofind) == 1
end