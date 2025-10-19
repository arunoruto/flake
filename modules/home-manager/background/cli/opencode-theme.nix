{ config, ... }:
{
  config = {
    programs.opencode.themes = {
      stylix = {
        "$schema" = "https://opencode.ai/theme.json";
        defs = {
          inherit (config.lib.stylix.colors.withHashtag)
            base00
            base01
            base02
            base03
            base04
            base05
            base06
            base07
            base08
            base09
            base0A
            base0B
            base0C
            base0D
            base0E
            base0F
            ;
        };
        theme = {
          accent = {
            dark = "base07";
            light = "base07";
          };
          background = {
            dark = "base00";
            light = "base06";
          };
          backgroundElement = {
            dark = "base01";
            light = "base04";
          };
          backgroundPanel = {
            dark = "base01";
            light = "base05";
          };
          border = {
            dark = "base02";
            light = "base03";
          };
          borderActive = {
            dark = "base03";
            light = "base02";
          };
          borderSubtle = {
            dark = "base02";
            light = "base03";
          };
          diffAdded = {
            dark = "base0B";
            light = "base0B";
          };
          diffAddedBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffAddedLineNumberBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffContext = {
            dark = "base03";
            light = "base03";
          };
          diffContextBg = {
            dark = "base01";
            light = "base05";
          };
          diffHighlightAdded = {
            dark = "base0B";
            light = "base0B";
          };
          diffHighlightRemoved = {
            dark = "base08";
            light = "base08";
          };
          diffHunkHeader = {
            dark = "base03";
            light = "base03";
          };
          diffLineNumber = {
            dark = "base02";
            light = "base04";
          };
          diffRemoved = {
            dark = "base08";
            light = "base08";
          };
          diffRemovedBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffRemovedLineNumberBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          error = {
            dark = "base08";
            light = "base08";
          };
          info = {
            dark = "base0C";
            light = "base0F";
          };
          markdownBlockQuote = {
            dark = "base03";
            light = "base03";
          };
          markdownCode = {
            dark = "base0B";
            light = "base0B";
          };
          markdownCodeBlock = {
            dark = "base04";
            light = "base00";
          };
          markdownEmph = {
            dark = "base09";
            light = "base09";
          };
          markdownHeading = {
            dark = "base0C";
            light = "base0F";
          };
          markdownHorizontalRule = {
            dark = "base03";
            light = "base03";
          };
          markdownImage = {
            dark = "base0D";

            light = "base0D";

          };
          markdownImageText = {
            dark = "base07";
            light = "base07";
          };
          markdownLink = {
            dark = "base0D";

            light = "base0D";

          };
          markdownLinkText = {
            dark = "base07";
            light = "base07";
          };
          markdownListEnumeration = {
            dark = "base07";
            light = "base07";
          };
          markdownListItem = {
            dark = "base0C";
            light = "base0F";
          };
          markdownStrong = {
            dark = "base0A";
            light = "base0A";
          };
          markdownText = {
            dark = "base04";
            light = "base00";
          };
          primary = {
            dark = "base0C";
            light = "base0F";
          };
          secondary = {
            dark = "base0D";

            light = "base0D";

          };
          success = {
            dark = "base0B";
            light = "base0B";
          };
          syntaxComment = {
            dark = "base03";
            light = "base03";
          };
          syntaxFunction = {
            dark = "base0C";
            light = "base0C";
          };
          syntaxKeyword = {
            dark = "base0D";

            light = "base0D";

          };
          syntaxNumber = {
            dark = "base0E";
            light = "base0E";
          };
          syntaxOperator = {
            dark = "base0D";

            light = "base0D";

          };
          syntaxPunctuation = {
            dark = "base04";
            light = "base00";
          };
          syntaxString = {
            dark = "base0B";
            light = "base0B";
          };
          syntaxType = {
            dark = "base07";
            light = "base07";
          };
          syntaxVariable = {
            dark = "base07";
            light = "base07";
          };
          text = {
            dark = "base04";
            light = "base00";
          };
          textMuted = {
            dark = "base03";
            light = "base01";
          };
          warning = {
            dark = "base09";
            light = "base09";
          };
        };
      };

      my-theme = {
        "$schema" = "https://opencode.ai/theme.json";
        defs = {
          nord0 = "#2E3440";
          nord1 = "#3B4252";
          nord10 = "#5E81AC";
          nord11 = "#BF616A";
          nord12 = "#D08770";
          nord13 = "#EBCB8B";
          nord14 = "#A3BE8C";
          nord15 = "#B48EAD";
          nord2 = "#434C5E";
          nord3 = "#4C566A";
          nord4 = "#D8DEE9";
          nord5 = "#E5E9F0";
          nord6 = "#ECEFF4";
          nord7 = "#8FBCBB";
          nord8 = "#88C0D0";
          nord9 = "#81A1C1";
        };
        theme = {
          accent = {
            dark = "nord7";
            light = "nord7";
          };
          background = {
            dark = "nord0";
            light = "nord6";
          };
          backgroundElement = {
            dark = "nord1";
            light = "nord4";
          };
          backgroundPanel = {
            dark = "nord1";
            light = "nord5";
          };
          border = {
            dark = "nord2";
            light = "nord3";
          };
          borderActive = {
            dark = "nord3";
            light = "nord2";
          };
          borderSubtle = {
            dark = "nord2";
            light = "nord3";
          };
          diffAdded = {
            dark = "nord14";
            light = "nord14";
          };
          diffAddedBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffAddedLineNumberBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffContext = {
            dark = "nord3";
            light = "nord3";
          };
          diffContextBg = {
            dark = "nord1";
            light = "nord5";
          };
          diffHighlightAdded = {
            dark = "nord14";
            light = "nord14";
          };
          diffHighlightRemoved = {
            dark = "nord11";
            light = "nord11";
          };
          diffHunkHeader = {
            dark = "nord3";
            light = "nord3";
          };
          diffLineNumber = {
            dark = "nord2";
            light = "nord4";
          };
          diffRemoved = {
            dark = "nord11";
            light = "nord11";
          };
          diffRemovedBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          diffRemovedLineNumberBg = {
            dark = "#3B4252";
            light = "#E5E9F0";
          };
          error = {
            dark = "nord11";
            light = "nord11";
          };
          info = {
            dark = "nord8";
            light = "nord10";
          };
          markdownBlockQuote = {
            dark = "nord3";
            light = "nord3";
          };
          markdownCode = {
            dark = "nord14";
            light = "nord14";
          };
          markdownCodeBlock = {
            dark = "nord4";
            light = "nord0";
          };
          markdownEmph = {
            dark = "nord12";
            light = "nord12";
          };
          markdownHeading = {
            dark = "nord8";
            light = "nord10";
          };
          markdownHorizontalRule = {
            dark = "nord3";
            light = "nord3";
          };
          markdownImage = {
            dark = "nord9";
            light = "nord9";
          };
          markdownImageText = {
            dark = "nord7";
            light = "nord7";
          };
          markdownLink = {
            dark = "nord9";
            light = "nord9";
          };
          markdownLinkText = {
            dark = "nord7";
            light = "nord7";
          };
          markdownListEnumeration = {
            dark = "nord7";
            light = "nord7";
          };
          markdownListItem = {
            dark = "nord8";
            light = "nord10";
          };
          markdownStrong = {
            dark = "nord13";
            light = "nord13";
          };
          markdownText = {
            dark = "nord4";
            light = "nord0";
          };
          primary = {
            dark = "nord8";
            light = "nord10";
          };
          secondary = {
            dark = "nord9";
            light = "nord9";
          };
          success = {
            dark = "nord14";
            light = "nord14";
          };
          syntaxComment = {
            dark = "nord3";
            light = "nord3";
          };
          syntaxFunction = {
            dark = "nord8";
            light = "nord8";
          };
          syntaxKeyword = {
            dark = "nord9";
            light = "nord9";
          };
          syntaxNumber = {
            dark = "nord15";
            light = "nord15";
          };
          syntaxOperator = {
            dark = "nord9";
            light = "nord9";
          };
          syntaxPunctuation = {
            dark = "nord4";
            light = "nord0";
          };
          syntaxString = {
            dark = "nord14";
            light = "nord14";
          };
          syntaxType = {
            dark = "nord7";
            light = "nord7";
          };
          syntaxVariable = {
            dark = "nord7";
            light = "nord7";
          };
          text = {
            dark = "nord4";
            light = "nord0";
          };
          textMuted = {
            dark = "nord3";
            light = "nord1";
          };
          warning = {
            dark = "nord12";
            light = "nord12";
          };
        };
      };
    };
  };
}
