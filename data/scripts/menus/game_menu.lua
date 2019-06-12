local game_menu = {
    surface = nil,      --main surface (will be be draw directly into the screen)
    transition_surface, --will be used to keep the last frame of the closing menu page during the transition 
    pages = {           --submenus
        "inventory",
        "quest_menu"
    },
    cursor_sprite = "menus/cursor.png",     --image used as the default cursor
    cursor_surface = nil,                   --surface for the cursor
    current_page_index = 1,
    current_page = nil,
    info_surface = nil,
    info_pre_surface = nil,
    info_surface_pos = {
        x = 0,
        y = 0,
    },
    info_surface_movement = nil,
    transition_movement = nil,
    transition_movement_pos = {x = 0, y = 0}
}

game_menu.surface = sol.surface.create(sol.video.get_quest_size())
game_menu.transition_surface = sol.surface.create(sol.video.get_quest_size())
game_menu.cursor_surface = sol.surface.create(game_menu.cursor_sprite)

local info_name_text_surface = sol.text_surface.create({
    horizontal_alignment = "center",
    vertical_alignment = "middle",
    font = "oracle_black"
})
local info_desc_text_surface = sol.text_surface.create({
    horizontal_alignment = "left",
    vertical_alignment = "middle",
    font = "oracle_black"
})
game_menu.info_surface = sol.surface.create(144, 19)

for k, v in ipairs(game_menu.pages) do
    game_menu.pages[k] = require("scripts/menus/game_menu_pages/"..v)
    game_menu.pages[k].game_menu = game_menu
end

--MENU METHODS AND UTILITY FUNCTIONS
function game_menu:init_info_surface(name, desc)
    self.info_pre_surface = nil

    sol.timer.stop_all(self)
    if not (name and desc) then return false end
    info_name_text_surface:set_text_key(name)
    info_desc_text_surface:set_text_key(desc)

    local desc_size, _ = info_desc_text_surface:get_size()
    self.info_pre_surface = sol.surface.create(152 + desc_size, 19)

    local surf = self.info_pre_surface
    info_name_text_surface:draw(surf, 72, 9)
    info_desc_text_surface:draw(surf, 152, 9)
    self:start_info_cycle()
end

function game_menu:start_info_cycle()
    if self.info_surface_movement then 
        self.info_surface_movement:stop()
        self.info_surface_movement = nil
    end

    self.info_surface_pos.x = 0
    sol.timer.start(self, 1000, function()
        game_menu:start_info_movement_1()
    end)
end

function game_menu:start_info_movement_1()
    self.info_surface_movement = sol.movement.create("straight")
    local m = self.info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    local surf_w, _ = self.info_pre_surface:get_size()
    m:set_max_distance(surf_w)
    function m:on_finished()
        game_menu:start_info_movement_2()
    end     
    m:start(self.info_surface_pos)
end

function game_menu:start_info_movement_2()
    self.info_surface_pos.x = 144
    self.info_surface_movement = sol.movement.create("straight")
    local m = self.info_surface_movement
    m:set_angle(math.pi)
    m:set_speed(32)
    function m:on_finished()
        game_menu:start_info_cycle()
    end
    m:set_max_distance(144)
    m:start(self.info_surface_pos)
end

function game_menu:get_game()
    return self.game
end

function game_menu:page_transition(new_page)
    self.current_page:draw(self.transition_surface)
    if self.current_page.on_closes then
        self.current_page:on_closed()
    end
    self.current_page = new_page

    self.transition_movement = sol.movement.create("straight")
    local m = self.transition_movement
    m:set_speed(128)
    m:set_angle(math.pi)
    function m:on_finished()
        game_menu:end_transition()
    end
    m:set_max_distance(144)
    self.transition_movement_pos = {x = 144, y = 16}
    m:start(self.transition_movement_pos)
end

function game_menu:end_transition()
    self.transition_movement = nil
    self.current_page:on_page_selected()
end

--====== MENU CALLBACKS ======
function game_menu:on_started()
    self.current_page = self.pages[self.current_page_index]

    for i, v in ipairs(self.pages) do
        if v.init then v:init(self) end
    end
    self.current_page:on_page_selected(self)
end

function game_menu:draw(dst_surface, x, y)
    local surf = self.surface
    surf:clear()
    self.current_page:draw(surf, self)

    local info_x, info_y = self.info_surface_pos.x, self.info_surface_pos.y
    if self.current_page.enable_info_text and self.info_pre_surface then
        self.info_surface:clear()
        self.info_pre_surface:draw(self.info_surface, info_x, info_y)
        self.info_surface:draw(surf, 8, 104)
    end

    surf:draw(dst_surface, x, y)
end

function game_menu:on_draw(dst_surface)  
    if self.transition_movement then
        local x, y = self.transition_movement_pos.x, self.transition_movement_pos.y
        self.transition_surface:draw(dst_surface, x - 144, y)
        
        self:draw(dst_surface, x, 16)
    else
        self:draw(dst_surface, 0, 16)
    end
end

function game_menu:on_finished()
    if self.current_page.on_closed then
        self.current_page:on_closed()
    end
    if self.transition_movement then
        self.transition_movement:stop()
    end
    if self.info_surface_movement then
        self.info_surface_movement:stop()
    end
end

function game_menu:on_command_pressed(command)
    if self.transition_movement then
        return true 
    end

    if command == "select" then
        self.current_page_index = self.current_page_index + 1
        if self.current_page_index > table.getn(self.pages) then
            self.current_page_index = 1
        end
        self:page_transition(self.pages[self.current_page_index])
    end

    if self.current_page.on_command_pressed then
        self.current_page:on_command_pressed(command)
    end
end

--====== BINDING THE MENU TO THE GAME ======

local function get_game_menu(game)
    return game_menu
end

local function bind_to_game(game)
    game.get_game_menu = get_game_menu
    game_menu.game = game
end

local function enter_menu(game)
    sol.menu.start(game, game_menu)
end

local function pause_callback(game)
    enter_menu(game)
end

local function unpause_callback()
    sol.menu.stop(game_menu)
end    

--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", bind_to_game)
game_meta:register_event("on_paused", pause_callback)
game_meta:register_event("on_unpaused", unpause_callback)