local modalMgr = hs.loadSpoon("ModalMgr")

-- Add modules folder to package path if needed
-- package.path = package.path .. ";" .. hs.configdir .. "/?.lua"

local windowMode = require("windowMode")
windowMode.setup(spoon.ModalMgr)

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
