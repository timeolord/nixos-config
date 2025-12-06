{ config, pkgs, ...}:
{
  home.packages = [ pkgs.waybar ];
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

        modules-left = ["hyprland/workspaces"];
        modules-center = ["cpu" "memory" "disk"];
        modules-right = ["tray" "network" "pulseaudio" "battery" "clock#date" "clock" "custom/power"];

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
          format = "⏻";
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
          format-icons = [" " " " " " " " " "];
        };
        memory = {
          format = "󰍛 {}%";
          format-alt = "󰍛 {used}/{total} GiB";
          interval = 5;
        };
        cpu = {
          format = "󰻠 {usage}%";
          format-alt = "󰻠 {avg_frequency} GHz";
          interval = 1;
        };
        disk = {
          format = "󰋊 {percentage_used}%";
          format-alt = "󰋊 {used}/{total} GiB";
          interval = 5;
          path = "/";
        };
        network = {
          "format-wifi" = "󰤨";
        	"format-ethernet" = " {ifname}: Aesthetic";
        	"format-linked" = " {ifname} (No IP)";
        	"format-disconnected" = "󰤭";
        	"format-alt" = " {ifname}: {ipaddr}/{cidr}";
          "tooltip-format" = "{essid}";
          "on-click" = "wpanm-connection-editor";
        };
        tray = {
          icon-size = 16;
          spacing = 5;
        };
        clock = {
          interval = 1;
          format = "{:%I:%M %p}";
        };
        "clock#date" = {
          interval = 60;
          format = "{:%b %a %d}";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
        	format-muted = "󰝟";
		      format-icons = {
			      default = ["󰕿" "󰖀" "󰕾"];
		      };
          scroll-step = 5;
		      on-click-right = "pavucontrol";
        };
      };
    };
    style = builtins.readFile ./waybar.css;
  };
}
