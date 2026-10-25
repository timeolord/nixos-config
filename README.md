secrets setup on a new machine
==============================

the sops secrets in secrets/ are encrypted with an age key. the key itself
is stored in this repo at secrets/age-key.txt.age, wrapped with a passphrase,
so the repo is self contained. it has to land in two places, both decrypted
from the same wrapped key.

the system secret (the login password in config.nix) is decrypted before
user creation, before /home is mounted, so the key lives on the root
subvolume:

    sudo mkdir -p /var/lib/sops-nix
    age -d secrets/age-key.txt.age | sudo tee /var/lib/sops-nix/key.txt > /dev/null
    sudo chmod 400 /var/lib/sops-nix/key.txt

home manager secrets (the ssh private key and the steam activitywatch
configuration) are decrypted as the user, so the key also goes in the home
config dir:

    mkdir -p ~/.config/sops/age
    age -d secrets/age-key.txt.age > ~/.config/sops/age/keys.txt

type the passphrase when prompted. after that every encrypted secret in the
repo can be decrypted on this machine, and rebuilds will place them where they
belong.

never commit either plaintext key (/var/lib/sops-nix/key.txt or
~/.config/sops/age/keys.txt) to the repo.

editing secrets
===============

run from the repo root so .sops.yaml is picked up:

    sops secrets/aw-watcher-steam.toml

adding a new secret: create the file under secrets/ with sops, then declare
it with sops.secrets in the relevant module (see programs/activitywatch.nix
for an example).

user password
=============

the login password is declarative (users.mutableUsers = false), so passwd
changes get reverted on rebuild. to change the password for real:

    mkpasswd -m yescrypt | tr -d '\n' > secrets/user-password
    sops encrypt --in-place secrets/user-password

then rebuild. root has no password of its own, use sudo from the wheel group.

ssh keys
========

the ssh keypair is declarative: the public key sits in programs/ssh/ and the
private key is encrypted at secrets/id_rsa. home manager places it at
~/.ssh/id_rsa with mode 0400, using ~/.config/sops/age/keys.txt to decrypt it.
on a new machine clone this repo over https first (it is public), restore
the age key as above, then rebuild to get the ssh key back.

configuration layout
====================

flake.nix builds four x86_64-linux systems. the hostname and username are
the same on each machine:

    melk-pc      amd, nvidia, btrfs root and home, snapper
    melkmobile  amd, nvidia, ext4 root, lid switches ignored
    melk-lab    intel, nvidia, ext4 root
    melktogo    intel, ext4 root, swap partition

config.nix holds shared system settings and home.nix holds shared home
manager settings. each host adds <host>.nix and its matching
hardware-configuration-<host>.nix. application modules live in programs/.

hyprland/hyprland.nix sets up ly, hyprland, and input methods. home manager
combines hyprland/hyprland.lua with hyprland/<host>.lua for the desktop
configuration. the same directory holds kitty, waybar, dunst, fuzzel,
hyprpaper, and the power menu settings.

packages come from nixos-unstable with emacs and godsays overlays. the
hyprland and plugin inputs are present in the flake, but the system module
currently uses the nixpkgs hyprland package. flake.lock records the pins.

flake.nix also pins peewee to 3.18.3 for activitywatch's aw-core dependency,
which still requires version 3. other packages keep the nixpkgs version.
the same overlay fixes mozc's widget class name for qt, the aw-qt wrapper
argument list, and compiles audacity's extensions qml module separately
to avoid a type name collision
with generated qt code.

building and rebuilding
=======================

run nix flake update to update all inputs, including godsays, to their latest
upstream revisions. to update only godsays:

    nix flake update godsays-flake

rebuild afterward to install the updated packages. rb uses the repository's
lockfile and does not update inputs itself.

build a system without activating it, replacing melkmobile with the host:

    nix build --no-link --no-write-lock-file .#nixosConfigurations.melkmobile.config.system.build.toplevel

switch to it when ready:

    sudo nixos-rebuild switch --flake /etc/nixos#melkmobile

rebuild.sh, also available as rb in fish, first checks that both age keys
can decrypt their configured secrets. if either key is missing or invalid,
it asks to decrypt secrets/age-key.txt.age with your passphrase and restores
the affected key with mode 0400. declining or failing decryption stops the
rebuild. it checks again after pulling in case the secrets changed.

it pulls the repo, switches the configuration for $USER, then stages all changes, commits,
and pushes on success. if the switch fails it retries with --show-trace.

each host also has an installer image output, built without its hardware
module:

    nix build .#melkmobile-iso

the root flake has no development shell. flake-templates/ holds haskell
and python project flakes used by the fish flakeinit function, which also
creates .envrc with use flake and git pull.

upstream development builds
===========================

the system flake includes these upstream inputs for access to development
builds. each stays pinned until its input is updated in flake.lock.

| input | source | package output |
| --- | --- | --- |
| rust-overlay | https://github.com/oxalica/rust-overlay | rust-nightly |
| zig-overlay | https://github.com/mitchellh/zig-overlay | zig-nightly |
| haskell-nix | https://github.com/input-output-hk/haskell.nix | ghc-development |
| codex | https://github.com/sadjow/codex-cli-nix | codex-latest |

rust selects the latest nightly with the default components and rust-src
available. zig uses the upstream master binary. haskell selects the ghc915
development compiler from haskell.nix's own package set, currently the pinned
9.15.20260204 snapshot. the codex input checks
hourly for released binaries; codex-latest provides the release at the pinned
revision, rather than a nightly build.

haskell.nix may fetch sources and build planning tools during evaluation.

use them directly from this repository:

    nix shell .#rust-nightly
    nix shell .#zig-nightly
    nix shell .#ghc-development
    nix run .#codex-latest

update just these inputs with:

    nix flake update rust-overlay zig-overlay haskell-nix codex

modules can also use the inputs argument to select other versions. haskell.nix
keeps its own nixpkgs pin and overlay separate from the system package set.
these outputs do not install development builds into the normal user profile.

style profiles
==============

Stylix manages the shared palette, fonts, cursor, opacity, and wallpaper.
styles/selected.nix contains the default profile name, currently "vespers".
a host can override it with style.name = "current"; in its host module.
profile selection takes effect through a normal system rebuild.

styles/current.nix preserves the existing purple and pink desktop, Ivan the
Terrible wallpaper, Sonic cursor, Catppuccin Mocha Blue GTK and Kvantum,
Kitty colors and transparency, and Doom One in Emacs. the application
exceptions live in this profile, so they do not carry into another profile.

styles/vespers.nix is the Victorian inspired alternative. it combines walnut
browns, antique gold, ivory and marble whites, Terminus pixel text, Cinzel
headings, and EB Garamond for prose. it changes the floating Waybar frame,
window spacing and borders, animations, launcher, notifications, terminal,
Emacs, GTK, Qt, shell colors and prompt, and power menu. the VESPERAE label
has the tooltip Ad maiorem Dei gloriam. the system language stays unchanged.

Ly also follows Vespers, with a static walnut background, ivory text, gold
frame, VESPERAE title, and AD MAIOREM DEI GLORIAM motto. Linux virtual
consoles use the matching palette and a larger 24 pixel Terminus font.
Waybar writes full Latin month names, such as 25 Octobris 2026, using the
local system timezone. the clock remains in 24 hour format.

the interface takes cues from NES.css and System.css: flat opaque panels,
square geometry, double gold frames, a small pixel cross, compact controls,
and inverted gold selections. Terminus is rendered without antialiasing;
Cinzel and Garamond retain their normal rendering. compositor shadows,
blur, border gradients, and animations are disabled. GTK controls and the
power menu have square edges without gradients or shadows. the Qt theme
uses a build time SVG transform to flatten gradient stops, remove rounded
rectangle corners and filters, and request crisp edges, with Kvantum popup
shadows, blurring, and opacity reduction disabled. painting scans are kept
unchanged. these references inspired the design; no web CSS library is
installed as a dependency:

https://nostalgic-css.github.io/NES.css/
https://sakofchit.github.io/system.css/

Waybar shows workspaces I through X and uses Latin names for input methods:
ANGLICA, GALLICA, SINICA, IAPONICA, and TURCICA. the same input methods and
switching shortcuts are retained. use style.name = "vespers"; in a host
module to select it independently, or edit styles/selected.nix for all hosts.
set the selection to "current" and rebuild to restore the previous style.

vespers uses the original 4000 × 2563 scan of Friedrich's The Abbey in the
Oakwood. an alternative 3518 × 4801 Granet scan of The Choir in the Capuchin
Church on the Piazza Barberini, Rome is also included. change stylix.image
in styles/vespers.nix to ../wallpapers/choir_of_the_capuchin_church.jpg to use
it; its portrait composition suits a portrait monitor better than a wide
screen. wallpapers/README.md records the sources and attribution. neither
painting was generated, recolored, or upscaled.

styles/default.nix registers profiles and enables selected Stylix targets.
Hyprland uses a custom palette adapter for its Lua configuration. Waybar,
Fuzzel, and Dunst also consume the Stylix palette while keeping their layouts
and existing application specific transparency. automatic theming of other
programs is disabled; enable additional targets explicitly when wanted.
new profiles get generated GTK, Qt, Kitty, and Emacs themes and a Bibata
cursor unless they override those settings.

for example, add styles/mocha.nix:

    { config, lib, pkgs, ... }:
    {
      config = lib.mkIf (config.style.name == "mocha") {
        stylix = {
          image = ../wallpapers/ivan_the_terrible.jpg;
          base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
          polarity = "dark";
          opacity.terminal = 0.9;
        };
      };
    }

add mocha = ./mocha.nix; to the profiles attribute set in styles/default.nix,
then change styles/selected.nix to contain just "mocha". each profile must
conditionally apply its settings as above and provide an image and palette.
keep application exceptions inside the corresponding conditional profile.

include new files in the git source set and rebuild, using your hostname:

    git add styles
    sudo nixos-rebuild switch --flake .#melkmobile

change the selection back to "current" and rebuild to restore this style.
log out and back in after switching so running applications and the Emacs
daemon load the new configuration. this is declarative switching through
rebuilds, rather than an immediate runtime theme toggle.

Stylix follows the system nixpkgs input. existing input revisions were kept
when adding it. future updates should update Stylix, nixpkgs, and Home
Manager together for compatibility, as described in the upstream docs:
https://nix-community.github.io/stylix/installation.html

language input
==============

fcitx handles english, french, chinese pinyin, japanese mozc, and turkish.
french uses us international qwerty with dead keys for accents, so typing
' followed by e gives é. turkish uses the turkish q layout. pinyin and
mozc use the us layout for phonetic input.

super space cycles forward and super shift space cycles backward. the
waybar language indicator shows the active input method in chinese and
updates every second. left click or scroll up cycles forward, and right
click or scroll down cycles backward. the selection is shared across apps.
fcitx's clipboard shortcut is cleared so emacs can receive control semicolon.

rebuild and log out and back in to load the new addons and settings.

settings and data sync
======================

home manager runs git-sync for ~/notes, ~/language-learning,
~/activity-data, and ~/website. clone these repos before the first
activation: their pre commit hooks are installed inside .git/hooks.
the hook unstages files over 50 mib and adds them to .git/info/exclude so
they do not block future syncs.

activitywatch starts with the graphical session. awatcher tracks wayland
activity, the steam watcher uses its encrypted configuration, and mpv has
a logger and sender. aw-sync waits for ~/activity-data/.git before
exporting into that repo. emacs also reports through activity-watch-mode.

the aspell personal dictionary is merged with programs/aspell/en.pws on
activation. a user service watches local changes and merges new words
back into this repo, keeping words from both copies.

strawberry uses programs/strawberry/strawberry.conf. activation copies it
to the user's config as a writable file, and a user service copies local
changes back into the repo. the repo copy wins on rebuild. the separate
programs/strawberry.conf is not used by the module.

these services can change tracked files while the desktop is running.
config.nix reapplies user and default acls on /etc/nixos during activation
so they can write here without sudo.

btrfs subvolumes (melk-pc)
==========================

the pool (uuid 850071b5-beef-4929-8fa4-3b88433f9316) uses these subvolumes,
mounted in hardware-configuration-melk-pc.nix:

    @           /
    @home       /home
    @nix        /nix          (kept out of snapshots, heavy churn)
    @log        /var/log      (kept out of snapshots)
    @snapshots  /.snapshots   (holds the root snapshots)

nix and log are separate subvolumes so they are never dragged into a root
snapshot. the original flat data still lives in the top level (subvolid=5)
as a rollback until it is reclaimed.

the system age key lives at /var/lib/sops-nix/key.txt (on @, mounted in the
initrd) rather than in /home, because sops decrypts the login password during
early boot before /home is mounted. if you ever move it back into a home dir
the login will break on a subvolume layout.

automatic snapshots
===================

snapper is configured in melk-pc.nix for the root and home subvolumes. a
timeline snapshot is taken every minute and cleanup thins it down:

    everything from the last hour is kept (min age 3600)
    then hourly for a day
    then 7 daily (a week)
    then 4 weekly

the timeline timer is persistent and cleanup runs every 10 minutes.
monthly and yearly retention are disabled.

snapshots are cow so a minute with no changes costs next to nothing. the
knobs are TIMELINE_LIMIT_HOURLY / DAILY / WEEKLY / MONTHLY. home snapshots
need /home/.snapshots to exist (btrfs subvolume create /home/.snapshots).

restoring from a snapshot
=========================

snapshots are read only at /.snapshots/<n>/snapshot and
/home/.snapshots/<n>/snapshot. list and inspect them:

    snapper -c home list
    snapper -c home status 42..0
    snapper -c home diff 42..0 /home/melk-pc/notes.txt

restoring individual files, the common case, works live:

    cp -a --reflink=auto /home/.snapshots/42/snapshot/melk-pc/notes.txt ~/notes.txt
    sudo snapper -c home undochange 42..0 /home/melk-pc/project

undochange n..0 reapplies snapshot n onto the live filesystem (modified,
deleted and new files). drop the path to revert everything the config covers.

rolling back a whole subvolume is manual: snapper rollback flips the btrfs
default subvolume but fstab pins subvol=@, so it has no effect here. do it
from a live usb (root cannot replace itself while mounted). for root:

    mount -o subvolid=5 /dev/disk/by-uuid/850071b5-beef-4929-8fa4-3b88433f9316 /mnt
    mv /mnt/@ /mnt/@.broken
    btrfs subvolume snapshot /mnt/@snapshots/<n>/snapshot /mnt/@
    umount /mnt && reboot

for home the snapshots are nested inside @home and snapper needs its
.snapshots back afterward:

    mount -o subvolid=5 /dev/disk/by-uuid/850071b5-beef-4929-8fa4-3b88433f9316 /mnt
    mv /mnt/@home /mnt/@home.broken
    btrfs subvolume snapshot /mnt/@home.broken/.snapshots/<n>/snapshot /mnt/@home
    btrfs subvolume create /mnt/@home/.snapshots
    umount /mnt && reboot

snapshotting a read only snapshot gives a fresh writable subvolume that fstab
mounts on boot. keep the .broken one until the restore is confirmed, then
delete it with btrfs subvolume delete.
