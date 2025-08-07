{ config, lib, ... }:
{
  config = lib.mkIf config.services.pocket-id.eanble {
    servies.pocket-id = {

    };
  };
}
