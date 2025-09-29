hs.loadSpoon('EmmyLua')
local modalMgr = hs.loadSpoon("ModalMgr")

-- Add modules folder to package path if needed
-- package.path = package.path .. ";" .. hs.configdir .. "/?.lua"

local windowMode = require("windowMode")

local leftHandWindowKeybindings = {
    move_left = { modifiers = {}, key = 'a', description = "Move Left" },
    change_screen = { modifiers = {}, key = 'f', description = "Change Screen" },
    center_window = { modifiers = {}, key = 'c', description = "Center Window" },
    maximize_window = { modifiers = {}, key = 'b', description = "Maximize" },              -- Changed from 'M' to 'f'
    fullscreen_window = { modifiers = { 'shift' }, key = 'b', description = "Fullscreen" }, -- Changed from 'M' to 'f'
    medium_size_window = { modifiers = {}, key = 'v', description = "Medium Size" },        -- Changed from 'N' to 'm'
    move_up = { modifiers = {}, key = 's', description = "Move Up" },      -- Changed from 'O' to 'n'
    prev_window_same_app = { modifiers = {}, key = 'd', description = "Previous Window" },  -- Changed from 'P' to 'p'
    show_mission_control = { modifiers = {}, key = 'z', description = "Mission Control" },  -- Changed from 'A' to 'space'
    show_desktop = { modifiers = { 'shift' }, key = 'x', description = "Show Desktop" },    -- Changed from 'D' to 'shift+space'
    reload_config = { modifiers = { 'shift' }, key = 'z', description = "Reload Config" },   -- Changed from 'shift+Z' to 'cmd+r'
    move_grid = { modifiers = {}, key = 'g', description = "Show Grid" }, -- Added grid toggle
    close_window = { modifiers = {}, key = 'w', description = "Close Window" }, -- Added close window
    quit_app = { modifiers = {}, key = 'q', description = "Quit App" }, -- Added quit app
    screenshot = { modifiers = {}, key = 'r', description = "Take Screenshot" } -- Added screenshot
}

windowMode.setup(spoon.ModalMgr, leftHandWindowKeybindings)

spoon.ModalMgr.supervisor:enter()

-- Fusion 360 helper hotkey
hs.hotkey.bind({ "cmd", "ctrl" }, "L", function()
    local win = hs.window.frontmostWindow()
    if not win then
        hs.alert.show("No active window")
        return
    end

    local app = win:application()
    local appName = app and app:name() or "Unknown"
    print("Frontmost app:", appName)
    hs.alert.show("App: " .. appName)

    if appName:lower():find("fusion") then
        app:activate()
        print("Activated Fusion 360")
        hs.timer.doAfter(0.3, function()
            hs.eventtap.keyStroke({}, "S", 0)
            hs.timer.doAfter(1.0, function()
                hs.eventtap.keyStrokes("Line")
                hs.timer.doAfter(1.0, function()
                    hs.eventtap.keyStroke({}, "return", 0)
                end)
            end)
        end)
    else
        hs.alert.show("Not Fusion 360")
    end
end)

wf = hs.window.filter.new()

wf:subscribe(hs.window.filter.windowFullscreened, function(win, appName)
    -- set window size to the full screen size, but not true fullscreen mode
    -- afer a delay of 0.5 seconds to allow the fullscreen transition to complete   
    delay = 0.5
    hs.timer.doAfter(delay, 
        function()
            win:setFullScreen(false)
            local screen = win:screen():frame()
            local frame = { x = screen.x, y = screen.y, w = screen.w, h = screen.h }
            win:setFrame(frame)
            hs.alert.show(appName .. " prevented from going fullscreen")
        end
    )    
end)










