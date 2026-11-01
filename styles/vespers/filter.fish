set action toggle
if test (count $argv) -gt 1
    echo 'usage: vespers_filter [on|dither|off|toggle|status]' >&2
    exit 2
end
if test (count $argv) -eq 1
    set action $argv[1]
end
if not contains -- $action on dither off toggle status
    echo 'usage: vespers_filter [on|dither|off|toggle|status]' >&2
    exit 2
end
function get_shader
    set response (@hyprctl@ -j getoption decoration.screen_shader)
    or return 1
    printf '%s\n' "$response" | @jq@ -er '.str | select(type == "string")'
end

set current (get_shader)
or exit 1
set enabled off
if contains -- "$current" '@shader@' '@dither_shader@'
    set enabled on
end
if test $action = status
    if test "$current" = '@dither_shader@'
        echo 'on (dithered)'
    else
        echo $enabled
    end
    exit 0
end
if test $action = toggle
    if test $enabled = on
        set action off
    else
        set action on
    end
end
if not contains -- "$current" '@shader@' '@dither_shader@' '[[EMPTY]]' ''
    echo 'another screen shader is active; leaving it in place' >&2
    exit 1
end
set target ''
if test $action = on
    set target '@shader@'
else if test $action = dither
    set target '@dither_shader@'
end
if test "$current" = '[[EMPTY]]'
    set current ''
end
if test "$current" = "$target"
    printf 'vespers filter: %s\n' $action
    exit 0
end
set response (@hyprctl@ eval "hl.config({ decoration = { screen_shader = \"$target\" }, debug = { damage_tracking = 1 } }); hl.exec_scheduled_prop_refresh_immediately()")
or exit 1
if test (string trim -- "$response") != ok
    printf 'could not change the screen shader: %s\n' "$response" >&2
    exit 1
end
set updated (get_shader)
or exit 1
if test "$updated" = '[[EMPTY]]'
    set updated ''
end
if test "$updated" != "$target"
    echo 'the compositor did not apply the requested screen shader' >&2
    exit 1
end
printf 'vespers filter: %s\n' $action
