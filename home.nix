{ config, pkgs, ... }:

{
  home.username = "melk";
  home.homeDirectory = "/home/melk";

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      shell = "${pkgs.fish}/bin/fish";
      background_opacity = 0.5;
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.variables = ["--all"];
    extraConfig = builtins.readFile ./hyprland.conf;
  };
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
        modules-right = ["tray" "network" "pulseaudio" "battery" "clock"];

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
        battery = {
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          format-alt = "{icon} {time}";
          format-icons = ["" "" "" "" ""];
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
          "on-click-right" = "nm-connection-editor";
        };
        tray = {
          icon-size = 16;
          spacing = 5;
        };
        pulseaudio = {
          format = "{icon} {volume}%";
        	format-muted = "󰝟";
		      format-icons = {
			      default = ["󰕿" "󰖀" "󰕾"];
		      };
		      # on-click = "bash /etc/nixos/scripts/volume-mute";
          # on-scroll-up = "bash /etc/nixos/scripts/volume-up";
          # on-scroll-down = "bash /etc/nixos/scripts/.scripts/volume-down";
          scroll-step = 5;
		      on-click-right = "pavucontrol";
        };
      };
    };
    style = builtins.readFile ./waybar.css;
  };
  services.dunst = {
    enable = true;
    settings = {
    };
  };
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "/etc/nixos/wallpapers/ivan_the_terrible.jpg"
      ];
      wallpaper = [
        ", /etc/nixos/wallpapers/ivan_the_terrible.jpg"
      ];
    };
  };
 
  home.packages = with pkgs; [
    bitwarden-desktop
    youtube-music
    discord
    signal-desktop
    bazecor
    zoom-us
    obsidian
    todoist-electron
    qbittorrent
    ghostscript
    pandoc
    zotero
    fastfetch
    gimp
  ];

  programs.git = {
    enable = true;
    settings.user.name = "melk";
    settings.user.email = "timeolord6677@gmail.com";
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
    ];
    extraConfig = builtins.readFile ./emacs.el;
  };

  programs.bash = {
    enable = true;  
  };

  programs.fish = {
    enable = true;
    shellInit = ''
    set PATH /etc/nixos $PATH
    abbr --add rb rebuild.sh
    '';
    interactiveShellInit=''
    fastfetch
    '';
  };

    # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
