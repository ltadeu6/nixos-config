# SysEx Controls: editor livre (GTK4/libadwaita) que substitui o MIDI Control
# Center da Arturia. Usado para configurar o Minilab3 sem a VM Windows.
{ lib, stdenv, fetchFromGitHub, meson, ninja, pkg-config, wrapGAppsHook4
, desktop-file-utils, appstream, gettext, glib, gtk4, libadwaita, alsa-lib }:

stdenv.mkDerivation rec {
  pname = "sysex-controls";
  version = "0.2.28";

  src = fetchFromGitHub {
    owner = "soyersoyer";
    repo = "sysex-controls";
    rev = "v${version}";
    hash = "sha256-DfVa0xUA79aSEo3V4O6MQWDxaRNJMO0HrA6diq0p/SY=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook4
    desktop-file-utils
    appstream
    gettext
    glib
  ];
  buildInputs = [ gtk4 libadwaita alsa-lib ];

  meta = {
    description = "SysEx controls for Akai, Arturia and Korg MIDI devices";
    homepage = "https://github.com/soyersoyer/sysex-controls";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "sysex-controls";
  };
}
