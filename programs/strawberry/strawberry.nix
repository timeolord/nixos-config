{ config, lib, pkgs, ... }:
let
  repoConf = "/etc/nixos/programs/strawberry/strawberry.conf";
  localConf = "${config.xdg.configHome}/strawberry/strawberry.conf";
  # install keeps the destination writable, a plain cp from the store would
  # leave a read only file that strawberry cannot save to
  copyIfChanged = pkgs.writeShellScript "copy_if_changed" ''
    set -eu
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.diffutils ]}
    src="$1"; dst="$2"
    if [ -e "$src" ] && ! cmp -s "$src" "$dst"; then
      install -D -m 600 "$src" "$dst"
    fi
  '';
in
{
  home.packages = [ pkgs.strawberry ];

  # the repo copy wins on rebuild, local changes flow back in between, same
  # idea as the aspell dictionary but whole file since ini cannot be merged
  home.activation.strawberryConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${copyIfChanged} ${./strawberry.conf} ${localConf}
  '';

  systemd.user.paths.strawberry-conf-sync = {
    Unit.Description = "watch strawberry settings for changes";
    Path.PathChanged = localConf;
    Install.WantedBy = [ "default.target" ];
  };
  systemd.user.services.strawberry-conf-sync = {
    Unit.Description = "copy strawberry settings into the nixos repo";
    Service = {
      Type = "oneshot";
      ExecStart = "${copyIfChanged} ${localConf} ${repoConf}";
    };
  };
}
