{ mkTarget, ... }:
mkTarget {
  config =
    { colors }:
    {
      programs.pi = {
        settings.theme = "stylix";
        themes.stylix = with colors.withHashtag; {
          "$schema" =
            "https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
          name = "stylix";
          colors = {
            accent = base0F;
            border = base02;
            borderAccent = base03;
            borderMuted = base02;
            success = base0B;
            error = base08;
            warning = base0A;
            muted = base04;
            dim = base03;
            text = "";
            thinkingText = base04;

            selectedBg = base02;
            userMessageBg = base01;
            userMessageText = "";
            customMessageBg = base02;
            customMessageText = "";
            customMessageLabel = base0D;
            toolPendingBg = base00;
            toolSuccessBg = base01;
            toolErrorBg = base02;
            toolTitle = base0F;
            toolOutput = "";

            mdHeading = base0F;
            mdLink = base0D;
            mdLinkUrl = base0C;
            mdCode = base0B;
            mdCodeBlock = "";
            mdCodeBlockBorder = base03;
            mdQuote = base04;
            mdQuoteBorder = base03;
            mdHr = base03;
            mdListBullet = base0C;

            toolDiffAdded = base0B;
            toolDiffRemoved = base08;
            toolDiffContext = base04;

            syntaxComment = base04;
            syntaxKeyword = base0E;
            syntaxFunction = base0D;
            syntaxVariable = base07;
            syntaxString = base0B;
            syntaxNumber = base09;
            syntaxType = base0A;
            syntaxOperator = base0C;
            syntaxPunctuation = base05;

            thinkingOff = base02;
            thinkingMinimal = base03;
            thinkingLow = base0D;
            thinkingMedium = base0C;
            thinkingHigh = base0E;
            thinkingXhigh = base08;

            bashMode = base09;
          };
          export = {
            pageBg = base00;
            cardBg = base01;
            infoBg = base02;
          };
        };
      };
    };
}
