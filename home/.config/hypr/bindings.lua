-- Personal overrides, loaded after Omarchy defaults by hyprland.lua.
-- Use OmaSwitch if its separately installed plugin is available.
local plugin = io.open(os.getenv("HOME") .. "/.config/omarchy/plugins/piyush.omaswitch/manifest.json", "r")
if plugin then
  plugin:close()
  hl.unbind("ALT + TAB")
  hl.unbind("ALT + SHIFT + TAB")
  o.bind("ALT + TAB", "OmaSwitch", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":1}'")
  o.bind("ALT + SHIFT + TAB", "OmaSwitch (reverse)", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":-1}'")
end

-- Short press shuts down; long press opens the power menu.
-- Defer the short action until release to avoid firing both actions.
hl.unbind("XF86PowerOff")
local power_long = false
o.bind("XF86PowerOff", nil, function()
  power_long = false
end, { locked = true })
o.bind("XF86PowerOff", "Power menu", function()
  power_long = true
  hl.exec_cmd("omarchy-menu toggle system")
end, { locked = true, long_press = true })
o.bind("XF86PowerOff", "Power off", function()
  if not power_long then
    hl.exec_cmd("omarchy-system-shutdown")
  end
end, { locked = true, release = true })
