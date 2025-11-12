function ghcl -a username repo_name
    set repo_link git@github.com:{$username}/{$repo_name}.git
    command git clone $repo_link
end
function gaup -a commit_message
    command git add -a
    command commit -m $commit_message
end
