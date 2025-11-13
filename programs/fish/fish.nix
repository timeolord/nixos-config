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
      du = "du -h";
      fish = "exec fish";
    };
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      set PYTHONSTARTUP /etc/nixos/python/startup.py
      set -gx EDITOR emacs
      function fish_greeting
         fastfetch
         echo "God Says..."
         godsays
         ls
      end
    '' + (builtins.readFile ./prompt.fish) + (builtins.readFile ./functions.fish);
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
