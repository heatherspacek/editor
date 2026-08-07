{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
    odin
    pkg-config
    sdl3
    sdl3-ttf
  ];

  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.sdl3 pkgs.sdl3-ttf ]}:$LD_LIBRARY_PATH"
  '';
}

