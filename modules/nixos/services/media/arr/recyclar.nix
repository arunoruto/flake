{
  config,
  lib,
  pkgs,
  ...
}:
let
  resetUnmatchedScores = {
    enabled = true;
  };

  radarrUnwantedFormats = {
    trash_id = "a3ac6af01d78e4f21fcb75f601ac96df"; # [Unwanted] Unwanted Formats
    select = [
      "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
      "cae4ca30163749b891686f95532519bd" # AV1
      "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
      "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
      "ed38b889b31be83fda192888e2286d83" # BR-DISK
      "0a3f082873eb454bde444150b70253cc" # Extras
      "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
      "90a6f9a284dff5103f6346090e6280c8" # LQ
      "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
      "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
      "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
    ];
  };

  sonarrUnwantedFormats = {
    trash_id = "59c3af66780d08332fdc64e68297098f"; # [Unwanted] Unwanted Formats
    select = [
      "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
      "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
      "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
      "6f808933a71bd9666531610cb8c059cc" # BR-DISK (BTN)
      "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
      "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
      "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
      "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
    ];
  };
in
{
  config = lib.mkIf config.services.arr.enable {
    services.recyclarr = {
      enable = lib.mkDefault true;
      package = lib.mkDefault pkgs.unstable.recyclarr;
      configuration = {
        radarr = {
          movies = {
            api_key._secret = config.sops.secrets."tokens/arr/radarr".path;
            base_url = "http://localhost:${builtins.toString config.services.radarr.settings.server.port}";
            delete_old_custom_formats = true;

            # Quality definitions are instance-wide. This instance mixes German
            # movie profiles with anime, so leave size sliders user-managed.
            quality_profiles = [
              {
                trash_id = "2b90e905c99490edc7c7a5787443748b"; # [German] HD Bluray + WEB
                reset_unmatched_scores = resetUnmatchedScores;
              }
              {
                trash_id = "27cc3d153c0a799fd139ef1ff4c4cc42"; # [German] UHD Bluray + WEB
                reset_unmatched_scores = resetUnmatchedScores;
              }
              {
                trash_id = "722b624f9af1e492284c4bc842153a38"; # [Anime] Remux-1080p
                reset_unmatched_scores = resetUnmatchedScores;
              }
            ];

            custom_format_groups = {
              add = [
                {
                  trash_id = "f8bf8eab4617f12dfdbd16303d8da245"; # [Optional] Golden Rule HD
                  select = [
                    "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                  ];
                }
                {
                  trash_id = "ff204bbcecdd487d1cefcefdbf0c278d"; # [Optional] Golden Rule UHD
                  select = [
                    "839bea857ed2c0a8e084f3cbdbd65ecb" # x265 (no HDR/DV)
                  ];
                }
                radarrUnwantedFormats
                {
                  trash_id = "bc85e56ee3bd0f01467866d5f1261543"; # [Release Groups] German
                  select = [
                    "8608a2ed20c636b8a62de108e9147713" # German Remux Tier 01
                    "f9cf598d55ce532d63596b060a6db9ee" # German Remux Tier 02
                    "54795711b78ea87e56127928c423689b" # German Bluray Tier 01
                    "1bfc773c53283d47c68e535811da30b7" # German Bluray Tier 02
                    "aee01d40cd1bf4bcded81ee62f0f3659" # German Bluray Tier 03
                    "a2ab25194f463f057a5559c03c84a3df" # German Web Tier 01
                    "08d120d5a003ec4954b5b255c0691d79" # German Web Tier 02
                    "439f9d71becaed589058ec949e037ff3" # German Web Tier 03
                    "2d136d4e33082fe573d06b1f237c40dd" # German Scene
                  ];
                }
              ];
            };
          };
        };

        sonarr = {
          series = {
            api_key._secret = config.sops.secrets."tokens/arr/sonarr".path;
            base_url = "http://localhost:${builtins.toString config.services.sonarr.settings.server.port}";
            delete_old_custom_formats = true;

            # Quality definitions are instance-wide. This instance mixes German
            # series profiles with anime, so leave size sliders user-managed.
            quality_profiles = [
              {
                trash_id = "dca7e5e9e99c703bcbdaaa471dd40e98"; # [German] HD Bluray + WEB
                reset_unmatched_scores = resetUnmatchedScores;
              }
              {
                trash_id = "3b0fa37fddaaefc931b75f2889d4b4f5"; # [German] UHD Bluray + WEB
                reset_unmatched_scores = resetUnmatchedScores;
              }
              {
                trash_id = "20e0fc959f1f1704bed501f23bdae76f"; # [Anime] Remux-1080p
                reset_unmatched_scores = resetUnmatchedScores;
              }
            ];

            custom_format_groups = {
              add = [
                {
                  trash_id = "158188097a58d7687dee647e04af0da3"; # [Optional] Golden Rule HD
                  select = [
                    "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                  ];
                }
                {
                  trash_id = "e3f37512790f00d0e89e54fe5e790d1c"; # [Optional] Golden Rule UHD
                  select = [
                    "9b64dff695c2115facf1b6ea59c9bd07" # x265 (no HDR/DV)
                  ];
                }
                sonarrUnwantedFormats
              ];
            };
          };
        };
      };
    };

    users.users.recyclarr.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];
  };
}
