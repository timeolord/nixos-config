#!/usr/bin/env fish

function check_secrets -a key_file
    test -s "$key_file"; or return 1
    age-keygen -y "$key_file" >/dev/null 2>&1; or return 1
    for secret in $argv[2..]
        env -u SOPS_AGE_KEY -u SOPS_AGE_KEY_CMD XDG_CONFIG_HOME=/dev/null SOPS_AGE_KEY_FILE="$key_file" \
            sops decrypt --input-type binary --output-type binary "$secret" >/dev/null 2>&1; or return 1
    end
end

function ensure_keys
    set -l system_key /var/lib/sops-nix/key.txt
    set -l home_key "$HOME/.config/sops/age/keys.txt"
    set -l sops_bin (command -s sops)
    set -l age_keygen_bin (command -s age-keygen)
    set -l system_ready 0
    set -l home_ready 0

    if sudo test -s "$system_key"; and sudo "$age_keygen_bin" -y "$system_key" >/dev/null 2>&1
        if sudo env -u SOPS_AGE_KEY -u SOPS_AGE_KEY_CMD XDG_CONFIG_HOME=/dev/null SOPS_AGE_KEY_FILE="$system_key" \
                "$sops_bin" decrypt --input-type binary --output-type binary secrets/user-password >/dev/null 2>&1
            set system_ready 1
        end
    end
    if check_secrets "$home_key" secrets/id_rsa secrets/aw-watcher-steam.toml
        set home_ready 1
    end
    if test $system_ready -eq 1; and test $home_ready -eq 1
        return 0
    end

    echo "age keys are missing or cannot decrypt the configured secrets."
    read -l -P "decrypt secrets/age-key.txt.age and restore the keys? [y/N] " answer; or return 1
    contains -- "$answer" y Y yes YES; or return 1

    set -g key_dir (mktemp -d); or return 1
    chmod 700 "$key_dir"; or return 1
    age --decrypt --output "$key_dir/key" secrets/age-key.txt.age; or return 1
    chmod 600 "$key_dir/key"; or return 1
    if not check_secrets "$key_dir/key" secrets/user-password secrets/id_rsa secrets/aw-watcher-steam.toml
        echo "the restored key cannot decrypt all configured secrets." >&2
        return 1
    end

    if test $system_ready -eq 0
        sudo install -d -m 700 /var/lib/sops-nix; or return 1
        sudo install -m 400 "$key_dir/key" "$system_key"; or return 1
    end
    if test $home_ready -eq 0
        install -d -m 700 "$HOME/.config/sops/age"; or return 1
        install -m 400 "$key_dir/key" "$home_key"; or return 1
    end
    rm -f -- "$key_dir/key"
    rmdir -- "$key_dir"
    set -e key_dir
    ensure_keys
end

function cleanup_keys --on-event fish_exit
    if set -q key_dir; and test -n "$key_dir"
        rm -f -- "$key_dir/key"
        rmdir -- "$key_dir"
    end
end

function main
    cd /etc/nixos; or return 1
    for dependency in age age-keygen sops
        command -q "$dependency"; or begin
            echo "missing dependency: $dependency" >&2
            return 1
        end
    end
    ensure_keys; or return 1
    git pull; or return 1
    ensure_keys; or return 1
    if sudo nixos-rebuild switch --flake "/etc/nixos#$USER"
        git add -A; or return 1
        git commit -m "updated configs"; or return 1
        git push
    else
        sudo nixos-rebuild switch --flake "/etc/nixos#$USER" --show-trace
        set -l rebuild_status $status
        git status
        return $rebuild_status
    end
end

main
exit $status
