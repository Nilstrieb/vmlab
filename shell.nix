{ pkgs ? import <nixpkgs> { } }: pkgs.mkShell {
  packages = with pkgs; [ debootstrap ansible ansible-lint ];
}
