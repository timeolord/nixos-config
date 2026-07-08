{ config, ... }:
{
  # public key is not secret, so it lives in the repo as plain text
  home.file.".ssh/id_rsa.pub".source = ./id_rsa.pub;

  # private key stays encrypted in the repo and gets decrypted on activation
  sops.secrets.id_rsa = {
    format = "binary";
    sopsFile = ../../secrets/id_rsa;
    path = "${config.home.homeDirectory}/.ssh/id_rsa";
    mode = "0400";
  };
}
