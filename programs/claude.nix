{
  config,
  inputs,
  lib,
  pkgs,
  userName,
  ...
}:
let
  prompt = ''
    I use NixOS, so for all dependencies make sure there is a flake.nix, along with a .envrc with "use flake". All comments should be lowercase written informally, without the use of any dashes. I prefer concise one liners and functional programming patterns. I prefer to use the languages Rust, Zig, and Haskell. I want functions to be named in snakecase. I use fish instead of bash. In Zig I do not want any default values to be used. If a default value is needed, a constructor should be used instead. Please avoid AI mannerisms, like em dashes, emojis, and unnecessary bolding, just use headers and text, with code snippets if necessary.
  '';
in
{
  home.file.".claude/CLAUDE.md".text = prompt;
  # home.file.".claude/settings.json".text = ''
  #   {
  #     "effortLevel": "medium",
  #     "env": {
  #       "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50",
  #       "CLAUDE_CODE_SUBAGENT_MODEL": "haiku"
  #     }
  #   }'';
  home.file.".codex/AGENTS.md".text = prompt;
  home.activation.codex_defaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3.withPackages (ps: [ ps.tomlkit ])}/bin/python3 - <<'PY'
    import os
    from pathlib import Path
    import tomlkit

    path = Path("${config.home.homeDirectory}/.codex/config.toml")
    path.parent.mkdir(parents=True, exist_ok=True)
    original = path.read_text() if path.exists() else ""
    settings = tomlkit.parse(original)
    settings.update(sandbox_mode="workspace-write", approval_policy="on-request", approvals_reviewer="auto_review")
    updated = tomlkit.dumps(settings)
    if updated != original:
        temporary = path.with_suffix(".toml.tmp")
        temporary.touch(mode=0o600, exist_ok=False)
        temporary.write_text(updated)
        os.replace(temporary, path)
    PY
  '';

  #   home.file.".claude/settings.json".text = ''
  # {
  #   "env": {
  #     "CLAUDE_CODE_ATTRIBUTION_HEADER": 0
  #   }
  # }
  # '';

  home.packages = with pkgs; [
    claude-code
    inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
