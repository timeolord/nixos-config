{ lib, pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-unstable-pgtk;
      config = ./emacs.el;
      defaultInitFile = false;
      alwaysEnsure = true;
    };
    extraConfig = lib.mkBefore (builtins.readFile ./emacs.el);
  };

  # treemacs needs python3 for its extended and deferred git modes, without
  # it the git status annotations silently break
  home.packages = [ pkgs.python3 ];

  # emacs runs as a daemon so all the init cost is paid once at login,
  # emacsclient frames then open instantly
  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };
}
