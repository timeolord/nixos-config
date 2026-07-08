{ config, lib, pkgs, ... }:
let
  repoDict = "/etc/nixos/programs/aspell/en.pws";
  localDict = "${config.home.homeDirectory}/.aspell.en.pws";
  # union merge of two personal dictionaries, rewrites the target only when
  # the word set actually changed so the path unit doesnt loop
  mergeDicts = pkgs.writeShellScript "merge_aspell_dicts" ''
    set -eu
    PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gnugrep pkgs.diffutils ]}
    a="$1"; b="$2"; out="$3"
    tmp=$(mktemp)
    cat "$a" "$b" 2>/dev/null | { grep -av '^personal_ws' || true; } | { grep -av '^[[:space:]]*$' || true; } | LC_ALL=C sort -u > "$tmp"
    result=$(mktemp)
    printf 'personal_ws-1.1 en %d\n' "$(wc -l < "$tmp")" > "$result"
    cat "$tmp" >> "$result"
    if [ ! -e "$out" ] || ! cmp -s "$result" "$out"; then mv "$result" "$out"; else rm "$result"; fi
    rm "$tmp"
  '';
in
{
  # seed the local dictionary from the repo copy on rebuild, keeping any
  # words that were only added locally
  home.activation.aspellDict = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${mergeDicts} ${./en.pws} ${localDict} ${localDict}
  '';

  # watch the local dictionary and fold new words back into the repo copy
  systemd.user.paths.aspell-dict-sync = {
    Unit.Description = "watch the aspell personal dictionary for new words";
    Path.PathChanged = localDict;
    Install.WantedBy = [ "default.target" ];
  };
  systemd.user.services.aspell-dict-sync = {
    Unit.Description = "merge new aspell words into the nixos repo";
    Service = {
      Type = "oneshot";
      ExecStart = "${mergeDicts} ${localDict} ${repoDict} ${repoDict}";
    };
  };
}
