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

    if test "$old_name" = "."; or test "$old_name" = ".."
        return 0
    end

    set -f new_name (string replace -a " - " "-" "$old_name")
    set -f new_name (string replace -ar '([[:upper:]]+)([[:upper:]][[:lower:]])' '$1-$2' "$new_name")
    set -f new_name (string replace -ar '([[:lower:][:digit:]])([[:upper:]])' '$1-$2' "$new_name")
    set -f new_name (string lower (string replace -a " " "-" "$new_name"))
    set -f new_name (string replace -a "_" "-" "$new_name")
    if test -d "$file_name"
        set -f new_name (string replace -a "." "-" "$new_name")
    end
    set -f new_name (string replace -ar -- "-+" "-" "$new_name")
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

function rnf
    set -f dir_name .
    set -f depth

    while test (count $argv) -gt 0
        switch $argv[1]
            case -d
                if test (count $argv) -lt 2
                    return 1
                end

                set depth $argv[2]
                set argv $argv[3..-1]
            case '*'
                set dir_name $argv[1]
                set argv $argv[2..-1]
        end
    end

    if not test -d "$dir_name"
        return 1
    end

    if test -n "$depth"
        if not string match -qr '^[0-9]+$' "$depth"
            return 1
        end

        set -f files (find "$dir_name" -maxdepth $depth -depth)
    else
        set -f files (find "$dir_name" -depth)
    end

    for file_name in $files
        rename-file "$file_name"
    end
end
