# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0
{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.ghaf.hardware.nvidia.orin.agx;
in {
  options.ghaf.hardware.nvidia.orin.agx.enableNetvmWlanPCIPassthrough =
    lib.mkEnableOption
    "WLAN card PCI passthrough to NetVM";
  config = lib.mkIf cfg.enableNetvmWlanPCIPassthrough {
    # Orin AGX WLAN card PCI passthrough
    ghaf.hardware.nvidia.orin.enablePCIPassthroughCommon = true;

    ghaf.virtualization.microvm.netvm.extraModules = [
      {
        microvm.devices = [
          {
            bus = "pci";
            path = "0001:01:00.0";
          }
        ];
        environment.systemPackages = [ pkgs.networkmanager (lib.mkIf config.ghaf.profiles.debug.enable pkgs.tcpdump) ];
        networking = {
          # wireless is disabled because we use NetworkManager for wireless
          wireless.enable = lib.mkForce false;
          networkmanager = {
            enable = true;
            plugins = lib.mkForce [ ];
            unmanaged = [ "ethint0" ];
          };
        };
        environment = {
          # noXlibs=false; needed for NetworkManager stuff
          noXlibs = false;

          etc."NetworkManager/system-connections/Wifi-1.nmconnection" = {
            text = ''
              [connection]
              id=Wifi-1
              uuid=33679db6-4cde-11ee-be56-0242ac120002
              type=wifi
              [wifi]
              mode=infrastructure
              ssid=SSID_OF_NETWORK
              [wifi-security]
              key-mgmt=wpa-psk
              psk=WPA_PASSWORD
              [ipv4]
              method=auto
              [ipv6]
              method=disabled
              [proxy]
            '';
            mode = "0600";
          };
        };
      }
    ];


    boot.kernelPatches = [
      {
        name = "agx-pci-passthrough-patch";
        patch = ./pci-passthrough-agx-test.patch;
      }
    ];

    boot.kernelParams = [
      "vfio-pci.ids=10ec:c82f"
      "vfio_iommu_type1.allow_unsafe_interrupts=1"
    ];

    hardware.deviceTree = {
      enable = true;
      name = "tegra234-p3701-host-passthrough.dtb";
    };
  };
}
