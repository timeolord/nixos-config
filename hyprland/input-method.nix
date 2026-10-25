{ config, lib, pkgs, ... }:
let
  input_methods = [
    { name = "keyboard-us"; label = "英文"; layout = "us"; }
    { name = "keyboard-us-intl"; label = "法文"; layout = "us-intl"; }
    { name = "pinyin"; label = "中文"; layout = "us"; }
    { name = "mozc"; label = "日文"; layout = "us"; }
    { name = "keyboard-tr"; label = "土耳其文"; layout = "tr"; }
  ];
  language_labels = config.desktop.language_labels;
  language_tooltip = config.desktop.language_tooltip;
  language_status = pkgs.writeTextFile {
    name = "fcitx5-language";
    destination = "/bin/fcitx5-language";
    executable = true;
    checkPhase = "${pkgs.fish}/bin/fish --no-execute $out/bin/fcitx5-language";
    text = ''
      #!${pkgs.fish}/bin/fish
      set input_methods ${lib.escapeShellArgs (map (method: method.name) input_methods)}
      set messages ${lib.escapeShellArgs (map (method: builtins.toJSON { text = language_labels.${method.name}; tooltip = language_tooltip; }) input_methods)}
      set current (${pkgs.fcitx5}/bin/fcitx5-remote --check -n 2>/dev/null)
      set index (contains --index -- "$current" $input_methods)
      if not test -n "$index"
          printf '%s\n' ${lib.escapeShellArg (builtins.toJSON { text = "?"; tooltip = config.desktop.language_unavailable; class = "unavailable"; })}
          exit 0
      end
      switch "$argv[1]"
          case next prev
              set step 1
              if test "$argv[1]" = prev
                  set step -1
              end
              set total (count $input_methods)
              set index (math "($index - 1 + $step + $total) % $total + 1")
              ${pkgs.fcitx5}/bin/fcitx5-remote --check -s "$input_methods[$index]"
          case '*'
              printf '%s\n' "$messages[$index]"
      end
    '';
  };
in
{
  options.desktop = {
    language_labels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = builtins.listToAttrs (map (method: { inherit (method) name; value = method.label; }) input_methods);
      description = "Waybar labels for each fcitx input method.";
    };
    language_tooltip = lib.mkOption {
      type = lib.types.str;
      default = "左键或向上滚动切换，右键或向下滚动返回";
      description = "Tooltip for the Waybar language selector.";
    };
    language_unavailable = lib.mkOption {
      type = lib.types.str;
      default = "输入法不可用";
      description = "Tooltip when fcitx is unavailable.";
    };
  };

  config = {
    home.packages = [ language_status ];

    xdg.configFile."fcitx5/profile".text = ''
      [Groups/0]
      Name=Default
      Default Layout=us
      DefaultIM=keyboard-us

    '' + lib.concatImapStringsSep "\n" (index: method: ''
      [Groups/0/Items/${toString (index - 1)}]
      Name=${method.name}
      Layout=${method.layout}
    '') input_methods + ''

      [GroupOrder]
      0=Default
    '';

    xdg.configFile."fcitx5/config".text = ''
      [Hotkey]
      EnumerateSkipFirst=False

      [Hotkey/TriggerKeys]
      [Hotkey/AltTriggerKeys]
      [Hotkey/EnumerateForwardKeys]
      0=Super+space
      [Hotkey/EnumerateBackwardKeys]
      0=Super+Shift+space
      [Hotkey/EnumerateGroupForwardKeys]
      [Hotkey/EnumerateGroupBackwardKeys]

      [Behavior]
      ShareInputState=All
    '';

    # let emacs receive control semicolon
    xdg.configFile."fcitx5/conf/clipboard.conf".text = ''
      [TriggerKey]
    '';

    programs.waybar.settings.mainBar."custom/language" = {
      exec = "${language_status}/bin/fcitx5-language";
      return-type = "json";
      interval = 1;
      on-click = "${language_status}/bin/fcitx5-language next";
      on-click-right = "${language_status}/bin/fcitx5-language prev";
      on-scroll-up = "${language_status}/bin/fcitx5-language next";
      on-scroll-down = "${language_status}/bin/fcitx5-language prev";
    };
  };
}
