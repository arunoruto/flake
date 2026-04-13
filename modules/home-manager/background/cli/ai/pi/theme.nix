{
  config,
  lib,
  pkgs,
  ...
}:
let
  jsonFormat = pkgs.formats.json { };
  c = config.lib.stylix.colors.withHashtag;
in
{
  config = lib.mkIf config.programs.pi.enable {
    home.file.".pi/agent/themes/stylix.json".source = jsonFormat.generate "pi-theme-stylix.json" {
      "$schema" =
        "https://raw.githubusercontent.com/badlogic/pi-mono/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json";
      name = "stylix";
      colors = {
        accent = c.base0F;
        border = c.base02;
        borderAccent = c.base03;
        borderMuted = c.base02;
        success = c.base0B;
        error = c.base08;
        warning = c.base0A;
        muted = c.base04;
        dim = c.base03;
        text = "";
        thinkingText = c.base04;

        selectedBg = c.base02;
        userMessageBg = c.base01;
        userMessageText = "";
        customMessageBg = c.base02;
        customMessageText = "";
        customMessageLabel = c.base0D;
        toolPendingBg = c.base00;
        toolSuccessBg = c.base01;
        toolErrorBg = c.base02;
        toolTitle = c.base0F;
        toolOutput = "";

        mdHeading = c.base0F;
        mdLink = c.base0D;
        mdLinkUrl = c.base0C;
        mdCode = c.base0B;
        mdCodeBlock = "";
        mdCodeBlockBorder = c.base03;
        mdQuote = c.base04;
        mdQuoteBorder = c.base03;
        mdHr = c.base03;
        mdListBullet = c.base0C;

        toolDiffAdded = c.base0B;
        toolDiffRemoved = c.base08;
        toolDiffContext = c.base04;

        syntaxComment = c.base04;
        syntaxKeyword = c.base0E;
        syntaxFunction = c.base0D;
        syntaxVariable = c.base07;
        syntaxString = c.base0B;
        syntaxNumber = c.base09;
        syntaxType = c.base0A;
        syntaxOperator = c.base0C;
        syntaxPunctuation = c.base05;

        thinkingOff = c.base02;
        thinkingMinimal = c.base03;
        thinkingLow = c.base0D;
        thinkingMedium = c.base0C;
        thinkingHigh = c.base0E;
        thinkingXhigh = c.base08;

        bashMode = c.base09;
      };
      export = {
        pageBg = c.base00;
        cardBg = c.base01;
        infoBg = c.base02;
      };
    };
  };
}
