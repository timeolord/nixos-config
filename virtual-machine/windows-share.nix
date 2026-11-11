{ lib, pkgs, ... }:
let
  mountPoint = "/home/melk-vm/shared";
  options = lib.concatStringsSep "," [
    "ssh_command=${pkgs.openssh}/bin/ssh"
    "IdentityFile=/var/lib/windows-share/id_ed25519"
    "UserKnownHostsFile=/var/lib/windows-share/known_hosts"
    "StrictHostKeyChecking=yes" "IdentitiesOnly=yes" "BatchMode=yes"
    "ConnectTimeout=5" "ServerAliveInterval=5" "ServerAliveCountMax=2"
    "reconnect" "allow_other" "default_permissions"
    "uid=1000" "gid=100" "umask=0077" "dir_cache=no"
  ];
in
{
  systemd.tmpfiles.rules = [ "d ${mountPoint} 0755 melk-vm users -" ];
  systemd.services.windows-share = {
    description = "Mount the Windows shared folder";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "systemd-tmpfiles-setup.service" ];
    unitConfig.StartLimitIntervalSec = 0;
    serviceConfig = {
      ExecStart = "${pkgs.sshfs}/bin/sshfs -f -p 45903 -o ${options} shared@10.0.2.2:/ ${mountPoint}";
      ExecStop = "-${pkgs.util-linux}/bin/umount -l ${mountPoint}";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
