{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.arr.sonarr.enable = lib.mkEnableOption "Enable sensible sonarr settings";

  config = lib.mkIf config.services.arr.sonarr.enable {
    services =
      let
        cfg = config.services.media;
        service = "sonarr";
        url-path = "/${service}";
      in
      {
        sonarr = {
          enable = lib.mkDefault true;
          package = lib.mkDefault pkgs.unstable.sonarr;
          dataDir = lib.mkDefault "${cfg.dataDir}/sonarr";
          openFirewall = lib.mkDefault cfg.openFirewall;
          environmentFiles = lib.mkDefault [
            (pkgs.writeTextFile {
              name = "sonarr-env";
              text = ''
                SONARR__AUTH__METHOD=External
                SONARR__SERVER__URLBASE=${url-path}
              '';
            }).outPath
          ];
        };
        recyclarr.configuration.sonarr = lib.optionalAttrs config.services.sonarr.enable {
          series = {
            api_key._secret = config.sops.secrets."tokens/arr/sonarr".path;
            base_url = "http://localhost:${builtins.toString config.services.sonarr.settings.server.port}";
            custom_formats = [
              {
                trash_ids = [
                  # [No Category]
                  "6f808933a71bd9666531610cb8c059cc" # BR-DISK (BTN)
                  "5d9fd1b1e06cd8a475462f40214b7df6" # FLUX
                  "4a20cfb76b5f92a8ca22b894b32e71be" # Multi-Episode
                  "e0c1a67f23908a55b6ae9834e8ed6727" # Single Episode

                  # Anime Misc
                  "d2d7b8a9d39413da5f44054080e028a3" # v0
                  "273bd326df95955e1b6c26527d1df89b" # v1
                  "228b8ee9aa0a609463efca874524a6b8" # v2
                  "0e5833d3af2cc5fa96a0c29cd4477feb" # v3
                  "4fc15eeb8f2f9a749f918217d4234ad8" # v4

                  # Anime Optional
                  "b2550eb333d27b75833e25b8c2557b38" # 10bit
                  "418f50b10f1907201b6cfdf881f467b7" # Anime Dual Audio
                  "9c14d194486c4014d422adc64092d794" # Dubs Only
                  "026d5aadd1a6b4e550b134cb6c72b3ca" # Uncensored

                  # Anime Source Groups
                  "949c16fe0a8147f50ba82cc2df9411c9" # Anime BD Tier 01 (Top SeaDex Muxers)
                  "ed7f1e315e000aef424a58517fa48727" # Anime BD Tier 02 (SeaDex Muxers)
                  "096e406c92baa713da4a72d88030b815" # Anime BD Tier 03 (SeaDex Muxers)
                  "30feba9da3030c5ed1e0f7d610bcadc4" # Anime BD Tier 04 (SeaDex Muxers)
                  "545a76b14ddc349b8b185a6344e28b04" # Anime BD Tier 05 (Remuxes)
                  "25d2afecab632b1582eaf03b63055f72" # Anime BD Tier 06 (FanSubs)
                  "0329044e3d9137b08502a9f84a7e58db" # Anime BD Tier 07 (P2P/Scene)
                  "c81bbfb47fed3d5a3ad027d077f889de" # Anime BD Tier 08 (Mini Encodes)
                  "e3515e519f3b1360cbfc17651944354c" # Anime LQ Groups
                  "b4a1b3d705159cdca36d71e57ca86871" # Anime Raws
                  "e0014372773c8f0e1bef8824f00c7dc4" # Anime Web Tier 01 (Muxers)
                  "19180499de5ef2b84b6ec59aae444696" # Anime Web Tier 02 (Top FanSubs)
                  "c27f2ae6a4e82373b0f1da094e2489ad" # Anime Web Tier 03 (Official Subs)
                  "4fd5528a3a8024e6b49f9c67053ea5f3" # Anime Web Tier 04 (Official Subs)
                  "29c2a13d091144f63307e4a8ce963a39" # Anime Web Tier 05 (FanSubs)
                  "dc262f88d74c651b12e9d90b39f6c753" # Anime Web Tier 06 (FanSubs)

                  # Anime Streaming Services
                  "a370d974bc7b80374de1d9ba7519760b" # ABEMA
                  "d54cd2bf1326287275b56bccedb72ee2" # ADN
                  "7dd31f3dee6d2ef8eeaa156e23c3857e" # B-Global
                  "4c67ff059210182b59cdd41697b8cb08" # Bilibili
                  "3e0b26604165f463f3e8e192261e7284" # CR
                  "1284d18e693de8efe0fe7d6b3e0b9170" # FUNi
                  "570b03b3145a25011bf073274a407259" # HIDIVE
                  "44a8ee6403071dd7b8a3a8dd3fe8cb20" # VRV
                  "e5e6405d439dcd1af90962538acd4fe0" # WKN

                  # Asian Streaming Services
                  "7be9c0572d8cd4f81785dacf7e85985e" # FOD
                  "4404ad44d87ccbb82746e180713112fb" # HTSR
                  "d100ea972d1af2150b65b1cffb80f6b5" # TVer
                  "86f8d3b8761de651aa355d46d5d8db3e" # TVING
                  "0e99e7cc719a8a73b2668c3a0c3fe10c" # U-NEXT
                  "93c9d1e566dca8b34d57f5efbbf85f28" # VIU

                  # Audio Channels
                  "bd6dd5e043aa27ff4696a08d011c7d96" # 1.0 Mono
                  "834e534f103938853ffced4203b53e72" # 2.0 Stereo
                  "42cba7e38c7947a6d1d0a62580ee6d62" # 3.0 Sound
                  "1895195e84767de180653914ce207245" # 4.0 Sound
                  "3fbafa924f361e66fbc6187af82dfa85" # 5.1 Surround
                  "9fb6d778592c293467437593ef394bf1" # 6.1 Surround
                  "204c8c3e7315bb0ea81332774fa888d6" # 7.1 Surround

                  # Audio Formats
                  "a50b8a0c62274a7c38b09a9619ba9d86" # AAC
                  "b6fbafa7942952a13e17e2b1152b539a" # ATMOS (undefined)
                  "dbe00161b08a25ac6154c55f95e6318d" # DD
                  "63487786a8b01b7f20dd2bc90dd4a477" # DD+
                  "4232a509ce60c4e208d13825b7c06264" # DD+ ATMOS
                  "5964f2a8b3be407d083498e4459d05d0" # DTS
                  "9d00418ba386a083fbf4d58235fc37ef" # DTS X
                  "c1a25cd67b5d2e08287c957b1eb903ec" # DTS-ES
                  "cfa5fbd8f02a86fc55d8d223d06a5e1f" # DTS-HD HRA
                  "c429417a57ea8c41d57e6990a8b0033f" # DTS-HD MA
                  "851bd64e04c9374c51102be3dd9ae4cc" # FLAC
                  "3e8b714263b26f486972ee1e0fe7606c" # MP3
                  "28f6ef16d61e2d1adfce3156ed8257e3" # Opus
                  "30f70576671ca933adbdcfc736a69718" # PCM
                  "1808e4b9cee74e064dfae3f1db99dbfe" # TrueHD
                  "0d7824bb924701997f874e7ff7d4844a" # TrueHD ATMOS

                  # General Streaming Services
                  "d660701077794679fd59e8bdf4ce3a29" # AMZN
                  "f67c9ca88f463a48346062e8ad07713f" # ATVP
                  "77a7b25585c18af08f60b1547bb9b4fb" # CC
                  "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
                  "89358767a60cc28783cdc3d0be9388a4" # DSNP
                  "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
                  "a880d6abc21e7c16884f3ae393f84179" # HMAX
                  "f6cce30f1733d5c8194222a7507909bb" # HULU
                  "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
                  "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
                  "d34870697c9db575f17700212167be23" # NF
                  "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
                  "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
                  "ae58039e1319178e6be73caab5c42166" # SHO
                  "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
                  "9623c5c9cac8e939c1b9aedd32f640bf" # SYFY

                  # German Miscellaneous
                  "9aa0ca0d2d66b6f6ee51fc630f46cf6f" # German 1080p Booster
                  "b493cd40d8a3bbf2839127a706bdb673" # German 2160p Booster
                  "a6a6c33d057406aaad978a6902823c35" # German LQ
                  "d80c9f7cd2aad50271f1bd4e53125778" # German LQ (release title)
                  "237eda4ef550a97da2c9d87b437e500b" # German Microsized

                  # German Source Groups
                  "7940b2fb0278f27cf4f70187f2be95d6" # German Bluray Tier 01
                  "83b336a90d90d6b35ca673b007f80661" # German Bluray Tier 02
                  "d8f8e1539827967e0e564833e6c08d33" # German Bluray Tier 03
                  "da0f005f9c3edf34fc26e18dce8c6573" # German Remux Tier 01
                  "6bc5ccd80a03e7abb8f556eecd174b73" # German Remux Tier 02
                  "c2eec878fa1989599c226ce4c287d6a7" # German Scene
                  "68be37323132b35cf333c81a2ac8fc16" # German Web Tier 01
                  "f51b96a50b0e6196cb69724b7833d837" # German Web Tier 02
                  "bda67c2c0aae257308a4723d92475b86" # German Web Tier 03

                  # HDR Formats
                  "6d0d8de7b57e35518ac0308b0ddf404e" # DV
                  "7878c33f1963fefb3d6c8657d46c2f0a" # DV HDR10
                  "2b239ed870daba8126a53bd5dc8dc1c8" # DV HDR10+
                  "1f733af03141f068a540eec352589a89" # DV HLG
                  "27954b0a80aab882522a88a4d9eae1cd" # DV SDR
                  "3e2c4e748b64a1a1118e0ea3f4cf6875" # HDR
                  "bb019e1cd00f304f80971c965de064dc" # HDR (undefined)
                  "3497799d29a085e2ac2df9d468413c94" # HDR10
                  "a3d82cbef5039f8d295478d28a887159" # HDR10+
                  "17e889ce13117940092308f48b48b45b" # HLG
                  "2a7e3be05d3861d6df7171ec74cad727" # PQ

                  # HDR Optional
                  "ef4963043b0987f8485bc9106f16db38" # DV (Disk)
                  "9b27ab6498ec0f31a3353992e19434ca" # DV (WEBDL)
                  "385e9e8581d33133c3961bdcdeffb7b4" # DV HDR10+ Boost
                  "0dad0a507451acddd754fe6dc3a7f5e7" # HDR10+ Boost
                  "2016d1676f5ee13a5b7257ff86ac9a93" # SDR
                  "83304f261cf516bb208c18c54c0adf97" # SDR (no WEBDL)

                  # HQ Source Groups
                  "d6819cba26b1a6508138d25fb5e32293" # HD Bluray Tier 01
                  "c2216b7b8aa545dc1ce8388c618f8d57" # HD Bluray Tier 02
                  "9965a052eb87b0d10313b1cea89eb451" # Remux Tier 01
                  "8a1d0c3d7497e741736761a1da866a2e" # Remux Tier 02
                  "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
                  "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
                  "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
                  "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03

                  # Language profiles
                  "8a9fcdbb445f2add0505926df3bb7b8a" # German
                  "ed51973a811f51985f14e2f6f290e47a" # German DL
                  "c5dd0fd675f85487ad5bdf97159180bd" # German DL (undefined)
                  "69aa1e159f97d860440b04cd6d590c4f" # Language: Not English
                  "322fca6f8f3694acc1401ddb530fd33d" # Language: Not French
                  "ae575f95ab639ba5d15f663bf019e3e8" # Language: Not Original
                  "10e77b96ae4770a7de645a91a53ce29a" # Language: Original + French
                  "133589380b89f8f8394320901529bac1" # Not German or English

                  # Misc Streaming Services
                  "e6e299075e22ac8f541f722254c8350a" # AUBC
                  "defb0b4c8b3f6a15927c0f14c6e69c94" # CBC
                  "4e9a630db98d5391aec1368a0256e2fe" # CRAV
                  "dc5f2bb0e0262155b5fedd0f6c5d2b55" # DSCP
                  "fb1a91cdc0f26f7ca0696e0e95274645" # OViD
                  "3ac5d84fce98bab1b531393e9c82f467" # QIBI
                  "c30d2958827d1867c73318a5a2957eb1" # RED
                  "fe4062eac43d4ea75955f8ae48adcf1e" # STRP

                  # Miscellaneous
                  "290078c8b266272a5cc8e251b5e2eb0b" # 1080p
                  "1bef6c151fa35093015b0bfef18279e5" # 2160p
                  "c99279ee27a154c2f20d1d505cc99e25" # 720p
                  "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
                  "d7c747094a7c65f4c2de083c24899e8b" # FreeLeech
                  "1bd69272e23c5e6c5b1d6c8a36fce95e" # HFR
                  "5ab46ff851b76c337e13e81a4353875f" # INTERNAL
                  "4aee45b0868229c4fbd8bad3e315f1d0" # MPEG2
                  "7ba05c6e0e14e793538174c679126996" # MULTi
                  "82d40da2bc6923f41e14394075dd4b03" # No-RlsGroup
                  "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
                  "eb3d5cc0a2be0db205fb823640db6a3c" # Repack v2
                  "44e7c4de10ae50265753082e5dc76047" # Repack v3
                  "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
                  "06d66ab109d4d2eddb2794d21526d140" # Retags
                  "1b3994c551cbb92a2c781af061f4ab44" # Scene
                  "3bc5f395426614e155e585a2f056cdf1" # Season Pack
                  "7470a681e6205243983c4410ee4c920f" # VC-1
                  "90501962793d580d011511155c97e4e5" # VP9
                  "cddfb4e32db826151d97352b8e37c648" # x264
                  "c9eafd50846d299b862ca9bb6ea91950" # x265
                  "9b64dff695c2115facf1b6ea59c9bd07" # x265 (no HDR/DV)
                  "041d90b435ebd773271cea047a457a6a" # x266

                  # Optional Streaming Services
                  "43b3cf48cb385cd3eac608ee6bca7f09" # UHD Streaming Boost
                  "d2d299244a92b8a52d4921ce3897a256" # UHD Streaming Cut

                  # Series Versions
                  "3a4127d8aa781b44120d907f2cd62627" # Hybrid
                  "b735f09d3c025cbb7d75a5d38325b73b" # Remaster

                  # UK Streaming Services
                  "bbcaf03147de0f73be2be4a9078dfa03" # 4OD
                  "fcc09418f67ccaddcf3b641a22c5cfd7" # ALL4
                  "dc503e2425126fa1d0a9ad6168c83b3f" # IP
                  "fa5a16b951004c23e980d2913694a137" # ITVX
                  "9f72dc1059a6b277c21cee6a1f15f13f" # MY5
                  "b66a699fba6f9df91becab798d7502e5" # NOW

                  # Unwanted
                  "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
                  "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
                  "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
                  "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
                  "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
                  "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
                  "47435ece6b99a0b477caf360e79ba0bb" # x265 (HD)
                ];
              }
            ];
          };
        };
        traefik.dynamicConfigOptions = lib.optionalAttrs config.services.tailscale.enable {
          http = {
            routers."${service}" = {
              rule = "Host(`${config.networking.hostName}.${config.services.tailscale.tailnet}.ts.net`) && PathPrefix(`${url-path}`)";
              tls.certresolver = "ts";
              entrypoints = [ "websecure" ];
              service = service;
            };
            services."${service}".loadbalancer.servers = [
              {
                url = "http://localhost:${builtins.toString config.services.${service}.settings.server.port}";
              }
            ];
          };
        };
      };
    users.users.sonarr.extraGroups = lib.optionals (config.users.groups ? "media") [
      config.users.groups.media.name
    ];

    sops.secrets."tokens/arr/sonarr" = {
      mode = "0666";
      inherit (config.services.recyclarr) group;
    };
  };

}
