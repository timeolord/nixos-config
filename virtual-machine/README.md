# Windows hosted NixOS

`nixosConfigurations.melk-vm` uses the same system, Home Manager, application,
Hyprland, and selected style modules as the physical machines. It is a separate
host output, so the four existing hosts and their ISO outputs stay independent.

`hardware-configuration-melk-vm.nix` describes a QEMU virtio disk labelled
`nixos`. The VM uses BIOS GRUB, a swap file, and compressed memory swap. The
Windows launcher uses WHPX CPU acceleration and a VirGL virtual GPU with the
GTK display backend. SDL OpenGL hung on this host; GTK successfully exposed the
Intel UHD Graphics 620 renderer to Hyprland. It requires
the existing Windows hypervisor to be available to the account.

The portable installation, virtual disk, launchers, and logs live in
`C:\Users\MelodyWei\projects\nixos-vm`. The desktop shortcut opens the VM
full-screen. It does not run at Windows sign-in. Windows still owns the physical
hardware and login session.

VM specific differences are contained in `default.nix` and `hyprland/melk-vm.lua`:

* greetd starts the existing desktop with `start-hyprland`, which supervises the
  capability-enabled `/run/wrappers/bin/Hyprland` through its watchdog
* greetd waits for the escaped Home Manager service name before starting login
* the VM account is `melk-vm`, with fish as its login shell and no local password
* SSH uses the VM host's dedicated key and accepts no password logins
* the original encrypted login password is not restored
* home manager restores the original private SSH identity and Steam watcher
  secret through sops and syncs the four home repositories
* the Steam watcher and activity data export wait for their required files
* Audacity is omitted initially to avoid compiling the custom patched version
* the fish greeting keeps its information display without deleting directories
* Kitty uses 24 point Unicode VGA so its 16 pixel design doubles cleanly at
  96 DPI; the other desktop font sizes remain at 21 points
* `rb` uses the shared helper to pull, rebuild, commit and push; it checks home
  secrets, skips the unused system login key, and builds the VM with a path flake
* Firefox, Discord and Signal stay installed and launch manually
* the VM light session skips the duplicate direct wallpaper launch and Bluetooth
  applet; Home Manager still manages the wallpaper, and animations are disabled
* the Vespers screen filter defaults to off with partial redraws; Super+Shift+F12
  or `vespers_filter dither` can still enable it manually
* Nix builds run one job with four cores, and btrfs scrubbing is disabled on ext4

The Windows launcher allocates 4096 MB RAM and four virtual CPUs, with a dedicated
virtio disk I/O thread. The host has eight logical processors and about 8 GB RAM.
The shared Hyprland startup callback checks `vm_light_session`, set only by
`hyprland/melk-vm.lua`; the physical hosts retain their personal app startup.

Audio uses SDL playback and an output-only virtual HDA card because the Windows
DirectSound backend failed when opening an unavailable microphone. A silent
PipeWire playback test passed; microphone capture is not configured.

An optional, git ignored `access.nix` provides the local public SSH key. The
private key stays outside the repository. Local login and sudo are passwordless;
rebuilding reapplies the empty local password. Its initial state version is 26.05.

Inside the VM, edit `/etc/nixos` and run:

```fish
sudo nixos-rebuild switch --flake path:/etc/nixos#melk-vm --no-write-lock-file
```

Before the first rebuild with sync enabled, run this as `melk-vm`:

```fish
fish --no-config /etc/nixos/virtual-machine/restore-sync.fish
```

Enter the age passphrase in the terminal when prompted. This restores the age
identity under `~/.config/sops/age` and decrypts the SSH key without printing it,
clones the four repositories, then rebuilds. Verify GitHub's host fingerprint
before accepting its first connection prompt. Existing keys and clones are
preserved; a nonempty destination that is not a clone stops the bootstrap.
Home Manager owns the SSH key and repository hooks after activation. The system
login secret stays disabled, so no system age key is needed for this VM.

The Windows and guest source directories are separate Git copies. The guest
retains the original history and its VM changes remain uncommitted. Changes are not
automatically synchronized between Windows and the guest. Running `rb` in the
guest publishes its changes to GitHub after a successful rebuild. The deployment uses a path
flake so newly created files are included without a git staging requirement.

Networking uses user mode NAT with guest SSH forwarded to Windows loopback
port 2222. The QEMU management, serial, and guest agent ports also bind only to
loopback. No Windows firewall rules or virtual network drivers are installed.
