{
  description = "Ocaml flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    usedPkgs = with pkgs; [
      ocaml
      dune_3  
      ocamlPackages.findlib
      ocamlPackages.containers
      ocamlPackages.ocamlformat-rpc-lib
      ocamlPackages.ocamlformat
      ocamlPackages.gstreamer
      ocamlPackages.eio_main
      ocamlPackages.ocaml_sqlite3
      sqlite
      libev
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
    ];
  in
  {
    devShells.${system}.default =
      pkgs.mkShell 
        {
          buildInputs = usedPkgs;

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath(usedPkgs);

          shellHook = ''
            echo "Ocaml flake started"
          '';

        };

    #packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    #packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
