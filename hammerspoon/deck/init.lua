-- Wez Deck: Option+W opens a left-half panel of every WezTerm session, grouped by project.
-- Logic lives in ~/.config/wezdeck/bin/deck (Python); this file is only the window and the hotkey.
local M = {}

local HOME = os.getenv("HOME")
local PY = "/usr/bin/python3"
local DECK = HOME .. "/.config/wezdeck/bin/deck"
local WEZ_BUNDLE = "com.github.wez.wezterm"
local DIR = hs.configdir .. "/deck"

local panel, uc, prevWin, visible = nil, nil, nil, false
local lastModel = nil

local function readFile(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end

local function deck(args, cb)
  local full = { DECK }
  for _, a in ipairs(args) do table.insert(full, a) end
  local t = hs.task.new(PY, function(code, out, err) cb(code, out, err) end, full)
  t:start()
end

local LOG = HOME .. "/.config/wezdeck/panel.log"
local function plog(msg)
  local f = io.open(LOG, "a")
  if f then f:write(msg, "\n"); f:close() end
end

local LUA_REV = 2
plog(os.date("%H:%M:%S") .. " === deck module loaded (lua rev " .. LUA_REV .. ")")

local shotN = 0
local function shot(tag)
  -- Save what the window actually shows on screen, to compare with what the page believes.
  local w = panel and panel:hswindow()
  local img = w and w:snapshot()
  if not img then plog("shot '" .. tostring(tag) .. "': no snapshot (screen recording permission?)"); return end
  shotN = (shotN % 6) + 1
  local path = HOME .. "/.config/wezdeck/shot-" .. shotN .. ".png"
  img:saveToFile(path)
  plog(os.date("%H:%M:%S") .. " SCREENSHOT shot-" .. shotN .. ".png tag=" .. tostring(tag))
end

local function push(js)
  if panel then panel:evaluateJavaScript(js) end
end

-- Option+G (move session) and Option+R (rename code) are caught here while the panel is open,
-- because a web view does not reliably report Option combinations as key events.
local panelKeys = {
  hs.hotkey.new({ "alt" }, "g", function() push("deck.startMove()") end),
  hs.hotkey.new({ "alt" }, "r", function() push("deck.startRename()") end),
}
local function setPanelKeys(on)
  for _, hk in ipairs(panelKeys) do
    if on then hk:enable() else hk:disable() end
  end
end

local function leftHalf()
  local w = hs.window.focusedWindow()
  local scr = (w and w:screen()) or hs.screen.mainScreen()
  local f = scr:frame()
  return { x = f.x, y = f.y, w = math.floor(f.w / 2), h = f.h }
end

local function refresh()
  deck({ "model" }, function(code, out, err)
    if code == 0 and out and out ~= "" then
      lastModel = out
      push("deck.update(" .. out .. ")")
    else
      local msg = (out ~= "" and out) or err or "model failed"
      push("deck.flash(" .. hs.json.encode({ msg }):sub(2, -2) .. ", true)")
    end
  end)
end

local clickTap, appWatcher, shownAt = nil, nil, 0

local function hide(why)
  if panel then panel:hide() end
  visible = false
  setPanelKeys(false)
  if clickTap then clickTap:stop() end
  if appWatcher then appWatcher:stop() end
  if why then plog(os.date("%H:%M:%S") .. " panel hidden: " .. why) end
end

-- A floating panel that has lost focus must not stay up: the next Esc would go to whatever you clicked.
-- So the panel dismisses itself when you click anywhere outside it, or switch to another app.
local function insidePanel(pt)
  local f = panel and panel:frame()
  return f ~= nil and pt.x >= f.x and pt.x <= f.x + f.w and pt.y >= f.y and pt.y <= f.y + f.h
end
clickTap = hs.eventtap.new({
  hs.eventtap.event.types.leftMouseDown,
  hs.eventtap.event.types.rightMouseDown,
  hs.eventtap.event.types.otherMouseDown,
}, function(ev)
  if visible and not insidePanel(ev:location()) then
    -- hide after this click has been delivered, so it still reaches what was clicked
    hs.timer.doAfter(0, function() if visible then hide("click outside the panel") end end)
  end
  return false  -- never swallow the click
end)
appWatcher = hs.application.watcher.new(function(name, event)
  -- ignore the activation churn right after opening (the panel itself activates Hammerspoon)
  if visible and event == hs.application.watcher.activated and name ~= "Hammerspoon"
      and (hs.timer.secondsSinceEpoch() - shownAt) > 0.5 then
    hide("switched to " .. tostring(name))
  end
end)

local function handle(body)
  if body.type == "hide" then
    hide()
    if prevWin then prevWin:focus() end
  elseif body.type == "jump" then
    hide()
    -- Bring WezTerm forward first; the Lua handler in ~/.wezterm.lua then picks the right window and tab.
    local app = hs.application.get(WEZ_BUNDLE)
    if app then app:activate() end
    deck({ "jump", string.format("%d", body.pane_id) }, function(code, out)
      if code ~= 0 then hs.alert.show("deck: jump failed\n" .. tostring(out)) end
    end)
  elseif body.type == "shot" then
    shot(body.tag)
  elseif body.type == "log" then
    -- Debug trail the panel writes so scrolling problems can be diagnosed from outside the web view.
    local path = HOME .. "/.config/wezdeck/panel.log"
    local f = io.open(path, "a")
    if f then f:write(tostring(body.msg), "\n"); f:close() end
  elseif body.type == "assign" then
    deck({ "assign", body.session_id, body.spec }, function(code, out)
      local ok, res = pcall(hs.json.decode, out)
      if code ~= 0 and ok and res and res.error then
        push("deck.flash(" .. hs.json.encode({ res.error }):sub(2, -2) .. ", true)")
      end
      refresh()
    end)
  elseif body.type == "rename" then
    deck({ "rename", body.old, body["new"] }, function(code, out)
      local ok, res = pcall(hs.json.decode, out)
      if code ~= 0 and ok and res and res.error then
        push("deck.flash(" .. hs.json.encode({ res.error }):sub(2, -2) .. ", true)")
      end
      refresh()
    end)
  end
end

local function build()
  uc = hs.webview.usercontent.new("deck")
  uc:setCallback(function(msg) handle(msg.body) end)
  panel = hs.webview.new(leftHalf(), {}, uc)
  panel:windowStyle({ "borderless" })
  panel:allowTextEntry(true)
  panel:level(hs.drawing.windowLevels.floating)
  panel:shadow(true)
  panel:behavior(hs.drawing.windowBehaviors.moveToActiveSpace)
  panel:html(readFile(DIR .. "/panel.html") or "<body>deck: panel.html missing</body>")
end

-- The window modal (Option+E) and the deck must never be up together: opening either closes the other.
local function closeWindowModal()
  local mm = spoon and spoon.ModalMgr
  if mm and next(mm.active_list) ~= nil then
    mm:deactivateAll()
    plog(os.date("%H:%M:%S") .. " window modal closed because the deck opened")
  end
end

local function show()
  closeWindowModal()
  prevWin = hs.window.focusedWindow()
  if not panel then build() end
  panel:frame(leftHalf())
  panel:show()
  panel:bringToFront(true)
  local w = panel:hswindow()
  if w then w:focus() end
  visible = true
  shownAt = hs.timer.secondsSinceEpoch()
  setPanelKeys(true)
  clickTap:start()
  appWatcher:start()
  local logPath = HOME .. "/.config/wezdeck/panel.log"
  local lf = io.open(logPath, "a")
  if lf then
    lf:write("=== panel shown ", os.date("%H:%M:%S"), " frame h=", tostring(panel:frame().h), " w=", tostring(panel:frame().w), "\n")
    local size = lf:seek("end")
    lf:close()
    if size and size > 400000 then os.remove(logPath) end  -- keeps the log from growing forever
  end
  push("deck.open()")
  if lastModel then push("deck.update(" .. lastModel .. ")") end
  refresh()
end

function M.toggle()
  if visible then
    hide()
    if prevWin then prevWin:focus() end
  else
    show()
  end
end

do
  local mm = spoon and spoon.ModalMgr
  if mm and not mm._deckWrapped then
    local original = mm.activate
    mm.activate = function(self, ...)
      if visible then
        hide("window modal opened")
        if prevWin then prevWin:focus() end
      end
      return original(self, ...)
    end
    mm._deckWrapped = true
  end
end

-- Keep a reference so the hotkey is not garbage collected.
M.hotkey = hs.hotkey.bind({ "alt" }, "w", M.toggle)

return M
