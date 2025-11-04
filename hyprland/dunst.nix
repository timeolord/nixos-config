{ config, pkgs, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        indicate_hidden = "true";
        width = 300;
        height = "(0, 300)";
        origin = "top-right";
        offset = "(10, 50)";
        scale = 0;
        notification_limit = 0;
        progress_bar = "true";
        progress_bar_height = 10;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;

        separator_height = 0;
        padding = 8;
        horizontal_padding = 10;
        text_icon_padding = 0;
        frame_width = 0;
        sort = "yes";
        idle_threshold = 120;
        font = "Monospace 10";
        line_height = 0;
        markup = "full";
        format = "%s %p %b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = "false";
        show_indicators = "yes";

        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 64;
        icon_path = "";

        sticky_history = "yes";
        history_length = 20;

        browser = "${pkgs.firefox}/bin/firefox -new-tab";
        always_run_script = "true";

        title = "Dunst";
        class = "Dunst";

        corner_radius = 5;
        ignore_dbusclose = "false";

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";

        fullscreen = "show";
      };
      urgency_low = {
        background = "#45069380";
        foreground = "#f4d9e1ff";
        timeout = 10;
      };
      urgency_normal = {
        background = "#8c00ff80";
        foreground = "#f4d9e1ff";
        timeout = 10;
      };
      urgency_critical = {
        background = "#ff3f7f80";
        foreground = "#f4d9e1ff";
        timeout = 60;
      };
    };
  };
}
