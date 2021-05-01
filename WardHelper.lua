
require("common.log")
module("WardHelper", package.seeall, log.setup)
clean.module("WardHelper", package.seeall, log.setup)

local CoreEx = _G.CoreEx
local Libs   = _G.Libs

local Menu = Libs.NewMenu
local Vector        = CoreEx.Geometry.Vector
local Game          = CoreEx.Game
local Path          = CoreEx.Geometry.Path 
local Enums         = CoreEx.Enums
local Renderer      = CoreEx.Renderer
local ObjectManager = CoreEx.ObjectManager
local EventManager  = CoreEx.EventManager

local Events = Enums.Events
local Player = ObjectManager.Player
local LocalPlayer = ObjectManager.Player.AsHero

local WardHelper     = {}
local Callbacks = {}

local mapID = Game:GetMapID()

local safeWardSpots = {
	{ -- BLUE TOP SIDE BRUSH
		clickPosition = {x=2380.09, y=-71.24, z=11004.69},
		wardPosition  = {x=2826.47, y=-71.02, z=11221.34},
		movePosition  = {x=1774, y=52.84, z=10856}
	},
	{ -- MID TO WOLVES BLUE SIDE
		clickPosition = {x=5174.83, y=50.57, z=7119.81},
		wardPosition  = {x=4909.10, y=50.65, z=7110.90},
		movePosition  = {x=5749.25, y=51.65, z=7282.75}
	},
	{ -- TOWER TO WOLVES BLUE SIDE
		clickPosition = {x=5239.21, y=50.67, z=6944.90},
		wardPosition  = {x=4919.83, y=50.64, z=7023.80},
		movePosition  = {x=5574, y=51.74, z=6458}
	},
	{ -- RED BLUE SIDE
		clickPosition = {x=8463.64, y=50.60, z=4658.71},
		wardPosition  = {x=8512.29, y=51.30, z=4745.90},
		movePosition  = {x=8022, y=53.72, z=4258}
	},
	{    -- DRAGON -> BOT BUSH
		clickPosition = {x=10301.03, y=49.03, z=3333.20},
		wardPosition  = {x=10322.94, y=49.03, z=3244.38},
		movePosition  = {x=10072, y=-71.24, z=3908}
	},
	{    -- BARON -> TOP BUSH
		clickPosition = {x=4633.83, y=50.51, z=11354.40},
		wardPosition  = {x=4524.69, y=53.25, z=11515.21},
		movePosition  = {x=4824, y=-71.24, z=10906}
	},
	{    -- RED -> RED SIDE
		clickPosition = {x=6360.12, y=52.61, z=10362.71},
		wardPosition  = {x=6269.35, y=53.72, z=10306.69},
		movePosition  = {x=6824, y=56, z=10656}
	},
	{    -- TOWER TO WOLVES -> RED SIDE
		clickPosition = {x=9586.57, y=59.62, z=8020.29},
		wardPosition  = {x=9871.77, y=51.47, z=8014.44},
		movePosition  = {x=9122, y=53.74, z=8356}
	},
	{    -- MID TO WOLVES -> RED SIDE
		clickPosition = {x=9647.62, y=51.31, z=7889.96},
		wardPosition  = {x=9874.42, y=51.50, z=7969.29},
		movePosition  = {x=9122, y=52.60, z=7606}
	},
	{    -- RED BOT SIDE BUSH
		clickPosition = {x=12427.00, y=-35.46, z=3984.26},
		wardPosition  = {x=11975.34, y=66.37, z=3927.68},
		movePosition  = {x=13022, y=51.37, z=3808}
	}
}

function WardHelper.IsGameAvailable()
  return not (
    Game.IsChatOpen()  or
    Game.IsMinimized() or
    LocalPlayer.IsDead or
    LocalPlayer.IsRecalling
  )
end

function Callbacks.LoadMenu()
  Menu.RegisterMenu("WardHelper", "WardHelper", function ()
    Menu.ColumnLayout("Drawings", "Drawings", 1, true, function ()
      Menu.Checkbox("Enabled", "Enabled", true)
    end)
  end)
end
function Callbacks.OnDraw()
  if not WardHelper.IsGameAvailable() then return false end
  local WardAwareness =  Menu.Get("Enabled")
      if mapID == 11 then
    if WardAwareness then
        for i,wardSpot in pairs(safeWardSpots) do
            local mpVec = Vector(wardSpot.movePosition);
            local spotDist = mpVec:Distance(Player.Position)
            local alpha = spotDist < 1 and 255 or (255 - 255 * (spotDist-1) / 400)
            local output = string.format("%x", alpha * 255) -- "7F" 
            if (spotDist < 400) and (spotDist > 70) then
                Renderer.DrawCircle3D(mpVec, 20, 30, 1.0, 0xFFFF00 + alpha);
                elseif (spotDist < 70) then
                Renderer.DrawCircle3D(Vector(wardSpot.wardPosition), 20, 30, 1, 0xFFFF00)            
                local clVec = Vector(wardSpot.clickPosition);
                local clickDist = Vector.Distance(clVec, Renderer.GetMousePos());
                if clickDist > 30 then
                    Renderer.DrawCircle3D(clVec,20, 30, 1, 0xffffff)
                    else
                        local wpVec = Vector(wardSpot.wardPosition)
                        Renderer.DrawCircle3D(clVec,20, 30, 1.0, 0x32CD32FF); 
                        Renderer.DrawCircle3D(wpVec,20, 30, 1.0, 0xFF000011);
                    local magneticWardSpotVector = Vector(wardSpot.movePosition)
                    local wardPositionVector = Vector(wardSpot.wardPosition)
                    Renderer.DrawLine3D(magneticWardSpotVector, wardPositionVector, 2, 0x32CD32FF)
                    end
                end
            end
        end
    end
end


function OnLoad()
  Callbacks.LoadMenu()
  for EventName, EventId in pairs(Events) do
    if Events[EventName] then
        EventManager.RegisterCallback(EventId, Callbacks[EventName])
    end
  end
  INFO("> WardHelper Enabled !")
  return true
end
