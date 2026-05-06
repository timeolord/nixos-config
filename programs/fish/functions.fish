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
    rm $file_name
end
function rename-file -a file_name
    if test -z "$file_name"; or not test -e "$file_name"
        return 1
    end

    set -f parent (path dirname "$file_name")
    set -f old_name (path basename "$file_name")
    set -f new_name (string lower (string replace -a " " "_" "$old_name"))
    set -f new_path "$parent/$new_name"

    if test "$file_name" = "$new_path"; or test "$old_name" = "$new_name"
        return 0
    end

    if test -e "$new_path"
        echo "rename-file: $new_path already exists"
        return 1
    end

    mv "$file_name" "$new_path"
end

function rnf -a dir_name
    if test -z "$dir_name"
        set dir_name .
    end

    if not test -d "$dir_name"
        return 1
    end

    for file_name in (find "$dir_name" -depth)
        rename-file "$file_name"
    end
end
