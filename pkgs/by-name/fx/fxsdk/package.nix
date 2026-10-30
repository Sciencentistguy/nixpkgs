{
  lib,
  symlinkJoin,
  makeWrapper,
  cmake,
  coreutils,
  findutils,
  getopt,
  gnugrep,
  gnumake,
  gnused,
  runCommand,
  fxsdk-unwrapped,
  sh-elf-binutils,
  sh-elf-gcc,
  sh-elf-libstdcxx,
  openlibm-sh3eb,
  fxlibc,
  gint,
  libraries ? [
    openlibm-sh3eb
    fxlibc
    sh-elf-libstdcxx
    gint
  ],
}:

# The fxSDK expects the cross-compiler, the target libraries and its own CMake
# modules to share a single prefix. This joins all components into one tree,
# then points both GCC and the fxsdk script at it rather than at their own
# store paths.
symlinkJoin (finalAttrs: {
  pname = "fxsdk";
  inherit (fxsdk-unwrapped) version;

  paths = [
    fxsdk-unwrapped
    sh-elf-binutils
    sh-elf-gcc
  ]
  ++ libraries;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    for driver in sh-elf-{c++,cpp,g++,gcc} sh3eb-elf-gcc-${sh-elf-gcc.version}; do
      rm $out/bin/$driver
      makeWrapper ${sh-elf-gcc}/bin/$driver $out/bin/$driver \
        --set GCC_EXEC_PREFIX $out/lib/gcc/
    done

    rm $out/bin/fxsdk
    substitute ${fxsdk-unwrapped}/bin/fxsdk $out/bin/fxsdk \
      --replace-fail 'PREFIX="${fxsdk-unwrapped}"' "PREFIX=\"$out\"" \
      --replace-fail '$PREFIX/share/fxsdk/sysroot' '$PREFIX'
    chmod +x $out/bin/fxsdk

    wrapProgram $out/bin/fxsdk \
      --prefix PATH : $out/bin:${
        lib.makeBinPath [
          cmake
          coreutils
          findutils
          getopt
          gnugrep
          gnumake
          gnused
        ]
      }
  '';

  passthru.tests = {
    build-addin =
      runCommand "fxsdk-test-build-addin"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          fxsdk new MyAddin
          cd MyAddin
          fxsdk build-fx
          fxsdk build-cg
          test -s MyAddin.g1a
          test -s MyAddin.g3a
          touch $out
        '';

    build-cxx-addin =
      runCommand "fxsdk-test-build-cxx-addin"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          fxsdk new MyAddin
          cd MyAddin
          rm src/main.c
          cp ${./test-main.cpp} src/main.cpp
          substituteInPlace CMakeLists.txt \
            --replace-fail src/main.c src/main.cpp \
            --replace-fail 'target_link_libraries(myaddin Gint::Gint)' \
                           'target_link_libraries(myaddin -lstdc++ Gint::Gint)'
          fxsdk build-cg
          test -s MyAddin.g3a
          touch $out
        '';
  };

  strictDeps = true;
  __structuredAttrs = true;

  meta = {
    inherit (fxsdk-unwrapped.meta)
      homepage
      license
      maintainers
      platforms
      mainProgram
      ;
    description = "Development kit for CASIO graphing calculator add-ins, including the cross-compiler and gint";
  };
})
