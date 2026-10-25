set verse ''
set next_verse 0
set next_width 0
set width 96
set offset 1
set pause_frames 8

while true
    set now (@date@ +%s)
    if test $now -ge $next_verse
        set candidate (@timeout@ 10 @godsays@ 2>/dev/null | string join ' ' | string replace -ar '\s+' ' ' | string trim)
        if test -n "$candidate"
            set verse "$candidate"
        else if test -z "$verse"
            set verse 'Scriptura non praesto est'
        end
        set next_verse (math $now + 300)
        set offset 1
        set pause_frames 8
    end

    if test $now -ge $next_width
        set output_name ''
        set -q WAYBAR_OUTPUT_NAME; and set output_name "$WAYBAR_OUTPUT_NAME"
        set candidate_width (@hyprctl@ monitors -j 2>/dev/null | @jq@ -er --arg output "$output_name" 'map(select(.name == $output or $output == "")) | first | (if .transform % 2 == 1 then .height else .width end) / .scale | ((. - 64) / @char_width@ | floor) | if . >= 16 then . else 16 end' 2>/dev/null)
        if string match -qr '^[0-9]+$' -- "$candidate_width"
            set width $candidate_width
        end
        set next_width (math $now + 5)
    end

    set verse_length (string length -- "$verse")
    set last_offset (math "max(1, $verse_length - $width + 1)")
    set offset (math "min($offset, $last_offset)")
    set visible (string sub --start $offset --length $width -- "$verse")
    @jq@ --null-input --compact-output --arg text "$visible" --arg tooltip "$verse" '{text: ($text | @html), tooltip: ($tooltip | @html)}'; or exit

    if test $verse_length -gt $width
        if test $pause_frames -gt 0
            set pause_frames (math $pause_frames - 1)
        else if test $offset -lt $last_offset
            set offset (math $offset + 1)
            if test $offset -eq $last_offset
                set pause_frames 8
            end
        else
            set offset 1
            set pause_frames 8
        end
    end
    @sleep@ 0.4
end
