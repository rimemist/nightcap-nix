#!/usr/bin/env bash
# Nightcap NixOS runtime environment

# Dynamic libraries
NIX_LIBS="/nix/store/wsawm4nismaxz5lzc40ywcwyi1mcn6xv-vulkan-loader-1.4.357.0/lib:/nix/store/80nx7ciyhxikh3wp12z9wyvwzl6mz3gl-capstone-5.0.9/lib:/nix/store/physhp1ym3nmrx9drp064x7d6wzri2k2-curl-8.21.0-dev/lib:/nix/store/h4458hsxjxj2nd8b4ppi88f84bn5srmm-fontconfig-2.18.2-dev/lib:/nix/store/523c8ahn31rkirncjlab9nwmn4zkxf15-gamemode-1.8.2-dev/lib:/nix/store/lfrjb7zz2g8mkm1g1jjg2hxwd1crryf6-glib-2.88.3-dev/lib:/nix/store/x9c472v731cfp7z3znbrg7sxck9zxfp1-glib-networking-2.80.1/lib:/nix/store/ldarm0myfdg5zglxaknziixckyq4szg7-gtk4-4.22.4-dev/lib:/nix/store/ss9b228006whyxa2bj7mqhv7w9h05f7z-hicolor-icon-theme-0.18-dev/lib:/nix/store/cqnidzcnvq78ar8kjqjhr728z6bcxy43-libadwaita-1.9.3-dev/lib:/nix/store/d0v13qn5kd2dwipwnpdsrjxb24519ab0-elfutils-0.195-dev/lib:/nix/store/zi7hs9vvxgx6ld1lyyk6szswdy39xgmp-ffmpeg-9.0-dev/lib:/nix/store/z4jvvncv5w8w35jq3f5bjxyn1mi97cmd-libglvnd-1.7.0-dev/lib:/nix/store/szab3dl8b0w737ph3awknyk5rl4x45m5-libplacebo-7.360.1/lib:/nix/store/pnpxsfvpgq3rl3i4n26802y6mw7nhinx-libpng-apng-1.6.58-dev/lib:/nix/store/n09ymlzhgdq6r74brsg0nkjyf3nqwy1r-libsecret-0.21.7-dev/lib:/nix/store/1x1vakr07gdjssv1szw255pmsg0mfa91-libsoup-3.6.6-dev/lib:/nix/store/jx3ln8gv4ykviij0mn877nm68hii0x6q-libutf8proc-2.4.0-1/lib:/nix/store/skmvbzmzdd7fqgmsw72vnmfdj0ij6gdr-libyaml-0.2.5-dev/lib:/nix/store/ql23s2lyjjcsm9k7ay2npivjns8gb580-minizip-1.3.2/lib:/nix/store/ymc296bfq75wwf7n44gzz8xng7xrsaci-nlohmann_json-3.12.0/lib:/nix/store/djbmc5jk7ggq5hhcb1g976iadjbs99hb-openssl-3.6.3-dev/lib:/nix/store/cc4w5kk80gybwz55dxsgj0pnb38nvxp5-sdl3-3.4.12-dev/lib:/nix/store/b8rcpkdhsvxzy9grhf4a0bp4v3zqdrlz-sdl3-ttf-3.2.2/lib:/nix/store/kbz9i48k5nvzzfrdss01lc3vsrsgp1cp-vulkan-loader-1.4.357.0-dev/lib:/nix/store/iqx3q70vzjrd11xvpj49ia0c0gvmqhly-webkitgtk-2.52.5+abi=6.0-dev/lib:/nix/store/dfb5jybg1sakjy1zahpgrxfqmz5rfwmc-zlib-1.3.2-dev/lib"

export LD_LIBRARY_PATH="${NIX_LIBS}:/run/opengl-driver/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Explicit path to host Vulkan loader
export LIBVULKAN_PATH="/nix/store/wsawm4nismaxz5lzc40ywcwyi1mcn6xv-vulkan-loader-1.4.357.0/lib/libvulkan.so.1"

# TLS / HTTPS for WebKitGTK & GIO (fixes "TLS support is not available")
export GIO_EXTRA_MODULES="/nix/store/x9c472v731cfp7z3znbrg7sxck9zxfp1-glib-networking-2.80.1/lib/gio/modules${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"

# GSettings schemas for GLib
for schema_dir in /nix/store/*-gsettings-desktop-schemas-*/share/gsettings-schemas/* /run/current-system/sw/share/gsettings-schemas; do
  if [ -d "$schema_dir" ]; then
    export XDG_DATA_DIRS="${schema_dir%/*/*}:${XDG_DATA_DIRS:-/run/current-system/sw/share:/usr/share}"
    break
  fi
done

# Vulkan ICD on NixOS (fixes AMD Vulkan detection)
if [ -f /run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json ]; then
  export VK_DRIVER_FILES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
  export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
fi

export MOCKTAIL_REQUIRE_REAL_GRAPHICS=0
export MOCKTAIL_VR_SRGB=1
export MOCKTAIL_VR_DISABLE_MENU=1
