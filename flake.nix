{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        mkdocs = pkgs.python3.withPackages (python-pkgs: [
          python-pkgs.mkdocs
          python-pkgs.mkdocs-material
        ]);
      in
      {
        apps = {
          default = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "serve" ''
              cd ${self}
              ${mkdocs}/bin/mkdocs serve
            ''}/bin/serve";
          };
        };
      }
    );
}
