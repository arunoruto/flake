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
  version = "1.31.0";

  src = fetchFromGitHub {
    owner = "arabold";
    repo = "docs-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+u57wCzMWDbeRXQ//XeyHrZPtGJe7nxsTyHitOD5/n8=";
  };

  npmDepsHash = "sha256-ZIKhgLurWjV1m9blEsXtsz7UeI+qrHANvBOpPiV+piY=";

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
