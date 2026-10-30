{
  lib,
  stdenv,
  fetchgit,
  fetchpatch,
  bash,
  cmake,
  glib,
  pkg-config,
  libpng,
  libusb1,
  ncurses,
  python3,
  SDL2,
  udisks,
  udisksSupport ? stdenv.hostPlatform.isLinux,
}:

let
  python = python3.withPackages (ps: [
    ps.pillow
    ps.pyelftools
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "fxsdk-unwrapped";
  version = "2.11.0";

  src = fetchgit {
    url = "https://git.planet-casio.com/Lephenixnoir/fxsdk.git";
    tag = finalAttrs.version;
    hash = "sha256-yXJ8a9h1n4NVvhNS1RFB+ItSqncR8RVOGOVoPG5ZhTI=";
  };

  patches = [
    # -ffreestanding hides most of libstdc++, making C++ add-ins impossible
    (fetchpatch {
      name = "disable-ffreestanding.patch";
      url = "https://git.planet-casio.com/Lephenixnoir/fxsdk/commit/f1721186bba1d71bfe0e4bd2741144a8f1539068.patch";
      hash = "sha256-NcyGRLrGb0HO1O1tTT7YFXF9mfEitDnbn49omyAmPrs=";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    bash
    libpng
    libusb1
    ncurses
    python
    SDL2
  ]
  ++ lib.optionals udisksSupport [
    glib
    udisks
  ];

  cmakeFlags = [ (lib.cmakeBool "FXLINK_DISABLE_UDISKS2" (!udisksSupport)) ];

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Command-line tools of the fxSDK, used to develop add-ins for CASIO graphing calculators";
    longDescription = ''
      This package only contains the host tools of the fxSDK (fxsdk, fxconv,
      fxgxa, fxlink). Use the fxsdk package for a complete development kit
      including the cross-compiler and gint.
    '';
    homepage = "https://git.planet-casio.com/Lephenixnoir/fxsdk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
    mainProgram = "fxsdk";
  };
})
