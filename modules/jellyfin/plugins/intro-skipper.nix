(
  final: prev:
    {
      jellyfin-web = prev.pkgs.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
        installPhase = ''
          runHook preInstall

          # this is the important line
          sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

          mkdir -p $out/share
          cp -a dist $out/share/jellyfin-web

          runHook postInstall
        '';
      });
    }
)