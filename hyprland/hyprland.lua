-- base hyprland config in the new lua form
-- see https://wiki.hypr.land/Configuring/

-- programs
local terminal = "kitty"
local menu = "fuzzel"
local mainMod = "SUPER"

----------------
--- monitors ---
----------------

-- fallback rule for any monitor not explicitly defined, per machine configs add their own
hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1 })

---------------------
--- look and feel ---
---------------------

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 5,
    border_size = 2,
    ["col.active_border"] = { colors = { "rgba(8c00ffff)", "rgba(450693ff)" }, angle = 90 },
    ["col.inactive_border"] = "rgba(595959aa)",
    resize_on_border = false,
    allow_tearing = false,
    layout = "master",
    no_focus_fallback = true,
  },
  decoration = {
    rounding = 5,
    rounding_power = 2,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },
  animations = {
    enabled = true,
  },
  master = {
    new_status = "slave",
    mfact = 0.65,
    orientation = "right",
  },
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
  },
  input = {
    kb_layout = "us",
    follow_mouse = 2,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
      clickfinger_behavior = true,
    },
  },
})

--------------------
--- animations -----
--------------------

hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "wind", style = "slide" })
hl.animation({ leaf = "fade", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "wind" })

---------------------
--- keybindings -----
---------------------

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("hyprshot -m output --clipboard-only"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprshot -m window --clipboard-only"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("emacsclient -c"))
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- resize the active window
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))
hl.bind(mainMod .. " + CTRL + I", hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.resize({ x = 0, y = 50, relative = true }))

-- move focus and windows in a direction
local dirs = { J = "l", L = "r", I = "u", K = "d" }
for key, dir in pairs(dirs) do
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- switch and move windows to workspaces
for i = 1, 9 do
  hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = true }))

hl.bind(mainMod .. " + ALT + I", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.focus({ workspace = "e-1" }))

-- scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- move and resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- audio keys, repeating and working while locked
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { repeating = true, locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { repeating = true, locked = true })

-- brightness keys, pick the first non nvidia backlight
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd([[device=$(ls /sys/class/backlight | grep -v "^nvidia_" | head -n1); [ -n "$device" ] || device=$(ls /sys/class/backlight | head -n1); brightnessctl -d "$device" -e4 -n2 set 5%+]]), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd([[device=$(ls /sys/class/backlight | grep -v "^nvidia_" | head -n1); [ -n "$device" ] || device=$(ls /sys/class/backlight | head -n1); brightnessctl -d "$device" -e4 -n2 set 5%-]]), { repeating = true, locked = true })

-- media keys, working while locked
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------------
--- windows and workspaces ---
------------------------------

-- ignore maximize requests from apps
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

-- fix some dragging issues with xwayland
hl.window_rule({
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = true, pin = true },
  no_focus = false,
})

-- slight transparency on some apps
hl.window_rule({ match = { class = "^(discord)$" }, opacity = "0.90" })
hl.window_rule({ match = { class = "^(com.github.th_ch.youtube_music)$" }, opacity = "0.90" })
hl.window_rule({ match = { class = "^(signal)$" }, opacity = "0.90" })
hl.window_rule({ match = { class = "^(Todoist)$" }, opacity = "0.90" })

-- fullscreen windows stay opaque
hl.window_rule({ match = { fullscreen = true }, opacity = "1.0" })

-----------------
--- autostart ---
-----------------

hl.on("hyprland.start", function()
  -- required for desktop functionality
  hl.exec_cmd("fcitx5 -d -r")
  hl.exec_cmd("dunst")
  hl.exec_cmd("hyprpaper")
  hl.exec_cmd("systemctl --user restart pipewire")
  hl.exec_cmd("systemctl --user start hyprpolkitagent")
  hl.exec_cmd("blueman-applet")
  hl.exec_cmd("waybar")
  hl.exec_cmd("nm-applet")

  -- personal apps
  hl.exec_cmd("firefox", { workspace = "1 silent" })
  hl.exec_cmd("discord --enable-features=UseOzonePlatform --ozone-platform=wayland", { workspace = "6 silent" })
  hl.exec_cmd("signal-desktop", { workspace = "6 silent" })
end)
