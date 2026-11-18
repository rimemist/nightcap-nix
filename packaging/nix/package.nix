{
  lib,
  stdenv,
  fetchFromGitHub,

  cmake,
  git,
  lld,
  ninja,
  pkg-config,
  vulkan-headers,
  makeWrapper,

  capstone,
  curl,
  fontconfig,
  gamemode,
  glib,
  glib-networking,
  gsettings-desktop-schemas,
  gtk4,
  hicolor-icon-theme,
  libadwaita,
  elfutils,
  ffmpeg,
  libglvnd,
  libplacebo,
  libpng,
  libsecret,
  libsoup_3,
  libutf8proc,
  libyaml,
  minizip,
  nlohmann_json,
  openssl,
  sdl3,
  sdl3-ttf,
  vulkan-loader,
  webkitgtk_6_0,
  zlib,
}:
let
  # submodules are not part of the flake source tree
  # so submodules are fetched from their pinned upstream revisions
  vulkanHeadersSrc = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Headers";
    rev = "8d6039a455a7ecc7d2a592ff97f62db4e59b70bf";
    hash = "sha256-+llJlEdzFcmqGBAdKHjYhkwBuH19ZngavmF1TQgejsI=";
  };

  openXrSdkSrc = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "OpenXR-SDK";
    rev = "f2448a8797c85814aa892efc1ab8707900fbcc78";
    hash = "sha256-glcHMArDabXbrxO4CY2QeTJFTeUTQH4v1O03LuhML7E=";
  };

  smaaSrc = fetchFromGitHub {
    owner = "iryoku";
    repo = "smaa";
    rev = "71c806a838bdd7d517df19192a20f0c61b3ca29d";
    hash = "sha256-bxM4CVwCSdJXIyFzxLJ8tGOX+yUb9BkdgSypWdL2tc8=";
  };

  src = ../..;

  lines = lib.splitString "\n" (builtins.readFile (lib.path.append src "CMakeLists.txt"));

  matches = map (builtins.match "[[:space:]]*VERSION[[:space:]]+([0-9][0-9.]*).*") lines;

  match = lib.findFirst (m: m != null) null matches;

  version =
    if match == null then throw "could not find VERSION in CMakeLists.txt" else builtins.elemAt match 0;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mocktail";
  inherit version;
  inherit src;

  nativeBuildInputs = [
    cmake
    git
    lld
    ninja
    pkg-config
    vulkan-headers
    makeWrapper
  ];

  buildInputs = [
    capstone
    curl
    fontconfig
    # Loaded with dlmopen at runtime. Keeping it here also adds libgamemode.so.0
    # to the wrapped binaries' and development shell's LD_LIBRARY_PATH.
    gamemode
    glib
    glib-networking
    gsettings-desktop-schemas
    gtk4
    hicolor-icon-theme
    libadwaita
    elfutils
    ffmpeg
    libglvnd
    libplacebo
    libpng
    libsecret
    libsoup_3
    libutf8proc
    libyaml
    minizip
    nlohmann_json
    openssl
    sdl3
    sdl3-ttf
    vulkan-loader
    webkitgtk_6_0
    zlib
  ];

  preConfigure = ''
    rm -rf third_party/Vulkan-Headers third_party/OpenXR-SDK third_party/smaa
    cp -r --no-preserve=mode ${vulkanHeadersSrc} third_party/Vulkan-Headers
    cp -r --no-preserve=mode ${openXrSdkSrc} third_party/OpenXR-SDK
    cp -r --no-preserve=mode ${smaaSrc} third_party/smaa
  '';

  # nixpkgs installs the header we need under include/libutf8proc
  NIX_CFLAGS_COMPILE = "-I${libutf8proc}/include/libutf8proc";

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_INSTALL_LIBDIR=lib"
    "-DMOCKTAIL_DEFAULT_COMPATIBILITY_MANIFEST=${placeholder "out"}/share/mocktail/metadata/roblox_compatibility.json"
    "-DMOCKTAIL_DEFAULT_SIGNING_TRUST_MANIFEST=${placeholder "out"}/share/mocktail/metadata/roblox_signing_certificates.json"
    "-DMOCKTAIL_DEFAULT_DOWNLOAD_SOURCES_MANIFEST=${placeholder "out"}/share/mocktail/metadata/roblox_download_sources.json"
    "-DMOCKTAIL_ENABLE_VR=ON"
    "-DBUILD_TESTING=OFF"
  ];

  postInstall = ''
    for binary in $out/bin/*; do
      wrapProgram "$binary" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}:/run/opengl-driver/lib" \
        --prefix GIO_EXTRA_MODULES : "${glib-networking}/lib/gio/modules" \
        --prefix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:$out/share" \
        --set-default LIBVULKAN_PATH "${vulkan-loader}/lib/libvulkan.so.1" \
        --set-default MOCKTAIL_VR_SRGB "1" \
        --set-default MOCKTAIL_VR_DISABLE_MENU "1" \
        --set-default MOCKTAIL_REQUIRE_REAL_GRAPHICS "0" \
        --run 'if [ -f /run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json ]; then export VK_DRIVER_FILES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"; export VK_ICD_FILENAMES="/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"; fi'
    done

    # Convenience wrappers
    makeWrapper "$out/bin/mocktail" "$out/bin/nightcap"
    makeWrapper "$out/bin/mocktail" "$out/bin/nightcap-vr" --add-flags "--vr"
    makeWrapper "$out/bin/mocktail" "$out/bin/nightcap-desktop" --add-flags "--no-vr"
  '';

  fixupPhase = ''
    install -Dm644 ${finalAttrs.src}/LICENSE "$out/share/licenses/${finalAttrs.pname}/LICENSE"
  '';

  meta = with lib; {
    description = "Android x86-64 Roblox compatibility runtime for Linux";
    homepage = "https://github.com/komaruworld/mocktail";
    license = licenses.asl20;
    platforms = platforms.unix;
    mainProgram = "mocktail";
  };
})
