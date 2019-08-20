local settings_menu = {
    bg_surface = nil,
    surface = nil,
    origin_page = nil,
    view_cursor = true,
    cursor = 1,
    scrolling = 0,
    button_effects = {},
    button_surface_builders = {}
}

local title_pos = {
    x = 16,
    y = 8
}

local cursor_pos = {
    x = 33,
    y = 57,
    offset = 24,
}

local button_pos = {
    x = 33, 
    y = 61,
    offset = 24
}

settings_menu.buttons = {
    "controls",
    "text_speed",
    "view",
    "jsp",
}

settings_menu.bg_surface = sol.surface.create("menus/settings_menu.png")
settings_menu.cursor_surface = sol.surface.create("menus/save_cursor.png")
settings_menu.surface = sol.surface.create(sol.video.get_quest_size())

--methods
function settings_menu:rebuild_surface()
    self.bg_surface:draw(self.surface)

    local x, y
    for i = 1, 3 do 
        x = button_pos.x
        y = button_pos.y + button_pos.offset * (i - 1)
        self.buttons[i + self.scrolling].surface:draw(self.surface, x, y)
    end

    if self.view_cursor then 
        x = cursor_pos.x
        y = cursor_pos.y + cursor_pos.offset * (self.cursor - self.scrolling - 1)
        self.cursor_surface:draw(self.surface, x, y)
    end
end

function settings_menu:rebuild_button_surface(button)
    button.bg_surface:draw(button.suface)
    button:surface_builder(self)
end

--button effects
function settings_menu.button_effects:controls(command)
    print(command)
end

--button surface builders

--SUBMENU METHODS

function settings_menu:draw(dst_surface)
    self.surface:draw(dst_surface)
end

function settings_menu:on_page_selected()
    settings_menu.cursor = 1
end

function settings_menu:on_command_pressed(command)
    if command == "action" or command == "left" or command == "right" then
        self.buttons[self.cursor].effect(self, command, self.buttons[self.cursor])
    elseif command == "up" then
        local cursor_relative = self.cursor - self.scrolling
        if cursor_relative == 1 then
            if self.scrolling == 0 then
                self.scrolling = self.nButtons - 3
                self.cursor = self.nButtons
            else
                self.scrolling = self.scrolling - 1
                self.cursor = self.cursor - 1
            end
        else
            self.cursor = self.cursor - 1
        end
        self:rebuild_surface()
    elseif command == "down" then
        local cursor_relative = self.cursor - self.scrolling
        if cursor_relative == 3 then
            if self.scrolling == self.nButtons - 3 then
                self.scrolling = 0
                self.cursor = 1
            else
                self.scrolling = self.scrolling + 1
                self.cursor = self.cursor + 1
            end
        else
            self.cursor = self.cursor + 1
        end
        self:rebuild_surface()
    end

end

function settings_menu:init()
    self:rebuild_surface()
end

function settings_menu:on_started(game)
    local title_surface = self.game_menu.lang:load_image("menus/settings_title")
    local x, y = title_pos.x, title_pos.y
    title_surface:draw(self.bg_surface, x, y)

    for i, v in ipairs(settings_menu.buttons) do
        self.buttons[i] = {
            name = v, 
            effect = self.button_effects[v],
            surface = settings_menu.game_menu.lang:load_image("menus/settings_"..v),
            surface_builder = self.button_surface_builders[v]
        }
        if self.buttons[i].surface_builder then 
            self.buttons[i].bg_surface = sol.surface.create(96, 13)
            self.buttons[i].surface:draw(self.buttons[i].bg_surface)
            self.buttons[i]:surface_builder(self)
        end
    end
    self.nButtons = table.getn(self.buttons)
end


return settings_menu