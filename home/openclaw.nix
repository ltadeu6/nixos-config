{ ... }:

{
  programs.openclaw = {
    enable = true;
    documents = ../openclaw/documents;
    instances.default = {
      enable = true;
      config = {
        gateway.mode = "local";
        gateway.auth.mode = "token";
        gateway.auth.token = {
          source = "env";
          provider = "default";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };
        gateway.remote.token = {
          source = "env";
          provider = "default";
          id = "OPENCLAW_GATEWAY_TOKEN";
        };

        agents.defaults.model.primary = "ollama/gemma4:e4b";
        models.providers.ollama = {
          baseUrl = "http://127.0.0.1:11434";
          api = "ollama";
          apiKey = "ollama-local";
          models = [ ];
        };
      };
    };
  };
}
