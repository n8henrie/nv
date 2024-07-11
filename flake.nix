{
  description = "Very basic template for darwin";

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # overlays = {
      #   default = self.overlays.${name};
      #   ${name} = _: prev: {
      #     # inherit doesn't work with dynamic attributes
      #     ${name} = self.packages.${prev.system}.${name};
      #   };
      # };
      packages.${system}.default = pkgs.callPackage ./. { };
      # apps.${system}.default = {
      #   type = "app";
      #   program = "${self.packages.${system}.default}/bin/${name}";
      # };
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          darwin.Libsystem
          openssl.dev
        ];
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
