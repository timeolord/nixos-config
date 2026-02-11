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
    switch $lang_name
        case haskell
            set -f flake_template $(load-flake-template haskell.nix)
        case python
            set -f flake_template $(load-flake-template python.nix)
        case '*'
            echo "Invalid Language"
            cd ..
            rm -rf $project_name
            return 1
    end
    set flake_template $(string replace -a \"__project_name\" \"$project_name\" $flake_template)
    echo $flake_template > flake.nix
    echo "use flake\n git pull" > .envrc
    echo ".direnv" > .gitignore
    git init
    git add -A
    direnv allow .
    nixfmt flake.nix
end
function load-flake-template -a flake_name
    echo $(cat /etc/nixos/flake-templates/$flake_name)
end
function cd
    builtin cd $argv
    and ls
end
function untar -a file_name
    set -f file $file_name
    while path extension $file &> /dev/null
        set -f file (path change-extension '' $file)
    end
    mkdir $file
    tar -xf $file_name -C ./$file
    rm $file_name
end
function guntar -a file_name
    gunzip $file_name
    set -f file (path change-extension '' $file_name)
    untar $file
end
function u7z -a file_name
    7z x $file_name
end

function rename-file -a file_name
    mv $file_name (string join "" (generate-new-name (path change-extension '' $file_name)) (path extension $file_name))
end
function generate-new-name -a name
    set -f new_name (string replace -a "_" "-" $name)
    set -f new_name (string replace -a " " "-" $new_name)
    set -f new_name (string replace -a "." "-" $new_name)
    set -f new_name (string lower $new_name)
    echo $new_name
end
function rename-folder -a folder_name
    mv $file_name (generate-new-name $folder_name)
end
function rnf
    set -f files (ls -p | grep -v /)
    set -f folders (ls -d */)
    for folder in $folders
        rename-folder $folder
    end
    for file in $files
        rename-file $file
    end
end
