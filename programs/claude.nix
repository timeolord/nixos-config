{
  config,
  pkgs,
  userName,
  ...
}:
{
  home.file.".claude/CLAUDE.md".text = ''
    I use NixOS, so for each for all dependencies make sure there is a flake.nix, along with a .envrc with "use flake". All comments should be lowercase written informally, without the use of any dashes. I prefer concise one liners and functional programming patterns. I prefer to use the languages Rust, Zig, and Haskell.
  '';
  home.packages = with pkgs; [
    claude-code
  ];
}
