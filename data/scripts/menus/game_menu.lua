local game_menu = {
    surface = nil,      --main surface (will be be draw directly into the screen)
    transition_surface, --will be used to keep the last frame of the closing menu page during the transition 
    pages = {           --submenus
        "inventory"
    },
    cursor_sprite = "menus/cursor.png",     --image used as the default cursor
    cursor_surface = nil,                   --surface for the cursor
    current_page_index = 1,
    current_page = nil,
}

game_menu.surface = sol.surface.create(sol.video.get_quest_size())
game_menu.transition_surface = sol.surface.create(sol.video.get_quest_size())
game_menu.cursor_surface = sol.surface.create(game_menu.cursor_sprite)

for k, v in ipairs(game_menu.pages) do
    game_menu.pages[k] = require("scripts/menus/game_menu_pages/"..v)
end

--====== MENU CALLBACKS ======
function game_menu:on_started()
    self.current_page = self.pages[self.current_page_index]

    for i, v in ipairs(self.pages) do
        if v.init then v:init() end
    end
    self.current_page:on_page_selected()
end

function game_menu:on_draw(dst_surface)  
    local surf = self.surface
    surf:clear()
    self.current_page:draw(surf, self)
    surf:draw(dst_surface, 0, 16)
end

--====== BINDING THE MENU TO THE GAME ======

local function get_game_menu(game)
    return game_menu
end

local function bind_to_game(game)
    game.get_game_menu = get_game_menu
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