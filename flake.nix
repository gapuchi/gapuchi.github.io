{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default =
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
      buildInputs = with pkgs; [
        (python3.withPackages (python-pkgs: [
          python-pkgs.mkdocs
          python-pkgs.mkdocs-material
        ]))
      ];
    };
  };
}
