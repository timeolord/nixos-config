{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.waybar
    pkgs.playerctl
  ];
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        position = "top";
        layer = "top";
        margin-top = 0;
        margin-bottom = 0;
        margin-left = 0;
        margin-right = 0;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [
          "cpu"
          "custom/nvidia"
          "memory"
          "disk"
          "network"
        ];
        modules-right = [
          "tray"
          "hyprland/language"
          "pulseaudio"
          "battery"
          "clock#date"
          "clock"
          "custom/power"
        ];

        "hyprland/language" = {
          format = "{}";
          format-en = "英文";
        };

        "hyprland/workspaces" = {
          active-only = false;
          all-outputs = true;
          on-scroll-up = "hyprctl dispatch workspace -1";
          on-scroll-down = "hyprctl dispatch workspace +1";
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
          format-icons = {
            "1" = "壹";
            "2" = "贰";
            "3" = "叁";
            "4" = "肆";
            "5" = "伍";
            "6" = "陆";
            "7" = "柒";
            "8" = "捌";
            "9" = "玖";
            "10" = "拾";
            urgent = "";
          };
        };

        "custom/power" = {
          format = "⏻ ";
          on-click = "syspower";
        };
        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-connected = " {num_connections} connected";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
        };
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{icon} {time}";
          format-icons = [
            " "
            " "
            " "
            " "
            " "
          ];
        };
        "custom/nvidia" = {
          exec = "nvidia-smi --query-gpu=utilization.gpu --format=csv,nounits,noheader";
          format = "󱑵  {}%";
          interval = 1;
        };
        memory = {
          format = "  {}%";
          format-alt = "  {used}/{total} GiB";
          interval = 5;
        };
        cpu = {
          format = "  {usage}%";
          format-alt = "  {avg_frequency} GHz";
          interval = 1;
        };
        disk = {
          format = "󰋊 {percentage_used}%";
          format-alt = "󰋊 {used}/{total} GiB";
          interval = 5;
          path = "/";
        };
        network = {
          format-wifi = "󰤨 {essid} {bandwidthUpBytes} {bandwidthDownBytes}";
          format-ethernet = " {bandwidthUpBytes} {bandwidthDownBytes}";
          format-linked = " {bandwidthUpBytes} {bandwidthDownBytes}";
          format-disconnected = "󰤭";
          # format-alt = "";
          tooltip-format = "{frequency} {signalStrength}";
          on-click-right = "nm-connection-editor";
          interval = 1;
        };
        tray = {
          icon-size = 16;
          spacing = 5;
        };
        clock = {
          interval = 1;
          format = "{:%I:%M %p}";
          tooltip = false;
        };
        "clock#date" = {
          interval = 60;
          format = "{:%b %a %d}";
          tooltip = false;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          scroll-step = 5;
          on-click-right = "pavucontrol";
        };
      };
    };
    style = builtins.readFile ./waybar.css;
  };
}
