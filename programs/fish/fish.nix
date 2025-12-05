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
      untar = "tar -xf";
      lsa = "ls -lha";
      emacs = "emacs 2> /dev/null &";
      du = "du -h";
      fish = "exec fish";
    };
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      set PYTHONSTARTUP /etc/nixos/python/startup.py
      set -gx EDITOR emacs
      function fish_greeting
         rm -r /home/${userName}/Downloads 2> /dev/null
         rm -r /home/${userName}/null 2> /dev/null
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
