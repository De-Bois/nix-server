{ stdenv, lib, fetchurl, docker, gnutar }:

stdenv.mkDerivation rec {
  pname = "pelican-wings";
  version = "v1.0.0-beta11";

  src = fetchurl {
    url = "https://github.com/pelican-dev/wings/releases/download/${version}/wings_linux_amd64";
    hash = "sha256-4Rt1cFIKP9AC6r8ho13oHwOx3v4ZPdoOd6AMNTnQrug=";
  };

  buildInputs = [ docker gnutar ];

  phases = [ "installPhase" ];

  installPhase = ''
    install -D $src $out/bin/wings
  '';
}