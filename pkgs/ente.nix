{ appimageTools, lib, fetchurl, ... }:
let
  pname = "ente-photos-desktop";
  version = "1.6.63";
  shortName = "ente";
  name = "${shortName}-${version}";

  # https://github.com/ente-io/photos-desktop/releases/download/v1.6.63/ente-1.6.63-arm64.AppImage
  # https://github.com/ente-io/photos-desktop/releases/download/v1.6.63/ente-1.6.63-x86_64.AppImage
  mirror = "https://github.com/ente-io/photos-desktop/releases/download";
  src = fetchurl {
    url = "${mirror}/v${version}/${name}-x86_64.AppImage";
    hash = "sha256-K2rNLHtzyh9/y54dz0l58XYnzsjP+qGl6OH9CExR2jU=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

    install -m 444 -D ${appimageContents}/${shortName}.desktop $out/share/applications/${pname}.desktop
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' "Exec=$out/bin/${pname}"
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  extraPkgs = pkgs: with pkgs; [ fuse ];

  meta = with lib; {
    description = "Fully open source, End to End Encrypted alternative to Google Photos and Apple Photos";
    mainProgram = "ente-photos-desktop";
    homepage = "https://github.com/ente-io/photos-desktop";
    license = licenses.mit;
    maintainers = with maintainer; [ tcarrio ];
    platforms = [ "x86_64-linux" ];
  };
}
