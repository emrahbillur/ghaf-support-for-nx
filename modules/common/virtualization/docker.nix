# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{ lib, config, ... }:
let
  cfg = config.ghaf.virtualization.docker.daemon;
  inherit (lib) mkEnableOption mkIf;
in
{
  options.ghaf.virtualization.docker.daemon = {
    enable = mkEnableOption "Docker Daemon";
  };

  config = mkIf cfg.enable {
    # Just ensure containers are enabled by boot.
    boot.enableContainers = lib.mkForce true;

    # For CUDA support unfree libraries and CudaSupport should be set
    ghaf.development.cuda.enable = lib.mkForce true;

    # Docker Daemon Settings
    virtualisation.docker = {
      # To force Docker package version settings
      #package = pkgs.docker_26;

      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };

      # Container file and processor limits 
      # daemon.settings = {
      #   default-ulimits = {
      #       nofile = {
      #       Name = "nofile";
      #       Hard = 1024;
      #       Soft = 1024;
      #       };
      #       nproc = {
      #       Name = "nproc";
      #       Soft = 65536;
      #       Hard = 65536;
      #       };
      #     };
      #   };
    };

    # Enabling CDI NVIDIA devices in podman or docker (nvidia docker container)
    # For Orin devices this setting does not work as jetpack-nixos still does not support them.
    # jetpack-nixos uses enableNvidia = true; even though it is deprecated
    # For x86_64 the case is different it was introduced to be 
    # virtualisation.containers.cdi.dynamic.nvidia.enable = true;
    # but deprecated and changed to hardware.nvidia-container-toolkit.enable
    # We enable below setting if architecture ix x86_64 and if the video driver is nvidia set it true
    hardware.nvidia-container-toolkit.enable = lib.mkIf (
      config.nixpkgs.localSystem.isx86_64 && (builtins.elem "nvidia" config.services.xserver.videoDrivers)
    ) true;

    # Enable Opengl renamed to hardware.graphics.enable
    hardware.graphics.enable = lib.mkForce true;

    # Add user to docker group and dialout group for access to serial ports
    users.users."ghaf".extraGroups = [
      "docker"
      "dialout"
    ];
  };
}
