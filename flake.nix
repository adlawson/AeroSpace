{
  description = "adlawson/Aerospace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (s: f nixpkgs.legacyPackages.${s});
    in
    {
      devShells = forAllSystems (pkgs: {
        # mkShellNoCC: plain mkShell implicitly puts stdenv.cc (nix's own
        # clang/cctools/xcrun) on PATH, which shadows the real Xcode
        # toolchain and breaks `swift build` / `xcodebuild`.
        default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            # script/setup.sh requires bash 5+ (macOS ships 3.2)
            bash
            git

            # build-docs.sh (bundler exec asciidoctor)
            ruby
            bundler

            # build-shell-completion.sh (complgen is `cargo install`ed by script/install-dep.sh, then sourced/checked in each shell)
            rustc
            cargo
            fish
            zsh

            # build-release.sh (xcodebuild-pretty, zip packaging, install-dep.sh downloads)
            xcbeautify
            curl
            unzip
            zip

            # Manages the actual Xcode.app install that xcodebuild/swift need.
            # NOTE: swiftly isn't packaged in nixpkgs, so it's not included here -
            # install it separately (https://www.swift.org/swiftly/) if you want
            # setup.sh's `swift()` wrapper to use it instead of falling back to
            # the system `swift` from Xcode.
            xcodes
          ];
        };
      });
    };
}
