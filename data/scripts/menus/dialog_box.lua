local game

--====== INIT DIALOG_BOX =======
local dialog_box = {

  -- Dialog box properties.
  dialog = nil,                -- Dialog being displayed or nil.
  first = true,                -- Whether this is the first dialog of a sequence.
  style = nil,                 -- "box" or "empty".
  vertical_position = "auto",  -- "auto", "top" or "bottom".
  skip_mode = nil,             -- "none", "current", "all" or "unchanged".
  icon_index = nil,            -- Index of the 16x16 icon in hud/dialog_icons.png or nil.
  info = nil,                  -- Parameter passed to start_dialog().
  skipped = false,             -- Whether the player skipped the dialog.
  selected_answer = nil,       -- Selected answer (1 or 2) or nil if there is no question.
  next = nil,

  -- Displaying text gradually.
  current_line = nil,             -- Next line to display or nil.
  next_line = nil,
  line_it = nil,               -- Iterator over of all lines of the dialog.
  line_surfaces = {},          -- Array of the 3 text surfaces.
  line_index = nil,            -- Line currently being shown.
  char_index = nil,            -- Next character to show in the current line.
  char_delay = nil,            -- Delay between two characters in milliseconds.
  full = false,                -- Whether the 3 visible lines have shown all content.
  need_letter_sound = false,   -- Whether a sound should be played with the next character.
  gradual = true,              -- Whether text is displayed gradually.

  -- Graphics.
  surface = nil,
  box_surface = nil,
  icons_img = nil,
  end_arrow = nil,
  arrow_timer = nil,
  draw_arrow = false,
  box_position = {x = 0, y = 0},      -- Destination coordinates of the dialog box.
  question_dst_position = nil, -- Destination coordinates of the question icon.
  icon_dst_position = nil,     -- Destination coordinates of the icon.
  font = "oracle",
  font_size = 15,
  text_color = { 115, 59, 22 } -- Text color.

}


-- Constants.
local nb_visible_lines = 2     -- Maximum number of lines in the dialog box.
local char_delays = {          -- Delay before displaying the next character.
  slow = 60,
  medium = 40,
  fast = 20  -- Default.
}
local letter_sound_delay = 100
local box_size = {w = 144, h = 40}
local arrow_pos = {x = 136, y = 33}

-- Initialize dialog box data.
--dialog_box.font, dialog_box.font_size = language_manager:get_dialog_font()
for i = 1, nb_visible_lines do
  dialog_box.line_surfaces[i] = sol.text_surface.create{
    horizontal_alignment = "left",
    vertical_alignment = "top",
    font = dialog_box.font,
    font_size = dialog_box.font_size,
    color = dialog_box.text_color
  }
end

dialog_box.surface = sol.surface.create(sol.video.get_quest_size())
dialog_box.end_arrow = sol.surface.create("menus/dialog.png")

--dialog_box.box_img = sol.surface.create("hud/dialog_box.png")
--dialog_box.icons_img = sol.surface.create("hud/dialog_icons.png")
--dialog_box.end_lines_sprite = sol.sprite.create("hud/dialog_box_message_end")

--====== DIALOG MENU CALLBACKS ======

function dialog_box:on_started()
  --debug
  print(dialog_box.dialog.text)

  
  self.char_delay = char_delays["fast"] -- à remplacer par une vraie sélection de la vitesse (settings ?)
  self.box_position:set(8, 96) --à remplacer par un vrai calcul de la position de la box en fonction de celle du joeur
  sol.timer.start(game, 2000, function() dialog_box:advance_dialog() end)
  self:start_arrow_blinking()
end

function dialog_box:on_finished()
  game:set_custom_command_effect("action", nil)
  game:stop_dialog()
end

function dialog_box:on_draw(dst_surface)
  local x, y = self.box_position:get()
  self.surface:fill_color({0, 0, 0}, x, y, box_size.w, box_size.h)
  
  if self:is_full() and self.draw_arrow then
    self.end_arrow:draw(self.surface, x + arrow_pos.x, y + arrow_pos.y)
  end

  self.surface:draw(dst_surface)
end

function dialog_box:on_command_pressed(command)
  if command == "action" and dialog_box:is_full() then
    dialog_box:advance_dialog()
  end
end

--====== DIALOG MENU FUNCTIONS ======

function dialog_box:quit()
  if sol.menu.is_started(self) then
    sol.menu.stop(self)
  end
end

function dialog_box.box_position:get()
  return self.x, self.y
end

function dialog_box.box_position:set(x, y)
  self.x = x
  self.y = y
end

function dialog_box:is_line_full()
  return self.char_index > #self.current_line
end

function dialog_box:is_full()
  return false
end

function dialog_box:start_arrow_blinking()
  self.draw_arrow = true
  self.arrow_timer = sol.timer.start(self, 500, function()
    dialog_box.draw_arrow = not dialog_box.draw_arrow
    return true
  end)
end

function dialog_box:stop_arrow_blinking()
  self.draw_arrow = false
  self.arrow_timer:stop()
end

function dialog_box:show_dialog()
-- Initialize this dialog.
  local dialog = self.dialog

  local text = dialog.text
  if dialog_box.info ~= nil then
    -- There is a "$v" sequence to substitute.
    text = text:gsub("%$v", dialog_box.info)
  end
  -- Split the text in lines.
  text = text:gsub("\r\n", "\n"):gsub("\r", "\n")
  self.line_it = text:gmatch("([^\n]*)\n")  -- Each line including empty ones.
  self.next_line = self.line_it()
  self.line_index = 1
  
  for i = 1, nb_visible_lines do
    self.line_surfaces[i]:set_text("")
  end

  self:start_next_line()

end

function dialog_box:start_next_line()
  if not self:has_more_lines() then
    self:show_next_dialog()
    return
  end

  self.current_line = self.next_line
  self.next_line = line_it()  

end

function dialog_box:start_line()
  self.char_index = 1
  self:show_next_char()
  sol.timer.start(self, self.char_delay, self.show_next_char)
end

function dialog_box:show_next_char()
  
end

function dialog_box:has_more_lines()
  return self.next_line ~= nil
end

function dialog_box:advance_dialog()
  if not self.next_dialog and sol.menu.is_started(self) then
    self:quit()
  end
end

--====== BINDING THE DIALOG TO THE GAME ======

local function dialog_start_callback(game, dialog, info)
  dialog_box.dialog = dialog
  dialog_box.info = info
  sol.menu.start(game, dialog_box)
end

local function get_dialog_box(game)
  return dialog_box
end

local function bind_to_game(game_)
  game = game_
  game:register_event("on_dialog_started", dialog_start_callback)
  game.get_dialog_box = get_dialog_box
end


--When the game starts, binds everything to it.
local game_meta = sol.main.get_metatable("game")
game_meta:register_event("on_started", bind_to_game)