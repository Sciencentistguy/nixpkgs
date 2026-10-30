{
  lib,
  stdenvNoCC,
  fetchgit,
  cmake,
  fxsdk,
  openlibm-sh3eb,
  sh-elf-gcc,
}:

let
  fxsdk' = fxsdk.override { libraries = [ openlibm-sh3eb ]; };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fxlibc";
  version = "1.5.1";

  src = fetchgit {
    url = "https://git.planet-casio.com/Vhex-Kernel-Core/fxlibc.git";
    tag = finalAttrs.version;
    hash = "sha256-ESZ2f1yQcq3lK6uEBnJgcXgyYJA61oe6F/RQNHAbobk=";
  };

  nativeBuildInputs = [
    cmake
    fxsdk'
  ];

  # The generic CMake setup hook would point CMAKE_AR etc. at host tools
  dontUseCmakeConfigure = true;

  configurePhase = ''
    runHook preConfigure

    cmake -B build \
      -DFXLIBC_TARGET=gint \
      -DCMAKE_TOOLCHAIN_FILE=cmake/toolchain-sh.cmake \
      -DCMAKE_INSTALL_PREFIX=$out/${sh-elf-gcc.target}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make -C build -j$NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make -C build install
    runHook postInstall
  '';

  dontStrip = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "C standard library for CASIO graphing calculator add-ins built with gint";
    homepage = "https://git.planet-casio.com/Vhex-Kernel-Core/fxlibc";
    license = with lib.licenses; [
      cc0
      # 3rdparty/grisu2b_59_56
      mit
      # 3rdparty/tinymt32
      bsd3
    ];
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
  };
})
