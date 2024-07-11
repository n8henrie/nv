{
  lib,
  stdenv,
  openssl,
  xcbuild,
  darwin,
}:
stdenv.mkDerivation {
  name = "notational-velocity";
  version = "2.0 β7";
  src = lib.cleanSource ./.;
  nativeBuildInputs = [ xcbuild ];
  buildInputs =
    [
      darwin.Libsystem
      openssl
    ]
    ++ (with darwin.apple_sdk.frameworks; [
      AppKit
      # Carbon
      Cocoa
      WebKit
    ]);
  dontUnpack = true;
  buildPhase = ''
    runHook preBuild

    set -x

    # mkdir -p $out/"Notational Velocity.app/Contents/Resources"

    # CONFIGURATION_BUILD_DIR=.
    pwd
    ls -ld .

    mkdir -p "Products/Deployment/Notational Velocity.app/Contents/MacOS"
    find .

      # -jobs $NIX_BUILD_CORES \
    xcodebuild build \
      SYMROOT=$PWD/Products OBJROOT=$PWD/Intermedates \
      -configuration Deployment \
      -project $src/Notation.xcodeproj \
      -destination generic/platform=macOS \
      -arch ${stdenv.hostPlatform.darwinArch} || true

    find .

    exit 1

    # clang -cc1 -emit-pch -o Notation_Prefix.pch.gch Notation_Prefix.pch
    # clang -cc1 -emit-pch -I${darwin.Libsystem}/include -o Notation_Prefix.pch.gch $src/Notation_Prefix.pch
    # clang -x c-header -c $src/Notation_Prefix.pch -o Notation_Prefix.pch.gch
    # clang -x objective-c -include-pch Notation_Prefix.pch.gch $src/*.m
    # clang -objc -include-pch Notation_Prefix.pch.gch $src/*.m

    runHook postBuild
  '';
}
