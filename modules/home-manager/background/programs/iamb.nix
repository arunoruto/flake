{ config, lib, ... }:
{
  config = lib.mkIf config.programs.iamb.enable {
    programs.iamb.settings = {
      profiles = {
        private = {
          user_id = "@arunoruto:matrix.org";
        };
        work = {
          user_id = "@mar:matrix.bv.e-technik.tu-dortmund.de";
        };
      };
    };
  };
}
