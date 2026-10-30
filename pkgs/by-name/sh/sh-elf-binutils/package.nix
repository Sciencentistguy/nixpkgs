{
  lib,
  stdenv,
  fetchurl,
  perl,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sh-elf-binutils";
  version = "2.42";

  src = fetchurl {
    url = "mirror://gnu/binutils/binutils-${finalAttrs.version}.tar.xz";
    hash = "sha256-9uTUH9X8d4sGt4kUV7NiDaXs6hAGxqSkGumYEJ+FqAA=";
  };

  nativeBuildInputs = [
    perl
    texinfo
  ];

  # Mirrors the configuration used by the fxSDK's sh-elf-binutils scripts
  configureFlags = [
    "--target=sh3eb-elf"
    "--with-multilib-list=m3,m4-nofpu"
    "--program-prefix=sh-elf-"
    "--enable-libssp"
    "--enable-lto"
    "--disable-nls"
    "--disable-werror"
  ];

  enableParallelBuilding = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "GNU binutils targeting the SuperH processors of CASIO graphing calculators";
    homepage = "https://git.planet-casio.com/Lephenixnoir/sh-elf-binutils";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
  };
})
