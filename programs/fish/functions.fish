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
    # only strip known archive extensions so version numbers survive
    set -f known_exts .tar .gz .tgz .bz2 .tbz .tbz2 .xz .txz .zst .tzst
    set -f file $file_name
    while contains (string lower (path extension $file)) $known_exts
        set -f file (path change-extension '' $file)
    end
    mkdir $file
    tar -xf $file_name -C ./$file
    and rm $file_name
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
function mp4togif
    if test (count $argv) -lt 1
        echo "Usage: mp4togif input.mp4 [output.gif]"
        return 1
    end

    set input $argv[1]

    if not test -f $input
        echo "File not found: $input"
        return 1
    end

    set stem (path change-extension "" -- (basename $input))
    set palette "/tmp/$stem-palette.png"

    if test (count $argv) -ge 2
        set output $argv[2]
    else
        set output (path change-extension ".gif" -- $input)
    end

    ffmpeg -i $input -vf "fps=15,scale=800:-1:flags=lanczos,palettegen" $palette
    or return 1

    ffmpeg -i $input -i $palette -lavfi "fps=15,scale=800:-1:flags=lanczos[x];[x][1:v]paletteuse" $output
end
function uncompress -a file_name
    if test -z "$file_name"; or not test -f "$file_name"
        echo "usage: uncompress <archive>"
        return 1
    end
    # only strip known archive extensions so version numbers survive,
    # demo-1.2.tar.gz should become demo-1.2 and not demo-1
    set -f known_exts .tar .gz .tgz .bz2 .tbz .tbz2 .xz .txz .zst .tzst .zip .jar .rar .7z
    set -f dir (path basename $file_name)
    while contains (string lower (path extension $dir)) $known_exts
        set -f dir (path change-extension '' $dir)
    end
    set -f inner (path change-extension '' (path basename $file_name))
    mkdir -p $dir
    switch (string lower $file_name)
        case '*.tar' '*.tar.gz' '*.tgz' '*.tar.bz2' '*.tbz' '*.tbz2' '*.tar.xz' '*.txz' '*.tar.zst' '*.tzst'
            tar -xf $file_name -C $dir
        case '*.zip' '*.jar'
            unzip -q $file_name -d $dir
        case '*.rar'
            unrar x -idq $file_name $dir/
        case '*.7z'
            7z x -bso0 -o$dir $file_name
        case '*.gz'
            gunzip -c $file_name > $dir/$inner
        case '*.bz2'
            bunzip2 -c $file_name > $dir/$inner
        case '*.xz'
            unxz -c $file_name > $dir/$inner
        case '*.zst'
            zstd -dqc $file_name > $dir/$inner
        case '*'
            echo "uncompress: no idea how to extract $file_name"
            rmdir $dir 2> /dev/null
            return 1
    end
    # keep the archive next to its contents instead of littering the cwd
    and mv $file_name $dir/
    or begin
        echo "uncompress: extraction failed"
        return 1
    end
end
complete -c uncompress -a '(__fish_complete_suffix .tar .tar.gz .tgz .tar.bz2 .tbz .tbz2 .tar.xz .txz .tar.zst .tzst .zip .jar .rar .7z .gz .bz2 .xz .zst)'
