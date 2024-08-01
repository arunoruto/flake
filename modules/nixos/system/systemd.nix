{
  systemd.services.chrome-killer = {
     #wantedBy = [ "multi-user.target" ];
     #after = [ "final.target" ];
     wantedBy = [ "final.target" ];
     after = [ "final.target" ];
     description = "Kill chrome during shutdown";
     serviceConfig = {
       Type = "oneshot";
       #User = "mirza";
       #RemainAfterExit = true;
       #ExecStop = ''killall chrome'';
       ExecStart = ''/run/current-system/sw/bin/killall chrome'';
     };
  };
}
