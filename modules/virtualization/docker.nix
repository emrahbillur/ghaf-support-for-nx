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
      virtualisation.docker.enable = true;
      #Since nvidia docker is not supporting cdi it fails.
      #virtualisation.docker.enableNvidia = true;
      virtualisation.podman.enable = true;
      virtualisation.podman.enableNvidia = true;
      virtualisation.docker.rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  }
