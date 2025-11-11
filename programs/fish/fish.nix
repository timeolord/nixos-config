{
  config,
  pkgs,
  userName,
  inputs,
  ...
}:
{
  home.packages = [ pkgs.any-nix-shell pkgs.neofetch ];
  # programs.fastfetch = {
  #   settings = {
  #     modules = [
        
  #     ];
  #   };
  # };
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
    };
    shellInit = ''
      set PATH /etc/nixos /home/${userName}/.local/bin $PATH
      set -gx EDITOR emacs
      abbr --add rb rebuild.sh
      function fish_greeting
         fastfetch
         neofetch
      end
    '' + builtins.readFile ./prompt.fish;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
  };
}
