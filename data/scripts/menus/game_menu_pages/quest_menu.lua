quest_menu = {
    enable_info_text = true,
    bg_image = nil,
    save_cursor_surface = nil
}

quest_menu.bg_image = sol.surface.create("menus/quest_menu")
quest_menu.save_cursor_surface = sol.surface.create("menus/cursor_36_14")

--UTILITY METHODS AND FUNCTIONS

function quest_menu:get_cursor(slot)
    if slot == 1 then
        
    end
end

--SUBMENU METHODS : will be called by the game_menu methods--