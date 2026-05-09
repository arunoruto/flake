# Tips & Resources

## Tutorials & Guides

- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/) — comprehensive intro
- [A Gentle Introduction to Nix Flakes](https://ebzzry.com/en/flakes/) — flake anatomy
- [Why you don't need flake-utils](https://ayats.org/blog/no-flake-utils) — the case for plain Nix

### Vimjoyer (YouTube)

- [Nix explained from the ground up](https://www.youtube.com/watch?v=5D3nUU1OVx8)
- [NixOS: Everything Everywhere All At Once](https://www.youtube.com/watch?v=CwfKlX3rA6E)
- [Ultimate NixOS Guide](https://www.youtube.com/watch?v=a67Sv4Mbxmc)
- [Modularize NixOS and Home Manager](https://www.youtube.com/watch?v=vYc6IzKvAJQ)
- [Nixvim: Neovim Distro Powered By Nix](https://www.youtube.com/watch?v=b641h63lqy0)
- [Is NixOS The Best Gaming Distro](https://www.youtube.com/watch?v=qlfm3MEbqYA)

### Other

- [Ampersand — NixOS setup walkthrough](https://www.youtube.com/watch?v=nLwbNhSxLd4)

## Nix Language

- [explainix](https://zaynetro.com/explainix) — hover over Nix syntax to see what it means
- [inherit keyword](https://www.ersocon.net/articles/master-nix-inherit-keyword-in-5-minutes~c464b126-0d57-4971-9a87-2515f9aa8d19)

## High-Level Libraries

- [flake-utils](https://github.com/numtide/flake-utils)
- [flake-parts](https://flake.parts/)
- [snowfall lib](https://snowfall.org/guides/lib/quickstart/) — this flake's directory structure is inspired by snowfall

## Updating Custom Packages

Use [nix-update](https://github.com/Mic92/nix-update):

```sh
nix-update legacyPackages.x86_64-linux.<pkg> --flake --override-filename packages/top-level/<pkg>/package.nix
```

## ZFS

- [ZFS on NixOS](https://www.return12.net/zfs-on-nixos/)
- [Basic Guide to Working with ZFS](https://somedudesays.com/2021/08/the-basic-guide-to-working-with-zfs/)
- [LevelOneTechs ZFS Guide](https://forum.level1techs.com/t/zfs-guide-for-starters-and-advanced-users-concepts-pool-config-tuning-troubleshooting/196035)
