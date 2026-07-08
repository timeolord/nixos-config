{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacsWithPackagesFromUsePackage {
      package = pkgs.emacs-unstable-pgtk;
      config = ./emacs.el;
      defaultInitFile = true;
      alwaysEnsure = true;
    };
  };

  # emacs runs as a daemon so all the init cost is paid once at login,
  # emacsclient frames then open instantly
  services.emacs = {
    enable = true;
    client.enable = true;
    startWithUserSession = "graphical";
  };
}
