function string.starts(s, tofind)
  if not type(s) == "string" then return end
  
  return s:find(tofind) == 1
end

function string.field(s, sep, index)
  local start_index  = 0
  for i = 1, index - 1 do
    start_index = s:find(sep, start_index + 1) + 1
  end
  local end_index = s:find(sep, start_index) - 1
  return s:sub(start_index, end_index)
end