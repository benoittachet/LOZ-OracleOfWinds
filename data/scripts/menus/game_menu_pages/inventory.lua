--initializing the submenu object
local inventory_menu = {
    bg_sprite = "menus/inventory.png",
    bg_surface = nil,
    items = {
        "rock_feather"
    },
    items_sprites = {}
}

local horizontal_offset = 32
local vertical_offset = 24
local first_slot_offset = {
    x = 22, 
    y = 9
}

local cursor_pos = {
    h_offset = 32,
    v_offset = 24,
    tl_offset = {
        x = 22, 
        y = 9
    }
}

local items_pos = {
    h_offset = 32,
    v_offset = 24,
    tl_offset = {
        x = 32, 
        y = 21
    }
}

inventory_menu.bg_surface = sol.surface.create(inventory_menu.bg_sprite)

--SUBMENU METHODS : will be called by the game_menu methods
function inventory_menu:init()
    for i, item in ipairs(self.items) do 
        if item:get_variant() and not (self.items_sprites[item] and self.items_sprites[item]:get_direction() == item:get_variant()) then 
            self.items_sprites[item] = sol.sprite.create("entities/items")
            self.items_sprites[item]:set_animation(item:get_name())
            self.items_sprites[item]:set_direction(item:get_variant())
        end 
    end    
end

function inventory_menu:on_page_selected()  --appelée quand cette page est sélectionnée
    self.cursor = 1
end

function inventory_menu:draw(dst_surface, game_menu)
    self.bg_surface:draw(dst_surface)
    local cx, cy = (self.cursor - 1) % 3, math.floor((self.cursor - 1) / 3)
    local x, y = cursor_pos.tl_offset.x + (cx * cursor_pos.h_offset), cursor_pos.tl_offset.y + (cy * cursor_pos.v_offset)
    game_menu.cursor_surface:draw(dst_surface, x, y)

    for i, item in ipairs(self.items) do
        if item:get_variant() ~= 0 then
            cx, cy = (i - 1) % 3, math.floor((i - 1) / 3)
            x, y = items_pos.tl_offset.x + (cx * items_pos.h_offset), items_pos.tl_offset.y + (cy * items_pos.v_offset)
            self.items_sprites[item]:draw(dst_surface, x, y)
        end
    end
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