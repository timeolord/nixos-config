{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  programs.fish = {
    enable = true;
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      set -gx EDITOR emacs
      abbr --add rb rebuild.sh
      function fish_greeting
         fastfetch
         godsays
      end
    '' + builtins.readFile ./prompt.fish;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
