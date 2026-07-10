secrets setup on a new machine
==============================

the sops secrets in secrets/ are encrypted with an age key. the key itself
is stored in this repo at secrets/age-key.txt.age, wrapped with a passphrase,
so the repo is self contained. to restore it on a new machine:

    mkdir -p ~/.config/sops/age
    age -d secrets/age-key.txt.age > ~/.config/sops/age/keys.txt

type the passphrase when prompted. after that every encrypted secret in the
repo can be decrypted on this machine, and rebuilds will place them where
they belong.

never commit ~/.config/sops/age/keys.txt (the plaintext key) to the repo.

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
private key is encrypted at secrets/id_rsa, placed at ~/.ssh/id_rsa on
rebuild. on a new machine clone this repo over https first (it is public),
restore the age key as above, then rebuild to get the ssh key back.

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
    then weekly

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
