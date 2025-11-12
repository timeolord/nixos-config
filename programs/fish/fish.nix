{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  home.packages = [ pkgs.any-nix-shell pkgs.fastfetch ];
  programs.fastfetch = {
    settings = {
      modules = [
      ];
    };
  };
  programs.fish = {
    enable = true;
    shellAbbrs = {
      rb = "rebuild.sh";
      nclean = "nix-clean.sh";
      fperm = "fix-permissions.sh";
      gs = "git status";
      gau = "git add - u";
      gcm = "git commit -m";
      gph = "git push";
      gpl = "git pull";
      "..." = "cd ../..";
      utar = "tar -xf";
      lsa = "ls -lha";
      emacs = "emacs 2> /dev/null &";
    };
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      set -gx EDITOR "emacs 2> /dev/null"
      function fish_greeting
         fastfetch
         echo "God Says..."
         godsays
      end
    '' + (builtins.readFile ./prompt.fish) + (builtins.readFile ./functions.fish);
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
