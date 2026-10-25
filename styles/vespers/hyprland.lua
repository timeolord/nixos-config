hl.config({
  general = {
    gaps_in = 8,
    gaps_out = 18,
    border_size = 2,
    ["col.active_border"] = { colors = { "rgba(@base0A@ff)", "rgba(@base0D@ff)", "rgba(@base02@ff)" }, angle = 45 },
    ["col.inactive_border"] = "rgba(@base02@dd)",
  },
  decoration = {
    rounding = 3,
    shadow = { enabled = true, range = 24, render_power = 3, color = "rgba(0d0907cc)" },
    blur = { enabled = true, size = 4, passes = 2, vibrancy = 0.08 },
  },
})

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "default", style = "popin 96%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "default", style = "popin 96%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "default", style = "popin 98%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default", style = "fade" })
