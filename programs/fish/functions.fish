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
    set -l flake-template $(load-flake-template)
    set flake-template $(replace-var project_name $project_name $flake-template)
    echo "use flake" > .envrc
    direnv allow .
    git init
end
function load-flake-template -a flake_name project_name
    echo $(cat /etc/nixos/flake-templates/$flake_name | string collect)
end
function replace-var -a var value input
    string replace \"\$$var\$\" $value $input
end
