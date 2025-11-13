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
    mkdir $project_name
    cd $project_name
    set -l flake_template $(load-flake-template haskell.nix)
    set flake_template $(string replace -a \"__project_name\" \"$project_name\" $flake_template)
    echo $flake_template > flake.nix
    echo "use flake" > .envrc
    git init
    git add -A
    direnv allow .
    nixfmt flake.nix
end
function load-flake-template -a flake_name
    echo $(cat /etc/nixos/flake-templates/$flake_name)
end
