{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.arr.radarr.enable = lib.mkEnableOption "Enable sensible radarr settings";

  config = lib.mkIf config.services.arr.radarr.enable {
    services =
      let
        cfg = config.services.media;
      in
      {
        radarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.radarr;
          dataDir = lib.mkDefault "${cfg.dataDir}/radarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
          environmentFiles = lib.mkDefault [
            (pkgs.writeTextFile {
              name = "radarr-env";
              text = ''
                RADARR__AUTH__METHOD=External
              '';
            }).outPath
          ];
        };
        recyclarr.configuration.radarr = lib.optionalAttrs config.services.radarr.enable {
          movies = {
            api_key._secret = config.sops.secrets."tokens/arr/radarr".path;
            base_url = "http://localhost:${builtins.toString config.services.radarr.settings.server.port}";
            custom_formats = [
              {
                trash_ids = [
                  # [No Category]
                  "5153ec7413d9dae44e24275589b5e944" # BHDStudio
                  "e098247bc6652dd88c76644b275260ed" # FLUX
                  "ff5bc9e8ce91d46c997ca3ac6994d6f8" # FraMeSToR
                  "7a0d1ad358fee9f5b074af3ef3f9d9ef" # hallowed
                  "8cd3ac70db7ac318cf9a0e01333940a4" # SiC

                  # Anime
                  "fb3ccc5d5cc8f77c9055d4cb4561dded" # Anime BD Tier 01 (Top SeaDex Muxers)
                  "66926c8fa9312bc74ab71bf69aae4f4a" # Anime BD Tier 02 (SeaDex Muxers)
                  "fa857662bad28d5ff21a6e611869a0ff" # Anime BD Tier 03 (SeaDex Muxers)
                  "f262f1299d99b1a2263375e8fa2ddbb3" # Anime BD Tier 04 (SeaDex Muxers)
                  "ca864ed93c7b431150cc6748dc34875d" # Anime BD Tier 05 (Remuxes)
                  "9dce189b960fddf47891b7484ee886ca" # Anime BD Tier 06 (FanSubs)
                  "1ef101b3a82646b40e0cab7fc92cd896" # Anime BD Tier 07 (P2P/Scene)
                  "6115ccd6640b978234cc47f2c1f2cadc" # Anime BD Tier 08 (Mini Encodes)
                  "b0fdc5897f68c9a68c70c25169f77447" # Anime LQ Groups
                  "06b6542a47037d1e33b15aa3677c2365" # Anime Raws
                  "8167cffba4febfb9a6988ef24f274e7e" # Anime Web Tier 01 (Muxers)
                  "8526c54e36b4962d340fce52ef030e76" # Anime Web Tier 02 (Top FanSubs)
                  "de41e72708d2c856fa261094c85e965d" # Anime Web Tier 03 (Official Subs)
                  "9edaeee9ea3bcd585da9b7c0ac3fc54f" # Anime Web Tier 04 (Official Subs)
                  "22d953bbe897857b517928f3652b8dd3" # Anime Web Tier 05 (FanSubs)
                  "a786fbc0eae05afe3bb51aee3c83a9d4" # Anime Web Tier 06 (FanSubs)
                  "c259005cbaeb5ab44c06eddb4751e70c" # v0
                  "5f400539421b8fcf71d51e6384434573" # v1
                  "3df5e6dfef4b09bb6002f732bed5b774" # v2
                  "db92c27ba606996b146b57fbe6d09186" # v3
                  "d4e5e842fad129a3c097bdb2d20d31a0" # v4

                  # Anime Optional
                  "a5d148168c4506b55cf53984107c396e" # 10bit
                  "4a3b087eea2ce012fcc1ce319259a3be" # Anime Dual Audio
                  "b23eae459cc960816f2d6ba84af45055" # Dubs Only
                  "064af5f084a0a24458cc8ecd3220f93f" # Uncensored

                  # Anime Streaming Services
                  "60f6d50cbd3cfc3e9a8c00e3a30c3114" # VRV

                  # Asian Streaming Services
                  "917d1f2c845b2b466036b0cc2d7c72a3" # FOD
                  "834b2c0ba0a8596029b4479a29e1a032" # HTSR
                  "f1b0bae9bc222dab32c1b38b5a7a1088" # TVer
                  "26df36e3d2a96de2f8b7166ae37d3c33" # TVING
                  "279bda7434fd9075786de274e6c3c202" # "UEXT"
                  "1b355ff093fd1064b75ea98c616881b1" # VIU

                  # Audio Channels
                  "b124be9b146540f8e62f98fe32e49a2a" # 1.0 Mono
                  "89dac1be53d5268a7e10a19d3c896826" # 2.0 Stereo
                  "205125755c411c3b8622ca3175d27b37" # 3.0 Sound
                  "373b58bd188fc00c817bd8c7470ea285" # 4.0 Sound
                  "77ff61788dfe1097194fd8743d7b4524" # 5.1 Surround
                  "6fd7b090c3f7317502ab3b63cc7f51e3" # 6.1 Surround
                  "e77382bcfeba57cb83744c9c5449b401" # 7.1 Surround

                  # Audio Formats
                  "240770601cc226190c367ef59aba7463" # AAC
                  "417804f7f2c4308c1f4c5d380d4c4475" # ATMOS (undefined)
                  "c2998bd0d90ed5621d8df281e839436e" # DD
                  "185f1dd7264c4562b9022d963ac37424" # DD+
                  "1af239278386be2919e1bcee0bde047e" # DD+ ATMOS
                  "1c1a4c5e823891c75bc50380a6866f73" # DTS
                  "2f22d89048b01681dde8afe203bf2e95" # DTS X
                  "f9f847ac70a0af62ea4a08280b859636" # DTSS
                  "8e109e50e0a0b83a5098b056e13bf6db" # "DTSD" HRA
                  "dcf3ec6938fa32445f590a4da84256cd" # "DTSD" MA
                  "a570d4a0e56a2874b64e5bfa55202a1b" # FLAC
                  "6ba9033150e7896bdc9ec4b44f2b230f" # MP3
                  "a061e2e700f81932daf888599f8a8273" # Opus
                  "e7c2fcae07cbada050a0af3357491d7b" # PCM
                  "3cafb66171b47f226146a0770576870f" # TrueHD
                  "496f355514737f7d83bf7aa4d24f8169" # TrueHD ATMOS

                  # General Streaming Services
                  "b3b3a6ac74ecbd56bcdbefa4799fb9df" # AMZN
                  "40e9380490e748672c2522eaaeb692f7" # ATVP
                  "cc5e51a9e85a6296ceefe097a77f12f4" # BCORE
                  "16622a6911d1ab5d5b8b713d5b0036d4" # CRiT
                  "84272245b2988854bfb76a16e60baea5" # DSNP
                  "509e5f41146e278f9eab1ddaceb34515" # HBO
                  "5763d1b0ce84aff3b21038eea8e9b8ad" # HMAX
                  "526d445d4c16214309f0fd2b3be18a89" # Hulu
                  "e0ec9672be6cac914ffad34a6b077209" # iT
                  "2a6039655313bf5dab1e43523b62c374" # MA
                  "6a061313d22e51e0f25b7cd4dc065233" # MAX
                  "170b1d363bd8516fbf3a3eb05d4faff6" # NF
                  "c9fd353f8f5f1baf56dc601c4cb29920" # PCOK
                  "e36a0ba1bc902b26ee40818a1d59b8bd" # PMTP
                  "c2863d2a50c9acad1fb50e53ece60817" # STAN

                  # German Miscellaneous
                  "3bc8df3a71baaac60a31ef696ea72d36" # German 1080p Booster
                  "cc7b1e64e2513a6a271090cdfafaeb55" # German 2160p Booster
                  "263943bc5d99550c68aad0c4278ba1c7" # German LQ
                  "a826ee9e46607bc61795c85a6f2b1279" # German LQ (release title)
                  "03c430f326f10a27a9739b8bc83c30e4" # German Microsized
                  "c465ccc73923871b3eb1802042331306" # Line/Mic Dubbed

                  # German Source Groups
                  "54795711b78ea87e56127928c423689b" # German Bluray Tier 01
                  "1bfc773c53283d47c68e535811da30b7" # German Bluray Tier 02
                  "aee01d40cd1bf4bcded81ee62f0f3659" # German Bluray Tier 03
                  "8608a2ed20c636b8a62de108e9147713" # German Remux Tier 01
                  "f9cf598d55ce532d63596b060a6db9ee" # German Remux Tier 02
                  "2d136d4e33082fe573d06b1f237c40dd" # German Scene
                  "a2ab25194f463f057a5559c03c84a3df" # German Web Tier 01
                  "08d120d5a003ec4954b5b255c0691d79" # German Web Tier 02
                  "439f9d71becaed589058ec949e037ff3" # German Web Tier 03

                  # HDR Formats
                  "58d6a88f13e2db7f5059c41047876f00" # DV
                  "e23edd2482476e595fb990b12e7c609c" # DV HDR10
                  "c53085ddbd027d9624b320627748612f" # DV HDR10+
                  "55d53828b9d81cbe20b02efd00aa0efd" # DV HLG
                  "a3e19f8f627608af0211acd02bf89735" # DV SDR
                  "e61e28db95d22bedcadf030b8f156d96" # HDR
                  "2a4d9069cc1fe3242ff9bdaebed239bb" # HDR (undefined)
                  "dfb86d5941bc9075d6af23b09c2aeecd" # HDR10
                  "b974a6cd08c1066250f1f177d7aa1225" # HDR10+
                  "9364dd386c9b4a1100dde8264690add7" # HLG
                  "08d6d8834ad9ec87b1dc7ec8148e7a1f" # PQ

                  # HDR Optional
                  "f700d29429c023a5734505e77daeaea7" # DV (Disk)
                  "923b6abef9b17f937fab56cfcf89e1f1" # DV (WEBDL)
                  "55a5b50cb416dea5a50c4955896217ab" # DV HDR10+ Boost
                  "b17886cb4158d9fea189859409975758" # HDR10+ Boost
                  "9c38ebb7384dada637be8899efa68e6f" # SDR
                  "25c12f78430a3a23413652cbd1d48d77" # SDR (no WEBDL)

                  # HQ Release Groups
                  "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
                  "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
                  "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
                  "3a3ff47579026e76d6504ebea39390de" # Remux Tier 01
                  "9f98181fe5a3fbeb0cc29340da2a468a" # Remux Tier 02
                  "8baaf0b3142bf4d94c42a724f034e27a" # Remux Tier 03
                  "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
                  "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
                  "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
                  "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
                  "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
                  "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03

                  # Language profiles
                  "86bc3115eb4e9873ac96904a4a68e19e" # German
                  "f845be10da4f442654c13e1f2c3d6cd5" # German DL
                  "6aad77771dabe9d3e9d7be86f310b867" # German DL (undefined)
                  "0dc8aec3bd1c47cd6c40c46ecd27e846" # Language: Not English
                  "533f782474f0819643c2ec0c1eeeb0ac" # Language: Not French
                  "d6e9318c875905d6cfb5bee961afcea9" # Language: Not Original
                  "0542a48746585dc4444bbbb8a6bdf6ea" # Language: Original + French
                  "4eadb75fb23d09dfc0a8e3f687e72287" # Not German or English

                  # Misc Streaming Services
                  "3bf143ecd06f66ed88da4c704350af1d" # AUBC
                  "d9058beaae2e147183870304dd526761" # CBC
                  "f6ff65b3f4b464a79dcc75950fe20382" # CRAV
                  "fbca986396c5e695ef7b2def3c755d01" # OViD
                  "ab56ccdc473a1f2897c76187ea365be2" # STRP

                  # Miscellaneous
                  "820b09bb9acbfde9c35c71e0e565dad8" # 1080p
                  "fb392fb0d61a010ae38e49ceaa24a1ef" # 2160p
                  "b2be17d608fc88818940cd1833b0b24c" # 720p
                  "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
                  "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
                  "9de657fd3d327ecf144ec73dfe3a3e9a" # Dutch Groups
                  "0d91270a7255a1e388fa85e959f359d8" # FreeLeech
                  "73613461ac2cea99d52c4cd6e177ab82" # HFR
                  "182fa1c42a2468f8488e6dcf75a81b81" # INTERNAL
                  "ff86c4326018682f817830ced463332b" # MPEG2
                  "4b900e171accbfb172729b63323ea8ca" # MULTi
                  "ae9b7c9ebde1f3bd336a8cbd1ec4c5e5" # "NolsGroup"
                  "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
                  "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
                  "ae43b294509409a6a13919dedd4764c4" # Repack2
                  "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3
                  "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
                  "f537cf427b64c38c8e36298f657e4828" # Scene
                  "11cd1db7165d6a7ad9a83bc97b8b1060" # VC
                  "ae4cfaa9283a4f2150ac3da08e388723" # VP9
                  "2899d84dc9372de3408e6d8cc18e9666" # x264
                  "9170d55c319f4fe40da8711ba9d8050d" # x265
                  "839bea857ed2c0a8e084f3cbdbd65ecb" # x265 (no HDR/DV)
                  "390455c22a9cac81a738f6cbad705c3c" # x266

                  # Movie Versions
                  "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                  "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                  "0f12c086e289cf966fa5948eac571f44" # Hybrid
                  "eecf3a857724171f968a66cb5719e152" # IMAX
                  "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
                  "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                  "09d9dd29a0fc958f9796e65c2a8864b4" # Open Matte
                  "570bc9ebecd92723d2d21500f4be314c" # Remaster
                  "957d0f44b592285f26449575e8b1167e" # Special Edition
                  "e9001909a4c88013a359d0b9920d7bea" # Theatrical Cut
                  "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome

                  # UK Streaming Services
                  "6185878161f1e2eef9cd0641a0d09eae" # IP
                  "c3492a26af412e385404eade438ec51c" # ITVX
                  "eacd2cb6c6d4a93e459df2cec6d7b97a" # MY5
                  "3dce1fce9ac06d1349dfbd9186289385" # NOW

                  # Unwanted
                  "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
                  "cae4ca30163749b891686f95532519bd" # AV1
                  "ed38b889b31be83fda192888e2286d83" # "BRISK"
                  "0a3f082873eb454bde444150b70253cc" # Extras
                  "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
                  "90a6f9a284dff5103f6346090e6280c8" # LQ
                  "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
                  "712d74cd88bceb883ee32f773656b1f5" # "Singlong" Versions
                  "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
                  "dc98083864ea246d05a42df0d05f81cc" # x265 (HD)
                ];
              }
            ];
          };
        };
      };

    users.users.radarr.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

    sops.secrets."tokens/arr/radarr" = {
      mode = "0660";
      inherit (config.services.recyclarr) group;
    };
  };
}
