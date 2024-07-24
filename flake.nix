{
  description = "Flake to resurrect Notational Velocity";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";
  outputs =
    { nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.callPackage ./. { };
      devShells.${system}.default = pkgs.mkShell {
        buildInputs =
          with pkgs;
          [
            darwin.Libsystem
            openssl.dev
          ]
          ++ (with pkgs.darwin.apple_sdk.frameworks; [
            Cocoa
            WebKit
          ]);
      };
    };
}
