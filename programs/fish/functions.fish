function ghcl -a username repo_name
    set repo_link git@github.com:{$username}/{$repo_name}.git
    command git clone $repo_link
end
