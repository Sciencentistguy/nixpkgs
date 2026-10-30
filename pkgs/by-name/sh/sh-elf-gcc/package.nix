{
  lib,
  stdenv,
  fetchurl,
  gmp,
  isl,
  libmpc,
  mpfr,
  perl,
  texinfo,
  zlib,
  sh-elf-binutils,
}:

let
  target = "sh3eb-elf";
  binutilsTools = [
    "ar"
    "as"
    "ld"
    "nm"
    "objcopy"
    "objdump"
    "ranlib"
    "readelf"
    "strip"
  ];
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sh-elf-gcc";
  version = "14.1.0";

  src = fetchurl {
    url = "mirror://gnu/gcc/gcc-${finalAttrs.version}/gcc-${finalAttrs.version}.tar.xz";
    hash = "sha256-4oPGVJh6/j3p2AgLwL15U0tcoNaBpzoR/ytdN2dCaEA=";
  };

  patches = [
    # From https://git.planet-casio.com/Lephenixnoir/sh-elf-gcc/src/tag/14.1.0/patches
    ./libgcc-use-soft-fp.patch
  ];

  nativeBuildInputs = [
    perl
    sh-elf-binutils
    texinfo
  ];

  buildInputs = [
    gmp
    isl
    libmpc
    mpfr
    zlib
  ];

  env = lib.listToAttrs (
    map (tool: lib.nameValuePair "${lib.toUpper tool}_FOR_TARGET" "sh-elf-${tool}") binutilsTools
  );

  # The fxSDK renames binutils to sh-elf-*, so GCC cannot find them by itself.
  # Link them into the tooldir, where the driver looks relative to itself.
  preConfigure = ''
    mkdir -p $out/${target}/bin
    for tool in ${toString binutilsTools}; do
      ln -s ${sh-elf-binutils}/bin/sh-elf-$tool $out/${target}/bin/$tool
    done

    mkdir build
    cd build

    # GCC 14.1 does not build with newer language defaults
    configureFlagsArray+=("CC=$CC -std=gnu17" "CXX=$CXX -std=gnu++14")
  '';

  configureScript = "../configure";

  # Mirrors the configuration used by the fxSDK's sh-elf-gcc scripts
  configureFlags = [
    "--target=${target}"
    "--with-multilib-list=m3,m4-nofpu"
    "--enable-languages=c,c++"
    "--without-headers"
    "--program-prefix=sh-elf-"
    "--enable-libssp"
    "--enable-lto"
    "--enable-clocale=generic"
    "--enable-libstdcxx-allocator"
    "--disable-threads"
    "--disable-libstdcxx-verbose"
    "--enable-cxx-flags=-fno-exceptions"
    "--disable-nls"
  ];

  buildFlags = [
    "all-gcc"
    "all-target-libgcc"
  ];

  installTargets = [
    "install-strip-gcc"
    "install-strip-target-libgcc"
  ];

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ];

  # Target libraries are already stripped by install-strip-*, and the host
  # strip does not understand SuperH objects
  dontStrip = true;

  passthru = { inherit target; };

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "GCC cross-compiler targeting the SuperH processors of CASIO graphing calculators";
    homepage = "https://git.planet-casio.com/Lephenixnoir/sh-elf-gcc";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
    mainProgram = "sh-elf-gcc";
  };
})
