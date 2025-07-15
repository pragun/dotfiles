-- windowMode.lua
local M = {}

local function ensureNotFullscreen(win, moveFn)
    if win:isFullScreen() then
        hs.alert.show("Exiting Fullscreen…")
        win:setFullScreen(false)
        hs.timer.doAfter(0.4, function()
            hs.alert.show("Moving window…")
            moveFn()
        end)
        return true
    end
    return false
end

function M.setup(modalMgr)
    modalMgr:new("resize")
    local resizeModal = modalMgr.modal_list["resize"]

    -- Move Left
    resizeModal:bind('', 'h', "Move Left", function()
        local win = hs.window.frontmostWindow()
        if not ensureNotFullscreen(win, function()
                win:moveToUnit(hs.layout.left50)
            end) then
            win:moveToUnit(hs.layout.left50)
        end
    end)

    -- Move Right
    resizeModal:bind('', 'l', "Move Right", function()
        local win = hs.window.frontmostWindow()
        if not ensureNotFullscreen(win, function()
                win:moveToUnit(hs.layout.right50)
            end) then
            win:moveToUnit(hs.layout.right50)
        end
    end)

    -- Center
    resizeModal:bind('', 'c', "Center", function()
        local win = hs.window.frontmostWindow()
        if not ensureNotFullscreen(win, function()
                local screen = win:screen():frame()
                local frame = win:frame()
                frame.x = screen.x + (screen.w - frame.w) / 2
                frame.y = screen.y + (screen.h - frame.h) / 2
                win:setFrame(frame)
            end) then
            local screen = win:screen():frame()
            local frame = win:frame()
            frame.x = screen.x + (screen.w - frame.w) / 2
            frame.y = screen.y + (screen.h - frame.h) / 2
            win:setFrame(frame)
        end
    end)

    -- Maximize
    resizeModal:bind('', 'M', "Maximize", function()
        local win = hs.window.frontmostWindow()
        if not ensureNotFullscreen(win, function()
                win:maximize()
            end) then
            win:maximize()
        end
    end)

    -- Medium Size
    resizeModal:bind('', 'N', "Medium Size", function()
        local win = hs.window.frontmostWindow()
        local screen = win:screen():frame()
        local w, h = screen.w * 0.8, screen.h * 0.8
        local frame = {
            x = screen.x + (screen.w - w) / 2,
            y = screen.y + (screen.h - h) / 2,
            w = w,
            h = h
        }
        if not ensureNotFullscreen(win, function() win:setFrame(frame) end) then
            win:setFrame(frame)
        end
    end)

    -- Switch to next window in app
    resizeModal:bind('', 'O', "Next Window (Same App)", function()
        local win = hs.window.frontmostWindow()
        if not win then return end

        local app = win:application()
        if not app then return end

        local appWindows = app:allWindows()
        table.sort(appWindows, function(a, b) return a:id() < b:id() end)

        for i, w in ipairs(appWindows) do
            if w:id() == win:id() then
                local nextIndex = (i % #appWindows) + 1
                appWindows[nextIndex]:focus()
                break
            end
        end
    end)

    -- Switch to previous window in app
    resizeModal:bind('', 'P', "Prev Window (Same App)", function()
        local win = hs.window.frontmostWindow()
        if not win then return end

        local app = win:application()
        if not app then return end

        local appWindows = app:allWindows()
        table.sort(appWindows, function(a, b) return a:id() < b:id() end)

        for i, w in ipairs(appWindows) do
            if w:id() == win:id() then
                local prevIndex = (i - 2 + #appWindows) % #appWindows + 1
                appWindows[prevIndex]:focus()
                break
            end
        end
    end)

    -- Exit modal
    resizeModal:bind({}, 'escape', "Exit", function()
        modalMgr:deactivateAll()
    end)

    -- Activate modal
    modalMgr.supervisor:bind('cmd', 'E', "Resize", function()
        modalMgr:activate({ "resize" }, '#74BB67', true)
    end)

    -- Show Mission Control
    resizeModal:bind('', 'A', "Mission Control", function()
        hs.spaces.toggleMissionControl()
    end)

    resizeModal:bind('', 'S', "Spaces", function()
        hs.spaces.toggleSpaces()
    end)

    resizeModal:bind('', 'D', "Desktop", function()
        hs.spaces.toggleShowDesktop()
    end)
end

return M
