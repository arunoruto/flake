pkgs: lib:
pkgs.lib.genAttrs
  [
    "go"
    "python"
    "website"
  ]
  (
    shell:
    import ./${shell}.nix {
      inherit pkgs lib;
      # inherit pkgs;
      # inherit lib;
    }
  )
# ] (shell: import ./${shell}.nix { inherit pkgs; })
