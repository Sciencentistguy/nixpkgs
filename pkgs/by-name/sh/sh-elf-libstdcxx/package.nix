{
  lib,
  sh-elf-gcc,
  fxlibc,
  openlibm-sh3eb,
}:

let
  inherit (sh-elf-gcc) target;
  libc = [
    fxlibc
    openlibm-sh3eb
  ];
in
# libstdc++ needs the libc, which itself is built with sh-elf-gcc. Like the
# fxSDK's second sh-elf-gcc pass, rebuild GCC with the libc in its tooldir, but
# only install libstdc++.
sh-elf-gcc.overrideAttrs (prev: {
  pname = "sh-elf-libstdcxx";

  preConfigure = ''
    for dir in include lib; do
      mkdir -p $out/${target}/$dir
      for pkg in ${toString libc}; do
        ln -s $pkg/${target}/$dir/* $out/${target}/$dir/
      done
    done
  ''
  + prev.preConfigure;

  buildFlags = [
    "all-gcc"
    "all-target-libstdc++-v3"
  ];

  installTargets = [ "install-strip-target-libstdc++-v3" ];

  postInstall = ''
    rm -r $out/${target}/bin
    for dir in include lib; do
      for pkg in ${toString libc}; do
        for file in $pkg/${target}/$dir/*; do
          rm $out/${target}/$dir/$(basename $file)
        done
      done
    done
  '';

  meta = removeAttrs prev.meta [ "mainProgram" ] // {
    description = "GNU C++ standard library for the SuperH processors of CASIO graphing calculators";
    license = with lib.licenses; [
      gpl3Plus
      # GCC Runtime Library Exception
      free
    ];
  };
})
