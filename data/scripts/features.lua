-- Sets up all non built-in gameplay features specific to this quest.

-- Usage: require("scripts/features")

-- Features can be enabled to disabled independently by commenting
-- or uncommenting lines below.

sol.features = {}

require("scripts/hud/hud")
require("scripts/multi_events")
require("scripts/feature/generic")
require("scripts/feature/movement_generic")
require("scripts/feature/entity_generic")
require("scripts/meta/hero")
require("scripts/feature/video")

return true
