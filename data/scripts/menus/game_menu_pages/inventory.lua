--initializing the submenu object
local inventory_menu = {
    bg_sprite = "menus/inventory.png",
    bg_surface = nil,
    items = {
        "rock_feather",
        "rock_feather"
    },
    items_sprites = {},
    item_info_surface = nil,
    item_info_pre_surface = nil,
    item_info_surface_pos = {
        x = 0,
        y = 0,
    },
    item_info_surface_movement = nil,
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

local item_name_text_surface = sol.text_surface.create({
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "oracle_black"
})
local item_desc_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "oracle_black"
})
inventory_menu.item_info_surface = sol.surface.create(144, 19)

inventory_menu.bg_surface = sol.surface.create("menus/inventory.png")

--local functions and generic methods
function inventory_menu:get_selected_item()
    return self.items[self.cursor]
end

local function slot_coords_to_index(cx, cy)
    return (cx + cy * 4) + 1
end

local function slot_index_to_coords(i)
    return (i - 1) % 4, math.floor((i - 1) / 4)
end

function inventory_menu:init_item_info_surface()
    self.item_info_pre_surface = nil

    local item = self:get_selected_item()
    if not (item and item:get_variant() ~= 0) then return false end
    item_name_text_surface:set_text_key("items."..item:get_name()..".name")
    item_desc_text_surface:set_text_key("items."..item:get_name()..".description")

    local desc_size, _ = item_desc_text_surface:get_size()
    self.item_info_pre_surface = sol.surface.create(152 + desc_size, 19)

    local surf = self.item_info_pre_surface
    item_name_text_surface:draw(surf, 72, 9)
    item_desc_text_surface:draw(surf, 152, 9)
    self:start_item_info_cycle()
end

function inventory_menu:start_item_info_cycle()
    if self.item_info_surface_movement then 
        self.item_info_surface_movement:stop()
        self.item_info_surface_movement = nil
    end

    self.item_info_surface_pos.x = 0
    sol.timer.start(self.game_menu, 1000, function()
        inventory_menu:start_item_info_movement_1()
    end)
end

function inventory_menu:start_item_info_movement_1()
    self.item_info_surface_movement = sol.movement.create("straight")
    local m = self.item_info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    local surf_w, _ = self.item_info_pre_surface:get_size()
    m:set_max_distance(surf_w)
    function m:on_finished()
        inventory_menu:start_item_info_movement_2()
    end     
    m:start(self.item_info_surface_pos)
end

function inventory_menu:start_item_info_movement_2()
    self.item_info_surface_pos.x = 144
    self.item_info_surface_movement = sol.movement.create("straight")
    local m = self.item_info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    m:set_max_distance(144)
    function m:on_finished()
        inventory_menu:start_item_info_cycle()
    end
    m:start(self.item_info_surface_pos)
end

function inventory_menu:on_selection_changed()
    self:init_item_info_surface()
end

--SUBMENU METHODS : will be called by the game_menu methods
function inventory_menu:init(game_menu)
    self.game_menu = game_menu
    for i, item in ipairs(self.items) do 
        if item:get_variant() ~= 0 and not (self.items_sprites[item] and 
          self.items_sprites[item]:get_direction() == item:get_variant() - 1) then 
            self.items_sprites[item] = sol.sprite.create("entities/items")
            self.items_sprites[item]:set_animation(item:get_name())
            self.items_sprites[item]:set_direction(item:get_variant() - 1)
        end 
    end    
end

function inventory_menu:on_page_selected()  --appelée quand cette page est sélectionnée
    self.cursor = 1
    self:init_item_info_surface()
end

function inventory_menu:draw(dst_surface, game_menu)
    self.bg_surface:draw(dst_surface)
    local cx, cy = slot_index_to_coords(self.cursor)
    local x, y = cursor_pos.tl_offset.x + (cx * cursor_pos.h_offset), cursor_pos.tl_offset.y + (cy * cursor_pos.v_offset)
    game_menu.cursor_surface:draw(dst_surface, x, y)

    for i, item in ipairs(self.items) do
        if item:get_variant() ~= 0 then
            cx, cy = slot_index_to_coords(i)
            x, y = items_pos.tl_offset.x + (cx * items_pos.h_offset), items_pos.tl_offset.y + (cy * items_pos.v_offset)
            self.items_sprites[item]:draw(dst_surface, x, y)
        end
    end
    local info_x, info_y = self.item_info_surface_pos.x, self.item_info_surface_pos.y
    if self.item_info_pre_surface then
        self.item_info_surface:clear()
        self.item_info_pre_surface:draw(self.item_info_surface, info_x, info_y)
        self.item_info_surface:draw(dst_surface, 8, 104)
    end
end

function inventory_menu:on_command_pressed(command)
    local cx, cy
    if command == "item_1" then
        local item = self:get_selected_item()
        if item and item:get_variant() ~= 0 then
            item:get_game():set_item_assigned(1, item)
        end
    elseif command == "right" then
        cx, cy = slot_index_to_coords(self.cursor)
        cx = cx + 1
        if cx > 3 then cx = 0 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "up" then
        cx, cy = slot_index_to_coords(self.cursor)
        cy = cy - 1
        if cy < 0 then cy = 3 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "left" then
        cx, cy = slot_index_to_coords(self.cursor)
        cx = cx - 1
        if cx < 0 then cy = 3 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
    elseif command == "down" then
        cx, cy = slot_index_to_coords(self.cursor)
        cy = cy + 1
        if cy > 3 then cy = 0 end
        self.cursor = slot_coords_to_index(cx, cy)
        self:on_selection_changed()
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