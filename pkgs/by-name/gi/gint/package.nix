{
  lib,
  stdenvNoCC,
  fetchgit,
  fxsdk,
  fxlibc,
  openlibm-sh3eb,
  sh-elf-gcc,
}:

let
  fxsdk' = fxsdk.override {
    libraries = [
      openlibm-sh3eb
      fxlibc
    ];
  };
  platforms = [
    "fx"
    "cg"
    "fxg3a"
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gint";
  version = "2.11.0";

  src = fetchgit {
    url = "https://git.planet-casio.com/Lephenixnoir/gint.git";
    tag = finalAttrs.version;
    hash = "sha256-+83vV2elvlMgZ+eCfDNFwdHTovJQSUq/uAOfwc7s5j8=";
  };

  # gint installs into the paths reported by `fxsdk path`, which here belong to
  # the build-time fxsdk environment
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail '"''${FXSDK_LIB}"' '"''${CMAKE_INSTALL_PREFIX}/${sh-elf-gcc.target}/lib"' \
      --replace-fail '"''${FXSDK_INCLUDE}' '"''${CMAKE_INSTALL_PREFIX}/${sh-elf-gcc.target}/include' \
      --replace-fail '"''${FXSDK_CMAKE_MODULE_PATH}"' '"''${CMAKE_INSTALL_PREFIX}/lib/cmake/fxsdk"'
  '';

  nativeBuildInputs = [ fxsdk' ];

  # Mirrors giteapc.make
  configurePhase = ''
    runHook preConfigure
    for platform in ${toString platforms}; do
      fxsdk build-$platform -c -DCMAKE_INSTALL_PREFIX=$out
    done
    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    for platform in ${toString platforms}; do
      fxsdk build-$platform -j$NIX_BUILD_CORES
    done
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    for platform in ${toString platforms}; do
      fxsdk build-$platform install
    done
    runHook postInstall
  '';

  dontStrip = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Add-in unikernel for CASIO graphing calculators of the fx-9860G II and fx-CG 50 families";
    homepage = "https://git.planet-casio.com/Lephenixnoir/gint";
    # README: "This is free software: you may use it for any purpose, share it,
    # modify it, and share your changes. Credit is not required"
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
  };
})
