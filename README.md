# Nightcap Nix (VR & Desktop)

<div align="center">
  <img src="https://raw.githubusercontent.com/CoderDayton/nightcap/main/packaging/io.github.CoderDayton.nightcap.svg" alt="Nightcap logo" width="128">
  <h1 style="margin-top: 5px;">
    Nightcap Nix
    <br>
    <a href="https://github.com/rimemist/nightcap-nix"><img src="https://img.shields.io/badge/Nix_Flake-ready-blue?logo=nixos" alt="Nix Flake"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-Apache--2.0-blue.svg" alt="License"></a>
    <a href="https://github.com/CoderDayton/nightcap"><img src="https://img.shields.io/badge/upstream-CoderDayton%2Fnightcap-orange.svg" alt="Upstream"></a>
  </h1>
  <p>
    Nix Flake and NixOS packaging for <b>Nightcap</b> with OpenXR VR (WiVRn / SteamVR) and Desktop support.
  </p>
</div>

Nightcap runs the Roblox Android `x86_64` client on Linux using an internal compatibility layer connected to SDL3, Vulkan, and OpenXR.

This repository is a Nix-focused fork of [CoderDayton/nightcap](https://github.com/CoderDayton/nightcap) (branch `vr`), providing a zero-configuration **Nix Flake**, NixOS GPU & TLS integration, and critical fixes for VR gameplay.

---

## 🛠️ Fixes & Improvements in this Fork

- **VR Locomotion Fix (Menu Button Lockup):**
  - Pressing the Quest Menu button triggered an Android App Shell event (`channels[27]`) which permanently froze character walking (trapping the left thumbstick in D-pad UI selection mode).
  - Fixed via `MOCKTAIL_VR_DISABLE_MENU=1`, keeping character movement smooth and allowing the Menu button to be safely used for OpenXR/WayVR dashboards.
- **sRGB Color Correction in VR:**
  - OpenXR previously negotiated UNORM swapchains, causing washed-out / overexposed colors.
  - Prioritizes `VK_FORMAT_R8G8B8A8_SRGB` (`MOCKTAIL_VR_SRGB=1`) for vibrant, accurate colors in VR headsets.
- **NixOS Vulkan & GIO Integration:**
  - Automatically loads host graphics drivers from `/run/opengl-driver/share/vulkan/icd.d` (Mesa / AMD / Intel / NVIDIA).
  - Packages `glib-networking` TLS modules (`GIO_EXTRA_MODULES`) so WebKitGTK settings, account login, and Robux pages work out of the box without TLS errors.
- **Complete Nix Flake:**
  - Submodules (`OpenXR-SDK`, `smaa`, `Vulkan-Headers`) fetched with SRI hashes.
  - Bundled wrappers: `nightcap-vr`, `nightcap-desktop`, and `nightcap`.

---

## ⚡ Quick Start with Nix Flake

You can launch Nightcap directly without cloning or manual compilation:

### 1. VR Mode (WiVRn / SteamVR / ALVR)
Make sure your VR runtime is running and headset is connected:
```bash
nix run github:rimemist/nightcap-nix#vr
```

### 2. Desktop Mode
```bash
nix run github:rimemist/nightcap-nix#desktop
```

### 3. Settings Window
```bash
nix run github:rimemist/nightcap-nix -- --settings
```

---

## 🐧 Non-NixOS Systems (Arch Linux, Ubuntu, Fedora with Nix)

If you are using the standalone Nix package manager on a traditional Linux distribution (e.g., Arch Linux, Ubuntu, Fedora), GPU applications in Nix require access to your host OpenGL/Vulkan drivers.

Use **[nixGL](https://github.com/nix-community/nixGL)** to run seamlessly:

```bash
# Run in VR:
nix run --impure github:nix-community/nixGL -- nix run github:rimemist/nightcap-nix#vr

# Run Desktop:
nix run --impure github:nix-community/nixGL -- nix run github:rimemist/nightcap-nix#desktop
```

---

## ❄️ NixOS Configuration Integration

Add `nightcap` to your system `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nightcap.url = "github:rimemist/nightcap-nix";
  };

  outputs = { self, nixpkgs, nightcap, ... }: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Option A: Add the overlay
        { nixpkgs.overlays = [ nightcap.overlays.default ]; }

        # Option B: Add directly to system packages
        ({ pkgs, ... }: {
          environment.systemPackages = [
            nightcap.packages.x86_64-linux.default
          ];
        })
      ];
    };
  };
}
```

Then rebuild your system (`nixos-rebuild switch --flake .`). You will have `nightcap`, `nightcap-vr`, and `nightcap-desktop` commands available in your terminal and app menu.

---

## 🎮 Running from Local Clone

If you cloned this repository locally:

```bash
git clone --recurse-submodules https://github.com/rimemist/nightcap-nix.git
cd nightcap-nix
```

You can use the included convenience scripts:

- **`./run-vr.sh`** — Launches in VR mode with WiVRn/OpenXR paths configured.
- **`./run-desktop.sh`** — Launches in normal desktop mode.
- **`./check-vr.sh`** — Verifies your OpenXR runtime and headset connection.
- **`./run-settings.sh`** — Opens the configuration window.

### Local Development Shell
Enter an isolated development environment with all build dependencies:
```bash
nix develop
```

Or build the package locally:
```bash
nix build
./result/bin/nightcap-vr
```

---

## 🥽 Supported Roblox VR Builds

Experimental VR requires matching Roblox compatibility offsets. Supported versions:

| Build | Roblox Version | Status |
| :---: | :---: | :---: |
| 3222 | 2.742.1059 | Tested & Working |
| 20836 | 2.746.1266 | Tested & Working |

---

## 📄 Documentation

- [README-NIXOS.md](README-NIXOS.md) (Полное руководство на русском языке)
- [docs/VR.md](docs/VR.md) (VR options, keybindings, and runtime configuration)
- [docs/FFLAGS.md](docs/FFLAGS.md) (Fast Flags configuration)
- [docs/PERFORMANCE.md](docs/PERFORMANCE.md) (Performance tuning)

---

## ⚖️ Credits & Attribution

- **[CoderDayton/nightcap](https://github.com/CoderDayton/nightcap)** — Creator of Nightcap and the experimental VR branch.
- **[komaruworld/mocktail](https://github.com/komaruworld/mocktail)** — Upstream project.
- Nightcap is an independent community project. It is not affiliated with Roblox Corporation or VinegarHQ.
- Licensed under the [Apache License 2.0](LICENSE).
