{ stdenv, lib, fetchurl, docker, gnutar }:

stdenv.mkDerivation rec {
  pname = "pelican-wings";
  version = "v1.0.0-beta8";

  src = fetchurl {
    url = "https://github.com/pelican-dev/wings/releases/download/${version}/wings_linux_amd64";
    hash = "sha256-a2T4BjqS8Hy5YqwDEJpbvGqqsrVjdRhxvJLgk3MCXag=";
  };

  buildInputs = [ docker gnutar ];

  phases = [ "installPhase" ];

  installPhase = ''
    install -D $src $out/bin/wings
  '';
}