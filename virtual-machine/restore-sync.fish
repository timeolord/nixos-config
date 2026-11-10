#!/usr/bin/env fish

function restore_sync
    test (id -un) = melk-vm; or return 1
    cd /etc/nixos; or return 1
    umask 077
    set -l key_dir $HOME/.config/sops/age
    mkdir -p $key_dir $HOME/.ssh; or return 1
    if not test -s $key_dir/keys.txt
        set -l key_temp (mktemp $key_dir/restore.XXXXXX); or return 1
        if not age --decrypt secrets/age-key.txt.age > $key_temp
            rm -f $key_temp
            return 1
        end
        mv $key_temp $key_dir/keys.txt; or return 1
    end
    if not test -e $HOME/.ssh/id_rsa
        set -l ssh_temp (mktemp $HOME/.ssh/restore.XXXXXX); or return 1
        if not env SOPS_AGE_KEY_FILE=$key_dir/keys.txt sops --decrypt --input-type binary --output-type binary secrets/id_rsa > $ssh_temp
            rm -f $ssh_temp
            return 1
        end
        chmod 400 $ssh_temp; or return 1
        mv $ssh_temp $HOME/.ssh/id_rsa; or return 1
    end
    for repo in notes language-learning activity-data website
        set -l remote $repo
        if test $repo = website
            set remote timeolord.github.io
        end
        if not test -d $HOME/$repo/.git
            git clone git@github.com:timeolord/$remote.git $HOME/$repo; or return 1
        end
    end
    sudo nixos-rebuild switch --flake path:/etc/nixos#melk-vm --no-write-lock-file
end

restore_sync
