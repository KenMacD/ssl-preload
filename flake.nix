{
  description = "LD_PRELOAD library for accepting mitmproxy certificates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        packages = {
          default = self.packages.${system}.ssl-preload;

          ssl-preload = pkgs.stdenv.mkDerivation {
            pname = "ssl-preload";
            version = "0.1.0";

            src = pkgs.lib.cleanSource ./.;

            buildInputs = with pkgs; [
              openssl
              pkg-config
            ];

            installPhase = ''
              mkdir -p $out/lib
              cp libssl_preload.so $out/lib/

              # Create a convenient wrapper script
              mkdir -p $out/bin
              cat > $out/bin/with-ssl-preload <<EOF
              #!/usr/bin/env sh
              LD_PRELOAD=$out/lib/libssl_preload.so exec "\$@"
              EOF
              chmod +x $out/bin/with-ssl-preload
            '';

            meta = with pkgs.lib; {
              description = "LD_PRELOAD library for accepting mitmproxy certificates";
              platforms = platforms.linux;
              license = licenses.mit;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            pkg-config
            gcc
          ];
        };
      }
    );
}
