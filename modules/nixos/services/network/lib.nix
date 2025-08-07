lib: {
  traefikConfig =
    {
      serviceName,
      url,
      port,
      path ? "/",
      cert ? "cf",
    }:
    let
      host =
        if (builtins.isList url) then
          lib.strings.concatStringsSep " || " (lib.lists.forEach url (x: "Host(`${x}`)"))
        else
          "Host(`${url}`)";
    in
    {
      http = {
        routers."${serviceName}" = {
          rule = "(${host}) && PathPrefix(`${path}`)";
          tls.certresolver = cert;
          entrypoints = [ "websecure" ];
          service = serviceName;
        };
        services."${serviceName}".loadbalancer.servers = [
          {
            url = "http://localhost:${builtins.toString port}";
          }
        ];
      };
    };
}
