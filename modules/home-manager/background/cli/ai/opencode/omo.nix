{ ... }:
{
  programs.opencode = {
    omo.settings = {
      sisyphus_agent = {
        disabled = false;
        planner_enabled = true;
        replace_plan = true;
      };

      runtime_fallback = {
        enabled = true;
        retry_on_errors = [
          429
          503
          529
        ];
        max_fallback_attempts = 2;
        cooldown_seconds = 90;
        timeout_seconds = 0;
        notify_on_fallback = true;
      };

      hashline_edit = true;

      fallback_models = [
        "github-copilot/gpt-5.3-codex"
        "github-copilot/gpt-5-mini"
      ];

      background_task = {
        defaultConcurrency = 4;
        providerConcurrency = {
          "opencode-go" = 1;
          "github-copilot" = 8;
        };
        modelConcurrency = {
          "opencode-go/kimi-k2.5" = 1;
          "github-copilot/gpt-5.3-codex" = 4;
          "github-copilot/gpt-5-mini" = 12;
        };
      };

      experimental = {
        disable_omo_env = true;

        dynamic_context_pruning = {
          enabled = true;
          notification = "minimal";
          turn_protection = {
            enabled = true;
            turns = 3;
          };
          strategies = {
            deduplication.enabled = true;
            supersede_writes = {
              enabled = true;
              aggressive = true;
            };
            purge_errors = {
              enabled = true;
              turns = 3;
            };
          };
        };
      };

      agents = {
        sisyphus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "high";
          fallback_models = [
            "opencode-go/kimi-k2.5"
            "github-copilot/gpt-5-mini"
          ];
        };

        hephaestus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
        };

        oracle = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "high";
        };

        explore.model = "github-copilot/raptor-mini";
        multimodal-looker.model = "github-copilot/gpt-5-mini";

        prometheus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
        };

        metis = {
          model = "github-copilot/gpt-5-mini";
          variant = "medium";
        };

        momus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "xhigh";
        };

        atlas.model = "github-copilot/gpt-5-mini";
        sisyphus-junior.model = "github-copilot/gpt-5-mini";
      };

      categories = {
        visual-engineering = {
          model = "github-copilot/gemini-3.1-pro";
          variant = "high";
        };

        ultrabrain = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "high";
          fallback_models = [
            "opencode-go/kimi-k2.5"
            "github-copilot/gpt-5-mini"
          ];
        };

        deep = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
          fallback_models = [
            "opencode-go/kimi-k2.5"
            "github-copilot/gpt-5-mini"
          ];
        };

        artistry = {
          model = "github-copilot/gemini-3.1-pro";
          variant = "high";
        };

        quick.model = "github-copilot/gpt-5-mini";

        unspecified-low.model = "github-copilot/gpt-5-mini";
        unspecified-high = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
          fallback_models = [
            "opencode-go/kimi-k2.5"
            "github-copilot/gpt-5-mini"
          ];
        };

        writing.model = "github-copilot/claude-haiku-4.5";
      };
    };
  };
}
