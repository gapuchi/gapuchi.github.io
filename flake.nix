{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      eachDefaultSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
      mkBuildInputs = system: with nixpkgs.legacyPackages.${system}; [
          (python3.withPackages (python-pkgs: [
            python-pkgs.mkdocs
            python-pkgs.mkdocs-material
          ]))
        ];
    in
    {
      devShells = eachDefaultSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = mkBuildInputs system;
        };
      });

      apps = eachDefaultSystem (system: {
        serve = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.runCommand "serve" {
            buildInputs = mkBuildInputs system;
          } ''
            cd ${self}
            mkdocs serve
          ''}";
        };
      });
    };
}
