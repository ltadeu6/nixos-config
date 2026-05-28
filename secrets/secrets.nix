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
  "secrets/forgejo_api_token.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/android_release_keystore.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/android_release_store_password.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/android_release_key_password.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/matrix_android_firebase_service_account.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/matrix_android_google_services.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/matrix_android_commander_credentials.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/cloudflare_worker_api_token.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/cloudflare_dns_api_token.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/minecraft_rcon_password.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/oci_key.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
  "secrets/oci_config.age".publicKeys = [ users.ltadeu6 systems.Nixos ];
}
