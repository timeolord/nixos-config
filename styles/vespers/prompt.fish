function fish_prompt
    set -l last_status $status
    printf '\n%s%s%s' (set_color @base0D@) (prompt_pwd) (set_color normal)
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        printf ' %s%s%s' (set_color @base04@) (git branch --show-current 2>/dev/null) (set_color normal)
    end
    if test $last_status -ne 0
        printf ' %s[%s]%s' (set_color @base08@) $last_status (set_color normal)
    end
    printf '\n%s❯%s ' (set_color @base0A@) (set_color normal)
end
