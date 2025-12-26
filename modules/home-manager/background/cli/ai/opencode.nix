{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    # ./opencode-theme.nix
  ];

  config = lib.mkIf config.programs.opencode.enable {
    programs.opencode = {
      package = pkgs.unstable.opencode.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];

        postInstall = (old.postInstall or "") + ''
          substituteInPlace "$out/lib/opencode/dist/src/index.js" \
            --replace-fail 'https://desktop.opencode.ai' 'https://app.opencode.ai' \
            --replace-fail 'host: "desktop.opencode.ai"' 'host: "app.opencode.ai"' \
            --replace-fail '}).use(cors()).get("/global/event", describeRoute({' '}).use(cors()).get("/global/health", (c2) => c2.json({ healthy: true })).get("/global/event", describeRoute({' \
            --replace-fail '// src/file/watcher.ts' $'var OPENCODE_LIBC = process.env.OPENCODE_LIBC;\n\n// src/file/watcher.ts' \
            --replace-fail $'        stream2.writeSSE({\n          data: JSON.stringify({\n            type: "server.connected",\n            properties: {}\n          })\n        });' $'        stream2.writeSSE({\n          data: JSON.stringify({\n            payload: {\n              type: "server.connected",\n              properties: {}\n            }\n          })\n        });' \
            --replace-fail $'          stream2.writeSSE({\n            data: JSON.stringify({\n              type: "server.heartbeat",\n              properties: {}\n            })\n          });' $'          stream2.writeSSE({\n            data: JSON.stringify({\n              payload: {\n                type: "server.heartbeat",\n                properties: {}\n              }\n            })\n          });' \
            --replace-fail $'        const unsub = Bus.subscribeAll(async (event) => {\n          await stream2.writeSSE({\n            data: JSON.stringify(event)\n          });\n          if (event.type === Bus.InstanceDisposed.type) {\n            stream2.close();\n          }\n        });' $'        const unsub = Bus.subscribeAll(async (event) => {\n          await stream2.writeSSE({\n            data: JSON.stringify({ payload: event })\n          });\n          if (event.type === Bus.InstanceDisposed.type) {\n            stream2.close();\n          }\n        });'

           # Bun's node_modules layout stores @parcel watcher variants under .bun.
           # Some code paths require() @parcel/watcher-<platform>-<arch>-<libc> directly.
           mkdir -p "$out/lib/opencode/node_modules/@parcel"
           for libc in glibc musl; do
             for arch in x64 arm64 arm; do
               dest="$out/lib/opencode/node_modules/@parcel/watcher-linux-''${arch}-''${libc}"
               if [ ! -e "$dest" ]; then
                 src="$(echo "$out/lib/opencode/node_modules/.bun/@parcel+watcher-linux-''${arch}-''${libc}@"*/node_modules/@parcel/watcher-linux-''${arch}-''${libc} | head -n1)"
                 if [ -e "$src" ]; then
                   ln -s "$src" "$dest"
                 fi
               fi
             done
           done


          wrapProgram "$out/bin/opencode" \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]}"
        '';
      });
      settings = {
        theme = "stylix";
        # tools = {
        #   bash = true;
        #   edit = true;
        #   write = true;
        #   read = true;
        #   grep = true;
        #   glob = true;
        #   list = true;
        # };
        provider.ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama";
          # options.baseURL = "http://madara.king-little.ts.net:11434/v1";
          options.baseURL = lib.mkDefault config.programs.ollama.defaultPath;
          models = {
            "ministral-3:3b" = {
              name = "Ministral - Mini";
              tool_call = true;
            };
            "ministral-3:8b" = {
              name = "Ministral - Midi";
              tool_call = true;
            };
            "ministral-3:14b" = {
              name = "Ministral - Maxi";
              tool_call = true;
            };
            "gemma3:4b" = {
              name = "Gemma3 Mini";
              tool_call = false;
            };
            "gemma3:12b" = {
              name = "Gemma3";
              tool_call = false;
            };
            "deepseek-r1:14b" = {
              name = "DeepSeek-R1";
              # tools = true;
              reasoning = true;
            };
            "qwen3:14b" = {
              name = "Qwen3";
              tools = true;
              reasoning = true;
            };
          };
        };
        permission = {
          edit = "ask";
          bash = {
            ls = "allow";
            pwd = "allow";
            "git status" = "allow";
            "git diff*" = "allow";
            "git log*" = "allow";
            # "git add*" = "allow";
          };
        };
        agent = {
          autoaccept = {
            mode = "primary";
            tools = {
              write = true;
              edit = true;
              bash = true;
            };
            permission = {
              edit = "allow";
            };
          };
        };
        plugin = [ "opencode-gemini-auth@latest" ];
      };
      agents = {
        commit = ./commit.md;
      };
      enableMcpIntegration = true;
    };
  };
}
