{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/home/melk-vm/lab" = {
    device = "//192.168.1.190/sambashare";
    fsType = "cifs";
    options = [
      "prefixpath=Dr. Jiahu Wang"
      "credentials=/etc/samba/lab.credentials"
      "uid=1000" "gid=100" "forceuid" "forcegid"
      "file_mode=0600" "dir_mode=0700"
      "nosuid" "nodev" "_netdev" "nofail"
      "x-systemd.automount" "x-systemd.idle-timeout=300"
      "x-systemd.mount-timeout=15s" "x-systemd.device-timeout=5s"
    ];
  };
}
