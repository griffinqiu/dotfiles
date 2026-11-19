-- Terminal agents (Claude Code, Codex) and Herdr's remote image bridge all read
-- clipboard images on ctrl+v, while cmd+v only pastes text. Route cmd+v to
-- ctrl+v in terminals when the clipboard holds an image and no text.
local TERMINAL_BUNDLE_IDS = {
  ["com.mitchellh.ghostty"] = true,
  ["net.kovidgoyal.kitty"] = true,
}
local V_KEY_CODE = hs.keycodes.map["v"]

local function isTerminalFrontmost()
  local frontmostApp = hs.application.frontmostApplication()
  return frontmostApp ~= nil and TERMINAL_BUNDLE_IDS[frontmostApp:bundleID()] == true
end

local function clipboardHoldsOnlyImage()
  local availableTypes = hs.pasteboard.typesAvailable()
  return availableTypes.image == true and availableTypes.string ~= true
end

terminalImagePasteTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
  if event:getKeyCode() ~= V_KEY_CODE
    or not event:getFlags():containExactly({ "cmd" })
    or not isTerminalFrontmost()
    or not clipboardHoldsOnlyImage() then
    return false
  end

  return true, {
    hs.eventtap.event.newKeyEvent({ "ctrl" }, "v", true),
    hs.eventtap.event.newKeyEvent({ "ctrl" }, "v", false),
  }
end)
terminalImagePasteTap:start()
