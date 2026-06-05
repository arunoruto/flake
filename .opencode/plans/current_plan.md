Home Manager cleanup plan

Goal: collapse `modules/home-manager/background/programs/` into `background/cli/` because those modules are CLI/TUI/user tools and overlap with the existing CLI category.

Moves:
- `background/programs/git/` -> `background/cli/git/`
- `background/programs/games/` -> `background/cli/games/`
- `background/programs/awscli.nix` -> `background/cli/cloud/awscli.nix`
- `background/programs/iamb.nix`, `newsboat.nix`, `pop.nix` -> `background/cli/communication/`
- `background/programs/papis.nix` -> `background/cli/documents/papis.nix`
- `background/programs/mods.nix` -> `background/cli/ai/mods.nix`

Cleanup:
- Remove `background/programs/default.nix` and empty directory.
- Remove duplicate `foreground/programs/games/chess-tui.nix` if unused.
- Remove backup/dead artifacts only if they are not imported.

Verification:
- Stage moved files for flake visibility.
- Run `nix flake check`.

Next low-risk Home Manager phase:
- Move top-level `modules/home-manager/media/` into `background/services/audio/`.
- Fix simple option namespace mismatches: Zathura, Steam, Firefox PWA.
- Remove obvious backup artifacts under `modules/home-manager/`.
- Verify with Nix evaluation and `nix flake check`.
