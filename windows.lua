-- window management
local application = require "hs.application"
local hk = require "hs.hotkey"
local window = require "hs.window"
local layout = require "hs.layout"
local grid = require "hs.grid"
local screen = require "hs.screen"
local alert = require "hs.alert"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local mouse = require "hs.mouse"


-- default 0.2
window.animationDuration = 0


-- 移动鼠标
-- move cursor to previous monitor
function cursorPrev() 
    -- focusScreen(window.focusedWindow():screen():previous())
    local screens = screen.allScreens()
    if 1 > #screens then
      alert.show("Only " .. #screens .. " monitors ")
    else
      focusScreen(screens[1])
      alert.show("cursor is here", alert.defaultStyle,screens[1])
    end
end

-- move cursor to next monitor
function cursorNext() 
  -- focusScreen(window.focusedWindow():screen():next())
  local screens = screen.allScreens()
  if 2 > #screens then
    alert.show("Only " .. #screens .. " monitors ")
  else
    focusScreen(screens[2])
    alert.show("cursor is here",alert.defaultStyle,screens[2])
  end
end

-- Predicate that checks if a window belongs to a screen
function isInScreen(screen, win)
  return win:screen() == screen
end

function focusScreen(screen)
  --Get windows within screen, ordered from front to back.
  --If no windows exist, bring focus to desktop. Otherwise, set focus on
  --front-most application window.
  local windows = fnutils.filter(
      window.orderedWindows(),
      fnutils.partial(isInScreen, screen))
  local windowToFocus = #windows > 0 and windows[1] or window.desktop()
  windowToFocus:focus()
  -- move cursor to center of screen
  local pt = geometry.rectMidPoint(screen:fullFrame())
  mouse.setAbsolutePosition(pt)
end


-- 窗口操作
-- Some constructors, just for programming
function Cell(x, y, w, h)
  return hs.geometry(x, y, w, h)
end

-- left half
function leftHalf() 
  local lwindow = window.focusedWindow()
  local lscreen = window.focusedWindow():screen()
  local lscreenGrid = grid.getGrid(lscreen)
  local cell = Cell(0, 0, 0.5 * lscreenGrid.w, lscreenGrid.h)
  grid.set(lwindow, cell, lscreen)
  lwindow.setShadows(true)
end

-- right half
function rightHalf()
  local lwindow = window.focusedWindow()
  local lscreen = window.focusedWindow():screen()
  local lscreenGrid = grid.getGrid(lscreen)
  local cell = Cell(0.5 * lscreenGrid.w, 0, 0.5 * lscreenGrid.w, lscreenGrid.h)
  grid.set(lwindow, cell, lscreen)
  lwindow.setShadows(true)
end

-- top half
function topHalf()
  local lwindow = window.focusedWindow()
  local lscreen = window.focusedWindow():screen()
  local lscreenGrid = grid.getGrid(lscreen)
  local cell = Cell(0, 0, lscreenGrid.w, 0.5 * lscreenGrid.h)
  grid.set(lwindow, cell, lscreen)
end

-- bottom half
function bottomHalf()
  local lwindow = window.focusedWindow()
  local lscreen = window.focusedWindow():screen()
  local lscreenGrid = grid.getGrid(lscreen)
  local cell = Cell(0, 0.5 * lscreenGrid.h, lscreenGrid.w, 0.5 * lscreenGrid.h)
  grid.set(lwindow, cell, lscreen)
end

----------------------------------------------------------------
-- maximize screen
function maximizeWindow()
  local lwindow = window.focusedWindow()
  grid.maximizeWindow(lwindow)
end

function fullScreen()
  window.focusedWindow():toggleFullScreen()
end

----------------------------------------------------------------
-- 将窗口移动到另外一个屏幕

function throwLeft()
  window.focusedWindow():moveOneScreenWest()
end

function throwRight()
  window.focusedWindow():moveOneScreenEast()
end

-----------------------------------------------------
-- 按键定义
local function windowBind(hyper, keyFuncTable)
  for key,fn in pairs(keyFuncTable) do
    hk.bind(hyper, key, fn)
  end
end

-- * Move window to screen
windowBind({"ctrl", "cmd"}, {
  left = throwLeft,
  right = throwRight,
})

-- * Set Window Position on screen
windowBind({"ctrl", "alt", "cmd"}, {
  m = maximizeWindow,    -- ⌃⌥⌘ + M
  f = fullScreen,         -- ⌃⌥⌘ + F
  left = leftHalf,       -- ⌃⌥⌘ + ←
  right = rightHalf,     -- ⌃⌥⌘ + →
  up = topHalf,          -- ⌃⌥⌘ + ↑
  down = bottomHalf,      -- ⌃⌥⌘ + ↓
})

-- * Move cursor to screen
windowBind({"ctrl", "alt"}, {
  left = cursorPrev,
  right = cursorNext,
})
