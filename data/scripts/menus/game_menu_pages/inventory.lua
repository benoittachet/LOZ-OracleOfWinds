--initializing the submenu object
local inventory_menu = {
    bg_sprite = "menus/inventory.png",
    bg_surface = nil,
    items = {
        "rock_feather"
    }
}

local horizontal_offset = 32
local vertical_offset = 24
local first_slot_offset = {
    x = 22, 
    y = 9
}

inventory_menu.bg_surface = sol.surface.create(inventory_menu.bg_sprite)

--SUBMENU METHODS : will be called by the game_menu methods
function inventory_menu:init()
    self.cursor = 6
end

function inventory_menu:draw(dst_surface, game_menu)
    self.bg_surface:draw(dst_surface)
    local cx, cy = (self.cursor - 1) % 3, math.floor((self.cursor - 1) / 3)
    local x, y = first_slot_offset.x + (cx * horizontal_offset), first_slot_offset.y + (cy * vertical_offset)
    game_menu.cursor_surface:draw(dst_surface, x, y)
end

--Replacing the items names by the items objects when the game starts
local function load_items(game)
    for k, v in ipairs(inventory_menu.items) do
        inventory_menu.items[k] = game:get_item(v)
    end
end

local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", load_items)

return inventory_menu