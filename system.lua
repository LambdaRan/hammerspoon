local hotkey = require "hs.hotkey"
local caffeinate = require "hs.caffeinate"
local audiodevice = require "hs.audiodevice"

-- 使用系统锁屏快捷键 Ctrl+Command+q
-- hotkey.bind({'ctrl', 'alt', 'cmd'}, "W", function()
--   caffeinate.lockScreen()
--   -- caffeinate.startScreensaver()
-- end)

-- mute on sleep
function muteOnWake(eventType)
  if (eventType == caffeinate.watcher.systemDidWake) then
    local output = audiodevice.defaultOutputDevice()
    output:setMuted(true)
  end
end
caffeinateWatcher = caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()
