quest_menu = {
    enable_info_text = true,
    bg_surface = nil,
    cursor_36x14_surface = nil,
    current_cursor = nil
}

quest_menu.bg_surface = sol.surface.create("menus/quest_menu.png")
quest_menu.cursor_36x14_surface = sol.surface.create("menus/cursor_36_14.png")


local slot_cursors = {
    {115, 81 , "cursor_36x14_surface"},
    {110, 81, "cursor_36x14_surface"}
}

local slot_effects = {
    nil,
    "save",
}

--UTILITY METHODS AND FUNCTIONS
function quest_menu:get_cursor_info(slot)
    return slot_cursors[slot]
end

function quest_menu:set_current_cursor(slot)
    self.current_cursor = {}
    local cursos_info = self:get_cursor_info(slot)
    if not cursos_info then return end
    local x, y, cursor = unpack(cursos_info)
    self.current_cursor.x = x
    self.current_cursor.y = y
    self.current_cursor.cursor = self[cursor] or self.game_menu.cursor_surface
end

--slot effects
function quest_menu:save()
    self.game_menu:get_game():save()
end

--SUBMENU METHODS : will be called by the game_menu methods--

function quest_menu:on_page_selected()
    self.cursor = 2
    self:set_current_cursor(self.cursor)
    self.game_menu:init_info_surface("menus.quest.save.name", "menus.quest.save.description")
end

function quest_menu:draw(dst_surface)
    self.bg_surface:draw(dst_surface)
    if self.current_cursor then
        local x, y = self.current_cursor.x, self.current_cursor.y
        self.current_cursor.cursor:draw(dst_surface, x, y)
    end
end

function quest_menu:on_command_pressed(command)
    if command == "action" then
        if slot_effects[self.cursor] then
            self[slot_effects[self.cursor]](self)
        end
    end
end

return quest_menu