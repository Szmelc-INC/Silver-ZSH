{
  description = "Installer/setup for the Silver ZSH environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        setup-silver-zsh = pkgs.stdenv.mkDerivation {
          pname = "setup-silver-zsh";
          version = "0-unstable-${self.shortRev or self.dirtyShortRev or "dirty"}";
          src = ./.;
          dontBuild = true;
          installPhase = ''
            runHook preInstall
            install -Dm755 setup-silver-zsh $out/bin/setup-silver-zsh
            install -Dm644 LICENSE $out/share/licenses/setup-silver-zsh/LICENSE
            runHook postInstall
          '';
          meta = {
            description = "Installer/setup for the Silver ZSH environment";
            homepage = "https://github.com/Szmelc-INC/Silver-ZSH";
            license = pkgs.lib.licenses.mit;
            mainProgram = "setup-silver-zsh";
            platforms = pkgs.lib.platforms.linux;
          };
        };
        default = setup-silver-zsh;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/setup-silver-zsh";
        };
      });
    };
}
