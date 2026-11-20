-- Dummy Lua file so Luacheck has something to analyse.
local function greet(name)
  return "Hello, " .. name
end

return { greet = greet }
