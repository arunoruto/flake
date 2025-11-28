{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  # playwright,

  skipBrowserDownload ? true,
}:
buildNpmPackage (finalAttrs: {
  pname = "docs-mcp-server";
  version = "1.29.0";

  src = fetchFromGitHub {
    owner = "arabold";
    repo = "docs-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eQzKziJCy963uRQKtdjj1Ob8U4iG1Z1folso2K0Xx/I=";
  };

  npmDepsHash = "sha256-uSzsXBpzFthF9klmsTcNpkhVDroT0KuOHduXSxUJaeQ=";

  nativeBuildInputs = lib.optionals skipBrowserDownload [ makeWrapper ];
  # buildInputs = [ playwright ];

  postInstall = lib.optionalString skipBrowserDownload ''
    wrapProgram $out/bin/docs-mcp-server \
      --set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1
  '';
  # postInstall =
  #   let
  #     browsers = (builtins.fromJSON (builtins.readFile "${playwright}/browsers.json")).browsers;
  #     chromium-rev = (builtins.head (builtins.filter (x: x.name == "chromium") browsers)).revision;
  #   in
  #   ''
  #     wrapProgram $out/bin/docs-mcp-server \
  #       --set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD 1 \
  #       --set PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH "${playwright.browsers}/chromium-${chromium-rev}/chrome-linux/chrome"
  #   '';

  meta = {
    description = "Grounded Docs MCP Server: Enhance Your AI Coding Assistant ";
    homepage = "https://grounded.tools/";
    mainProgram = "docs-mcp-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ arunoruto ];
  };
})
