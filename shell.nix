# so we can access the `pkgs` and `stdenv` variables
with import <nixpkgs> {};

let
  easy-ps = import (
    pkgs.fetchFromGitHub {
      owner = "justinwoo";
      repo = "easy-purescript-nix";
      rev = "7802db65618c2ead3a55121355816b4c41d276d9";
      sha256 = "0n99hxxcp9yc8yvx7bx4ac6askinfark7dnps3hzz5v9skrvq15q";
    }
  ) {
    inherit pkgs;
  };
in
stdenv.mkDerivation {
  name = "purescript-bootstrap-shell";
  buildInputs = with pkgs; [
    nodejs-14_x
    easy-ps.purs
    easy-ps.spago
    easy-ps.purs-tidy
  ];
}
