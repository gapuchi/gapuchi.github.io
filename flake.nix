{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      eachDefaultSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
    in
    {
      devShells = eachDefaultSystem (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            (python3.withPackages (python-pkgs: [
              python-pkgs.mkdocs
              python-pkgs.mkdocs-material
            ]))
          ];
        };
      });
    };
}
