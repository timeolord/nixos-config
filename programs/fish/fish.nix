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
      function vterm_printf;
        if begin; [  -n "$TMUX" ]  ; and  string match -q -r "screen|tmux" "$TERM"; end
        # tell tmux to pass the escape sequences through
          printf "\ePtmux;\e\e]%s\007\e\\" "$argv"
        else if string match -q -- "screen*" "$TERM"
        # GNU screen (screen, screen-256color, screen-256color-bce)
          printf "\eP\e]%s\007\e\\" "$argv"
        else
          printf "\e]%s\e\\" "$argv"
        end
      end
    '' + (builtins.readFile ./prompt.fish) + (builtins.readFile ./functions.fish);
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
