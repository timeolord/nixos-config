if test (count $argv) -ne 2; or not contains -- "$argv[2]" true false
    echo 'usage: discord-theme-setup settings_file true|false' >&2
    exit 2
end
set settings_file $argv[1]
set enabled $argv[2]
if not test -e "$settings_file"; and test "$enabled" = false
    exit 0
end
umask 077
@coreutils@/mkdir -p -- (@coreutils@/dirname -- "$settings_file")
or exit 1
set temp_file (@coreutils@/mktemp "$settings_file.XXXXXX")
or exit 1
function cleanup --on-event fish_exit --inherit-variable temp_file
    @coreutils@/rm -f -- "$temp_file"
end
set input_file /dev/null
if test -e "$settings_file"
    set input_file "$settings_file"
end
@jq@ --slurp --arg theme stylix.theme.css --argjson enabled "$enabled" '
    if length == 0 then {}
    elif length == 1 and (.[0] | type == "object") then .[0]
    else error("expected a vencord settings object") end
    | .enabledThemes = ((.enabledThemes // [])
        | if type == "array" and all(.[]; type == "string") then .
          else error("expected a list of theme names") end
        | map(select(. != $theme)) + (if $enabled then [$theme] else [] end))
' "$input_file" > "$temp_file"
or exit 1
if test -e "$settings_file"; and @jq@ --exit-status --slurpfile original "$settings_file" '$original[0] == .' "$temp_file" > /dev/null
    exit 0
end
@coreutils@/mv -f -- "$temp_file" "$settings_file"
