{ pkgs, ... }:
{
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./configs/kitty.conf;
  };

  programs.hyprland = {
    enable = true;
    extraConfig = builtins.readFile Freyix/configs/hyprland.lua;
  };

  programs.librewolf = {
    enable = true;
    settings = {
      # Keep logins and history across restarts (optional)
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "network.cookie.lifetimePolicy" = 0;

      # Relax fingerprinting protection if sites break or force light mode
      "privacy.resistFingerprinting" = false;
      "webgl.disabled" = false;
    };
  };

  programs.vscode = {
    enable = true;
    # FHS wrapper: extensions that ship their own binaries (rust-analyzer, ruff, sumneko lua, terraform-ls)
    # run unmodified on NixOS, and the tools below are on PATH inside the editor.
    package = pkgs.vscodium.fhsWithPackages (
      ps: with ps; [
        ruff
        terraform
        terraform-ls
        clang-tools # clangd
        cppcheck # c-cpp-flylint
        shellcheck
        nixd
        nixfmt
        iverilog
        verilator
        cargo
        rustc
        clippy
        rustfmt
        lua-language-server
      ]
    );
    mutableExtensionsDir = false;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      userSettings =
        let
          vl = "${pkgs.verilator}/share/verilator/include";
          incs = [
            vl
            "${vl}/vltstd"
            "\${workspaceFolder}/obj_dir"
            "\${workspaceFolder}"
          ];
        in
        (builtins.fromJSON (builtins.readFile ../../configs/vscodium/settings.json))
        // {
          "c-cpp-flylint.cppcheck.includePaths" = incs;
          "c-cpp-flylint.includePaths" = incs;
          "Lua.workspace.library" = [ "${pkgs.hyprland}/share/hypr/stubs" ];
          "terraform.languageServer.pathToBinary" = "terraform-ls";
        };
      keybindings = builtins.fromJSON (builtins.readFile ../../configs/vscodium/keybindings.json);
      extensions = with pkgs.open-vsx; [
        charliermarsh.ruff
        hashicorp.terraform
        jbenden.c-cpp-flylint
        jnoortheen.nix-ide
        llvm-vs-code-extensions.vscode-clangd
        mshr-h.veriloghdl
        rust-lang.rust-analyzer
        sumneko.lua
        timonwong.shellcheck
      ];
    };
  };
}