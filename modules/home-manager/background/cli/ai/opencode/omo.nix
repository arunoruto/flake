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
          400
          429
          503
          529
        ]; # Explicitly catch rate limits
        max_fallback_attempts = 3;
        cooldown_seconds = 60; # Let Go cool down before retrying
        notify_on_fallback = true;
      };

      hashline_edit = true;

      fallback_models = [
        "github-copilot/gpt-5.3-codex"
        "github-copilot/gpt-5-mini" # 0x fallback safety net
      ];

      experimental = {
        disable_omo_env = true; # Massively improves Context Caching!

        dynamic_context_pruning = {
          enabled = true;
          notification = "minimal";
          turn_protection = {
            enabled = true;
            turns = 3; # Keep the last 3 turns intact
          };
          strategies = {
            deduplication.enabled = true; # Stop paying for duplicate tool reads
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
        # Core workers: Using OpenCode Go for massive context
        sisyphus = {
          model = "opencode-go/kimi-k2.5";
          variant = "max";
        };

        hephaestus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
        };

        oracle = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "high";
        };

        # 0x Utility Agents: Unlimited free background processing
        explore.model = "github-copilot/raptor-mini";
        multimodal-looker.model = "github-copilot/gpt-5-mini";

        # Planners
        prometheus = {
          model = "opencode-go/glm-5.1";
          variant = "max";
        };

        metis = {
          model = "opencode-go/glm-5.1";
          variant = "max";
        };

        momus = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "xhigh";
        };

        atlas.model = "opencode-go/kimi-k2.5";
        sisyphus-junior.model = "opencode-go/kimi-k2.5";
      };

      categories = {
        visual-engineering = {
          model = "github-copilot/gemini-3.1-pro";
          variant = "high";
        };

        ultrabrain = {
          model = "opencode-go/glm-5.1";
          variant = "high";
        };

        deep = {
          model = "github-copilot/gpt-5.3-codex";
          variant = "medium";
        };

        artistry = {
          model = "github-copilot/gemini-3.1-pro";
          variant = "high";
        };

        # 0x Categories: Rapid-fire tasks cost nothing
        quick.model = "github-copilot/gpt-5-mini";

        unspecified-low.model = "github-copilot/gpt-5-mini";
        unspecified-high.model = "opencode-go/kimi-k2.5";

        # 0.33x Category: Ultra-cheap documentation generation
        writing.model = "github-copilot/claude-haiku-4.5";
      };
    };
  };
}
