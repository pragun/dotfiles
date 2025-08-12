-- windowMode.lua
local M = {}

local function ensureNotFullscreen(win)
    if win:isFullScreen() then
        hs.alert.show("Exiting Fullscreen…")
        win:setFullScreen(false)
        return true
    end
    return false
end

function switchWindow(count)
    local win = hs.window.frontmostWindow()
    if not win then return end

    local app = win:application()
    if not app then return end

    local appWindows = app:allWindows()
    table.sort(appWindows, function(a, b) return a:id() < b:id() end)

    print(hs.inspect(appWindows))
    for i, w in ipairs(appWindows) do
        if w:id() == win:id() then
            local nextIndex = ((i + count - 1) % #appWindows) + 1
            local targetWindow = appWindows[nextIndex]
            targetWindow:focus()
            break
        end
    end
end

-- Window management actions
local actions = {
    move_left = function()
        local win = hs.window.frontmostWindow()
        ensureNotFullscreen(win)
        local screen = win:screen():frame()
        local frame = win:frame()
        -- Check if window is already at left50
        if math.abs(frame.x - screen.x) < 2 and math.abs(frame.w - screen.w/2) < 2 then
            -- Already at left, move to right
            win:moveToUnit(hs.layout.right50)
        else
            win:moveToUnit(hs.layout.left50)
        end
    end,

    move_right = function()
        local win = hs.window.frontmostWindow()
        ensureNotFullscreen(win)
        local screen = win:screen():frame()
        local frame = win:frame()
        -- Check if window is already at right50
        if math.abs((frame.x + frame.w) - (screen.x + screen.w)) < 2 and math.abs(frame.w - screen.w/2) < 2 then
            -- Already at right, move to left
            win:moveToUnit(hs.layout.left50)
        else
            win:moveToUnit(hs.layout.right50)
        end
    end,

    move_up = function()
        local win = hs.window.frontmostWindow()
        ensureNotFullscreen(win)
        local screen = win:screen():frame()
        local frame = win:frame()
        -- Check if window is already at top50
        if math.abs(frame.y - screen.y) < 2 and math.abs(frame.h - screen.h/2) < 2 then
            -- Already at top, move to bottom
            win:moveToUnit(hs.layout.bottom50)
        else
            win:moveToUnit(hs.layout.top50)
        end
    end,

    move_down = function()
        local win = hs.window.frontmostWindow()
        ensureNotFullscreen(win)
        local screen = win:screen():frame()
        local frame = win:frame()
        -- Check if window is already at bottom50
        if math.abs((frame.y + frame.h) - (screen.y + screen.h)) < 2 and math.abs(frame.h - screen.h/2) < 2 then
            -- Already at bottom, move to top
            win:moveToUnit(hs.layout.top50)
        else
            win:moveToUnit(hs.layout.bottom50)
        end
    end,

    center_window = function()
        local win = hs.window.frontmostWindow()
        local frame = win:frame()
        frame.x = frame.x + (frame.w - frame.w) / 2
        frame.y = frame.y + (frame.h - frame.h) / 2
        ensureNotFullscreen(win)
        local screen = win:screen():frame()
        win:setFrame(frame)
    end,

    maximize_window = function()
        local win = hs.window.frontmostWindow()
        local screen = win:screen():frame()
        local frame = {
            x = screen.x,
            y = screen.y,
            w = screen.w,
            h = screen.h
        }
        ensureNotFullscreen(win)
        win:setFrame(frame)
    end,

    fullscreen_window = function()
        local win = hs.window.frontmostWindow()
        local screen = win:screen():frame()
        win:setFullScreen(true)
    end,

    medium_size_window = function()
        local win = hs.window.frontmostWindow()
        local screen = win:screen():frame()
        local w, h = screen.w * 0.8, screen.h * 0.8
        local frame = {
            x = screen.x + (screen.w - w) / 2,
            y = screen.y + (screen.h - h) / 2,
            w = w,
            h = h
        }
        ensureNotFullscreen(win)
        win:setFrame(frame)
    end,

    next_window_same_app = function()
        switchWindow(-1)
    end,

    prev_window_same_app = function()
        switchWindow(1)
    end,

    show_mission_control = function()
        hs.spaces.toggleMissionControl()
    end,

    show_desktop = function()
        hs.spaces.toggleShowDesktop()
    end,

    reload_config = function()
        hs.reload()
    end
}

-- Default keybindings
local default_keybindings = {
    move_left = { modifiers = {}, key = 'h', description = "Move Left" },
    move_right = { modifiers = {}, key = 'l', description = "Move Right" },
    move_up = { modifiers = {}, key = 'k', description = "Move Up" },
    move_down = { modifiers = {}, key = 'j', description = "Move Down"},
    center_window = { modifiers = {}, key = 'c', description = "Center" },
    maximize_window = { modifiers = {}, key = 'M', description = "Maximize" },
    fullscreen_window = { modifiers = { 'shift' }, key = 'M', description = "Fullscreen [Bad]" },
    medium_size_window = { modifiers = {}, key = 'N', description = "Medium Size" },
    next_window_same_app = { modifiers = {}, key = 'O', description = "Next Window (Same App)" },
    prev_window_same_app = { modifiers = {}, key = 'P', description = "Prev Window (Same App)" },
    show_mission_control = { modifiers = {}, key = 'A', description = "Mission Control" },
    show_desktop = { modifiers = {}, key = 'D', description = "Desktop" },
    reload_config = { modifiers = { 'shift' }, key = 'Z', description = "Reload Config" }
}

function M.setup(modalMgr, keybindings)
    -- Use provided keybindings or fall back to defaults
    local bindings = keybindings or default_keybindings

    modalMgr:new("resize")
    local resizeModal = modalMgr.modal_list["resize"]

    -- Bind all configured actions
    for action_name, binding in pairs(bindings) do
        local action_func = actions[action_name]
        if action_func then
            resizeModal:bind(binding.modifiers, binding.key, binding.description, action_func)
        end
    end

    -- Exit modal (always bound to escape)
    resizeModal:bind({}, 'escape', "Exit", function()
        modalMgr:deactivateAll()
    end)

    -- Activate modal
    modalMgr.supervisor:bind('alt', 'E', "Resize", function()
        modalMgr:activate({ "resize" }, '#74BB67', true)
    end)
end

-- Export actions for external access if needed
M.actions = actions
M.default_keybindings = default_keybindings

return M
