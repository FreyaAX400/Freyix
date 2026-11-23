{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.freyix.coding;
in
{
  options.freyix.coding.enable = lib.mkEnableOption "VSCodium and language tooling";

  config = lib.mkIf cfg.enable {
    programs.vscodium = {
      enable = true;
      package = pkgs.vscodium.fhsWithPackages (
        ps: with ps; [
          ruff
          terraform
          terraform-ls
          clang-tools
          cppcheck
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
            "terraform.languageServer.pathToBinary" = "terraform-ls";
          }
          // lib.optionalAttrs config.freyix.desktop.enable {
            # LuaLS stubs for editing configs/hyprland.lua
            "Lua.workspace.library" = [ "${pkgs.hyprland}/share/hypr/stubs" ];
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
  };
}
