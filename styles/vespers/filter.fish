set action toggle
if test (count $argv) -gt 1
    echo 'usage: vespers_filter [on|off|toggle|status]' >&2
    exit 2
end
if test (count $argv) -eq 1
    set action $argv[1]
end
if not contains -- $action on off toggle status
    echo 'usage: vespers_filter [on|off|toggle|status]' >&2
    exit 2
end
set current (@hyprctl@ -j getoption decoration:screen_shader | @jq@ -er '.str')
or exit 1
set enabled off
if test "$current" = '@shader@'
    set enabled on
end
if test $action = status
    echo $enabled
    exit 0
end
if test $action = toggle
    if test $enabled = on
        set action off
    else
        set action on
    end
end
if not contains -- "$current" '@shader@' '[[EMPTY]]' ''
    echo 'another screen shader is active; leaving it in place' >&2
    exit 1
end
set target '[[EMPTY]]'
if test $action = on
    set target '@shader@'
end
@hyprctl@ keyword decoration:screen_shader "$target"
or exit 1
printf 'vespers filter: %s\n' $action
