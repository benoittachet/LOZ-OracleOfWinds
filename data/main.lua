-- This is the main Lua script of your project.
-- You will probably make a title screen and then start a game.
-- See the Lua API! http://www.solarus-games.org/doc/latest

require("scripts/features")
local game_manager = require("scripts/game_manager")
local solarus_logo = require("scripts/menus/solarus_logo")
local title_screen = require("scripts/menus/zunashy")
--require("scripts/sinking_override")
local input_manager = require("scripts/input_manager")

-- Starts a game.
function sol.main:start_savegame(game)

  -- Skip initial menus if any.
  sol.menu.stop(solarus_logo)

  sol.main.game = game
  game:start()
end

-- This function is called when Solarus starts.
function sol.main:on_started()
  sol.video.set_scale(2)
  -- Setting a language is useful to display text and dialogs.
  sol.language.set_language("en")

  -- Show the Solarus logo initially.
  sol.menu.start(self, solarus_logo)

  -- Start the game when the Solarus logo menu is finished.
  function solarus_logo:on_finished()
      sol.menu.start(sol.main,title_screen)
  end

  function title_screen:on_finished()
     local game = game_manager:create("save1.dat")

     sol.main:start_savegame(game)
  end
end

-- Event called when the program stops.
function sol.main:on_finished()
  sol.main.save_settings()
end

-- Event called when the player pressed a keyboard key.
gen.import(sol.main, input_manager, "on_key_pressed")