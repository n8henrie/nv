{
  lib,
  stdenv,
  openssl,
  darwin,
  zlib,
}:
stdenv.mkDerivation {
  name = "notational-velocity";
  version = "2.0 β7";
  src = lib.cleanSource ./.;
  buildInputs =
    [
      openssl.dev
      zlib
    ]
    ++ (with darwin.apple_sdk.frameworks; [
      AppKit
      ApplicationServices
      Carbon
      Cocoa
      CoreServices
      Foundation
      IOKit
      Security
      SecurityInterface
      SystemConfiguration
      WebKit
    ]);

  NIX_CFLAGS_COMPILE = [
    "-Wno-format-security"
    "-Wno-error=incompatible-function-pointer-types"
  ];

  buildPhase = ''
    runHook preBuild

    clang \
      -x objective-c-header \
      -c Notation_Prefix.pch \
      -o Notation_Prefix-objc.pch.gch

    clang \
      -x c-header \
      -c Notation_Prefix.pch \
      -o Notation_Prefix-c.pch.gch

    mapfile -d "" -t cfiles < <(find . -type f -name '*.c' -print0)
    clang \
      -x c \
      -include Notation_Prefix-c.pch \
      -c \
      "''${cfiles[@]}"

    mapfile -d "" -t objcfiles < <(find . -type f -name '*.m' -print0)
    clang \
      -x objective-c \
      -include Notation_Prefix-objc.pch \
      -I. \
      -I./JSON \
      -I./PTHotKeys \
      -I./ODBEditor \
      -c \
      "''${objcfiles[@]}"

    mapfile -d "" -t ofiles < <(find . -type f -name '*.o' -print0)
    clang \
      -lcrypto \
      -lz \
      -framework Cocoa \
      -framework Carbon \
      -framework CoreServices \
      -framework SecurityInterface \
      -framework Security \
      -framework WebKit \
      -framework ApplicationServices \
      -framework SystemConfiguration \
      -framework IOKit \
      "''${ofiles[@]}" \
      -o "Notational Velocity"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    dest="$out/Applications/Notational Velocity.app"
    mkdir -p "$dest"/Contents/{MacOS,Resources}
    cp "Notational Velocity" "$dest"/Contents/MacOS/
    cp "Info.plist" "$dest"/Contents/
    find . -type d -name '*.lproj' -exec cp -r -t "$dest"/Contents/Resources/ {} +

    runHook postInstall
  '';
}
