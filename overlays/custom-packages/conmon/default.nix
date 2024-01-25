# Copyright 2022-2024 TII (SSRC) and the Ghaf contributors
# SPDX-License-Identifier: Apache-2.0

(final: prev:
  {
    conmon = prev.conmon.overrideAttrs (old: rec {
      #pname = "conmon-2.1.10";
      version = "2.1.10";

      src = builtins.fetchTarball {
        url = https://github.com/containers/conmon/archive/refs/tags/v2.1.10.tar.gz;
        sha256 = "sha256:0q4kn54pfgq1c2h00hkidagxrynkgq9nmm1ikgd9084njg3z4iar";
      };
    });
  }
)

