{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
  setuptools,
  requests,
  pycryptodome,
  charset-normalizer,
  pillow,
  colorama,
}:
buildPythonApplication rec {
  pname = "xiaomi-cloud-tokens-extractor";
  version = "1.5.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "PiotrMachowski";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-db/EVCwX+s+Ki/5592Q31PdCZoz3aHsm1PWoi8opxJ4=";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    pycryptodome
    charset-normalizer
    pillow
    colorama
  ];

  postPatch = ''
    cat > pyproject.toml << EOF
    [project]
    name = "${pname}"
    version = "${version}"
    description = "${meta.description}"
    readme = "README.md"
    requires-python = ">=3.9,<4.0"
    license = { file = "LICENSE" }
    authors = [{ name = "Piotr Machowski" }]
    dynamic = ["dependencies"]
    [tool.setuptools.dynamic]
    dependencies = { file = "requirements.txt" }

    [project.scripts]
    tokens-extractor = "token_extractor:main"

    [build-system]
    requires = ["setuptools>=61.0"]
    build-backend = "setuptools.build_meta"
    EOF
  '';

  meta = with lib; {
    description = "Retrieves tokens for all devices connected to Xiaomi cloud and encryption keys for BLE devices";
    homepage = "https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor";
    changelog = "https://github.com/PiotrMachowski/Xiaomi-cloud-tokens-extractor/releases/tag/v${version}";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ arunoruto ];
    mainProgram = "tokens-extractor";
  };
}
