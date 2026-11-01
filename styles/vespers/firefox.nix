{ config, lib, pkgs, ... }:
let
  render_style = import ../render.nix { inherit config lib; };
  stylesheet = pkgs.writeText "vespers-firefox.css" (render_style (builtins.readFile ./firefox.css));
in
{
  config = lib.mkIf (lib.elem config.style.name [ "vespers" "vespers-16" ]) {
    programs.firefox = {
      package = pkgs.firefox.override {
        extraAutoConfig = ''pref("general.config.sandbox_enabled", false);'';
      };
      autoConfig = ''
        var vespers_style_service = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
        var vespers_io_service = Components.classes["@mozilla.org/network/io-service;1"].getService(Components.interfaces.nsIIOService);
        var vespers_stylesheet = vespers_io_service.newURI("file://${stylesheet}");
        if (!vespers_style_service.sheetRegistered(vespers_stylesheet, vespers_style_service.USER_SHEET)) {
          vespers_style_service.loadAndRegisterSheet(vespers_stylesheet, vespers_style_service.USER_SHEET);
        }
      '';
    };
  };
}
