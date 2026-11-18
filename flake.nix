{
  description = "Experimental Roblox compatibility runtime for Linux and FreeBSD";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [

      ];
      systems = [
        "x86_64-linux"
        # "aarch64-linux"
        # "aarch64-darwin"
        # "x86_64-darwin"
      ];
      perSystem =
        {
          pkgs,
          ...
        }:
        let
          package = pkgs.callPackage ./packaging/nix/package.nix { };
        in
        {
          packages.default = package;
          packages.mocktail = package;
          packages.nightcap = package;

          apps.default = {
            type = "app";
            program = "${package}/bin/nightcap";
          };
          apps.vr = {
            type = "app";
            program = "${package}/bin/nightcap-vr";
          };
          apps.desktop = {
            type = "app";
            program = "${package}/bin/nightcap-desktop";
          };

          devShells.default = pkgs.mkShell {
            inputsFrom = [ package ];

            # nixpkgs installs the header we need under include/libutf8proc
            NIX_CFLAGS_COMPILE = "-I${pkgs.libutf8proc}/include/libutf8proc";

            nativeBuildInputs = with pkgs; [
              cmake
              git
              lld
              ninja
              pkg-config
              vulkan-headers

              llvmPackages_22.clang-tools
              llvmPackages_22.libclang

              # debugging
              gdb
            ];

            desktopItems = [
              (pkgs.makeDesktopItem {
                name = "Mocktail";
                exec = "mocktail";
                icon = "mocktail";
                desktopName = "Mocktail";
                comment = "Experimental Roblox compatibility runtime for Linux and FreeBSD";
                categories = [ "Game" ];
              })
            ];

            shellHook = ''
              export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath package.buildInputs}:/run/opengl-driver/lib"
              export GIO_EXTRA_MODULES="${pkgs.glib-networking}/lib/gio/modules"
              export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"

              if [ -f /run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json ]; then
                export VK_DRIVER_FILES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
                export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
              fi

              # nix packages graphics drivers differently, and mocktail will still work if it cannot guarantee symbols
              export MOCKTAIL_REQUIRE_REAL_GRAPHICS=0
            '';
          };
        };
      flake = {
        overlays.default = final: prev: {
          nightcap = final.callPackage ./packaging/nix/package.nix { };
          mocktail = final.nightcap;
        };
      };
    };
}
