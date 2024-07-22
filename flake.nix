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
        # WARNING_CFLAGS = -Wno-error=incompatible-function-pointer-types
        # env.CXXFLAGS = pkgs.lib.concatStringsSep " " [
        #   "-Wno-format-security"
        #   "-Wno-error=incompatible-function-pointer-types"
        # ];
        # nativeBuildInputs = with pkgs; [];
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
