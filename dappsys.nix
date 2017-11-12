{ dapphub ? import <dapphub> {} }:

let
  inherit (dapphub) pkgs;

  remappings = xs:
    builtins.foldl' pkgs.lib.mergeAttrs {}
      (builtins.map
        (x: {
          "${x.name}/" = "${x}/src/";
          "${x.name}" = "${x}/src/index.sol";
         } // x.remappings)
         xs);

  dappPackage = attrs @ { dependencies ? [], ... }:
    pkgs.stdenv.mkDerivation (rec {
      buildInputs = [pkgs.solc];
      passthru.remappings =
        remappings dependencies;
      REMAPPINGS =
        pkgs.lib.mapAttrsToList (k: v: k + "=" + v) (remappings dependencies);
      builder = ./dapp.sh;
    } // attrs);

in rec {
  ds-test = dappPackage rec {
    name = "ds-test";
    src = pkgs.fetchFromGitHub {
      owner = "dapphub";
      repo = name;
      rev = "8053e2589749238451678b5a75028bc830dc31cb";
      sha256 = "0ifxf6m1q4i0rlg46yh9a8brsyj8m0bybs2gx4sx6kd5300b1qjq";
    };
  };

  ds-auth = dappPackage rec {
    name = "ds-auth";
    dependencies = [ds-test];
    src = pkgs.fetchFromGitHub {
      owner = "dapphub";
      repo = name;
      rev = "c0050bbb6807027c623b1a1ee7afd86515cdb004";
      sha256 = "08a544lmikaqz87alw67286rv31bxv8hmwgmhz7a2pxw25d0xxbj";
    };
  };
}
