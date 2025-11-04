{ config, pkgs, ... }:
{
  imports = [
    ./hyprland/hyprland.nix
  ];

  home.username = "melk";
  home.homeDirectory = "/home/melk";
 
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
    any-nix-shell
  ];

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
    set PATH /etc/nixos /home/melk/.local/bin $PATH
    abbr --add rb rebuild.sh
    abbr --add mtlb nix run gitlab:doronbehar/nix-matlab
    set -g fish_greeting
    '';
    interactiveShellInit=''
    fastfetch
    ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    godsays
    '';
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi_aware = "yes";
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        auto-select = "yes";
      };
      colors = {
        background = "282828dd";
        text = "f4d9e1ff";
        prompt = "f4d9e1ff";
        placeholder="838ba7ff";
        input="f4d9e1ff";
        match="ffc40080";
        selection="8c00ff90";
        selection-text="ff3f7fff";
        selection-match="ffce00ff";
        counter="8c00ffff";
        border="450693ff";
      };
    };
  };
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
