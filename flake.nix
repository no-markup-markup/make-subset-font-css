{
  description = "make-subset-font-css";

  inputs = {
    nixpkgs-linux.url    = "nixpkgs/nixos-25.11";
    nixpkgs-darwin.url   = "nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url      = "github:numtide/flake-utils";
    no-markup-markup.url = "github:no-markup-markup/nmm";
  };
  outputs = {
    self, nixpkgs-linux, nixpkgs-darwin, nixpkgs-unstable, flake-utils, no-markup-markup
  }:
    let
      linux-systems  = [
        # TODO "aarch64-linux"
        "x86_64-linux"
      ];
      darwin-systems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      ## windows-systems = [
      ##   # TODO "x86_64-windows"
      ## ];
      systems = linux-systems ++ darwin-systems; ## TODO ++ windows-systems;
      version = "0";
    in
      flake-utils.lib.eachSystem systems (system:
        let
          nixpkgs      = (
            if      builtins.elem system linux-systems  then
              nixpkgs-linux
            else if builtins.elem system darwin-systems then
              nixpkgs-darwin
            else
              nixpkgs-unstable
          );
          pkgs          = nixpkgs.legacyPackages.${system};
          pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
          pkgs_common   = is-dev-shell: [
            no-markup-markup.packages.${system}.default
            pkgs.julia-mono
            pkgs.bash
            pkgs.gnumake
            pkgs.python312Packages.fonttools
            pkgs.coreutils
            pkgs.gnused
          ];
        in {
          devShells.default = pkgs.mkShell {
            buildInputs = (
              (pkgs_common true)
            );
            shellHook = ''
              cd tests/input
              ln -s ${pkgs.julia-mono}/share/fonts/truetype JuliaMono
              cd -
            '';
          };
          packages.default = pkgs.stdenv.mkDerivation {
            name        = "make-subset-font-css-${version}";
            buildInputs = [
              pkgs.bash
              pkgs.gnumake
              pkgs.python312Packages.fonttools
              pkgs.coreutils
              pkgs.gnused
             ];
            src          = ./.;
            buildPhase   = ''
              make bin/make-subset-font-css
            '';
            installPhase = ''
              mkdir -p $out/bin
              cp bin/* $out/bin/
            '';
          };
          apps.default = {
            type    = "app";
            program = "${self.packages.${system}.default}/bin/make-subset-font-css";
          };
        }
      );
}
