{
  lib,
  stdenvNoCC,
  fetchgit,
  sh-elf-binutils,
  sh-elf-gcc,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "openlibm-sh3eb";
  version = "0.7.5-sh3eb-2";

  src = fetchgit {
    url = "https://git.planet-casio.com/Lephenixnoir/OpenLibm.git";
    tag = finalAttrs.version;
    hash = "sha256-JtR2KJXldPoGJ3E7BxQ1uej6Fegaqj5z+U/mI9icffE=";
  };

  nativeBuildInputs = [
    sh-elf-binutils
    sh-elf-gcc
  ];

  makeFlags = [
    "USEGCC=1"
    "TOOLPREFIX=sh-elf-"
    "CC=sh-elf-gcc"
    "AR=sh-elf-ar"
    "libdir=${placeholder "out"}/${sh-elf-gcc.target}/lib"
    "includedir=${placeholder "out"}/${sh-elf-gcc.target}/include"
  ];

  installTargets = [
    "install-static-superh"
    "install-headers-superh"
  ];

  enableParallelBuilding = true;

  dontStrip = true;

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    description = "Soft-float SuperH port of OpenLibm for CASIO graphing calculators";
    homepage = "https://git.planet-casio.com/Lephenixnoir/OpenLibm";
    license = with lib.licenses; [
      mit
      bsd2
      isc
    ];
    maintainers = with lib.maintainers; [ sciencentistguy ];
    platforms = lib.platforms.unix;
  };
})
