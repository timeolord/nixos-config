function ghcl -a username repo_name
    set repo_link git@github.com:{$username}/{$repo_name}.git
    command git clone $repo_link
end
function gacp -a commit_message
    command git add -A
    command git commit -m $commit_message
    command git push
end
function cd -a dir
    if [ "dir" = "" ]
        builtin cd $HOME
    else
        builtin cd $dir
    end
    ls
end
function flakeinit -a project_name lang_name
    mkdir project_name
    cd project_name
    
    echo "use flake" > .envrc
    direnv allow .
    git init
end
function nix-eval -a nix_expression
    nix-instantiate --eval -E $nix_expression
end
