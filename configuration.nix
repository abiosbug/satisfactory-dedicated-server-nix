{
  # Server specific defaults, see https://nixos.org/manual/nixos/stable/
  

  # add user to allow persistent storage and run the docker container
  users.users.satisfactory = {
    isNormalUser = true;
    extraGroups = [ "docker" ];
  };

  # allow UDP ports needed
  networking.firewall.allowedUDPPorts = [ 15777 15000 7777 ];

  # enable docker
  virtualisation.docker.enable = true;

  # systemd service file to run the docker container - not 100% reliable :shrug:
  systemd.services.satisfactory = {
    description = "Satisfactory Dedicated Server";
    serviceConfig = {
      User = 1000; # Adjust to match the actual UID of the user created above
      Group = 100; # NixOS uses 100 for the "users" group
      TimeoutStartSec = 0;
      Restart = "always";
    };
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    preStart = ''
      mkdir -p /home/satisfactory/SatisfactoryDedicatedServer
      ${pkgs.docker}/bin/docker stop satisfactory-server 2>/dev/null
      ${pkgs.docker}/bin/docker rm satisfactory-server 2>/dev/null
      ${pkgs.docker}/bin/docker pull wolveix/satisfactory-server:latest
    '';
    script = ''
      ${pkgs.docker}/bin/docker run --rm --name=satisfactory-server \
      -h satisfactory-server -e MAXPLAYERS=10 -e PGID=100 -e STEAMBETA=false \
      -v /home/satisfactory/SatisfactoryDedicatedServer:/config -p 7777:7777/udp \
      -p 15000:15000/udp -p 15777:15777/udp wolveix/satisfactory-server:latest

    ''
  };
};
