let
  users = {
    ltadeu6 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBitXAExTzEy48juhqlKANx/oYqnxpR7J6BCKsBXt8iH ltadeu6@nixos";
  };

  systems = {
    Nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBitXAExTzEy48juhqlKANx/oYqnxpR7J6BCKsBXt8iH ltadeu6@nixos";
  };
in {
  "secrets/openai_api_key.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/openclaw_gateway_token.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/minecraft_rcon_password.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/syncthing_pixel_id.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/syncthing_tv_id.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/wireguard_private_key.age".publicKeys = [ users.ltadeu6 systems.Nixos ];

  wireguard = {
    peerPublicKey = "SZa3sH9QzjuhAzSFDybLbOxr3UxwPzV3SaiNLaJIjz0=";
    endpoint = "vps32536.publiccloud.com.br:51820";
  };
}
