hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 3,
    ["col.active_border"] = "rgba(@base0D@ff)",
    ["col.inactive_border"] = "rgba(@base02@ff)",
  },
  decoration = {
    rounding = 0,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = { enabled = false },
    blur = { enabled = false },
  },
  animations = { enabled = false },
})

hl.window_rule({ match = { class = "^(discord|signal|com.github.th_ch.youtube_music|Todoist)$" }, opacity = "1.0" })
