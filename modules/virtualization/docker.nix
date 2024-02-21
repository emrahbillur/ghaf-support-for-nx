# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  config,
  ...
}: let
  cfg = config.ghaf.virtualization.docker.daemon;
in
  with lib; {
    options.ghaf.virtualization.docker.daemon = {
      enable = mkEnableOption "Docker Daemon";
    };

    config = mkIf cfg.enable {
      virtualisation = {
        ## The docker version 24 does not support CDI interface 
        ## So disable docker and use podman in docker compatibility mode.
        #docker = {
        #  enable = true;
        #  rootless = 
        #  {
        #    enable = true;
        #    setSocketVariable = true;
        #  };
        #};
        
        podman = {
          enable = true;
          
          # Create a `docker` alias for podman, to use it as a drop-in replacement
          dockerCompat = true;

          # Enabling CDI NVIDIA devices in podman 
          enableNvidia = true;

          # Required for containers under podman-compose to be able to talk to each other.
          defaultNetwork.settings.dns_enabled = true;
        };
      };
      # Enable Opengl
      hardware.opengl.enable = true;
    };
  }
