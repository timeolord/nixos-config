{
  config,
  pkgs,
  userName,
  ...
}:
{
  home.file.".claude/CLAUDE.md".text = ''
    I use NixOS, so for all dependencies make sure there is a flake.nix, along with a .envrc with "use flake". All comments should be lowercase written informally, without the use of any dashes. I prefer concise one liners and functional programming patterns. I prefer to use the languages Rust, Zig, and Haskell. I want functions to be named in snakecase. In Zig I do not want any default values to be used. If a default value is needed, a constructor should be used instead.
'';
  home.file.".claude/settings.json".text = ''
{
  "effortLevel": "medium"
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50",
    "CLAUDE_CODE_SUBAGENT_MODEL": "haiku",
  }
}'';

#   home.file.".claude/settings.json".text = ''
# {
#   "env": {
#     "CLAUDE_CODE_ATTRIBUTION_HEADER": 0
#   }
# }
# '';

  home.packages = with pkgs; [
    claude-code
    codex
    bubblewrap
  ];
}
