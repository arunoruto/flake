{
  config,
  lib,
  ...
}:
let
  colors = config.lib.stylix.colors.withHashtag;
in
{
  # The first entry of `themes` becomes the active theme when
  # `settings.theme` is unset.
  config = lib.mkIf (config.programs.superfile.enable && config.stylix.enable) {
    programs.superfile.themes.stylix = {
      # Only used by the builtin chroma previewer (see code_previewer).
      code_syntax_highlight = "base16-snazzy";

      file_panel_border = colors.base03;
      sidebar_border = colors.base03;
      footer_border = colors.base03;

      file_panel_border_active = colors.base0D;
      sidebar_border_active = colors.base0E;
      footer_border_active = colors.base0A;
      modal_border_active = colors.base0C;

      full_screen_bg = colors.base00;
      file_panel_bg = colors.base00;
      sidebar_bg = colors.base00;
      footer_bg = colors.base00;
      modal_bg = colors.base01;

      full_screen_fg = colors.base05;
      file_panel_fg = colors.base05;
      sidebar_fg = colors.base05;
      footer_fg = colors.base05;
      modal_fg = colors.base05;

      cursor = colors.base0C;
      correct = colors.base0B;
      error = colors.base08;
      hint = colors.base0D;
      cancel = colors.base04;
      gradient_color = [
        colors.base0D
        colors.base0E
      ];

      file_panel_top_directory_icon = colors.base0B;
      file_panel_top_path = colors.base0D;
      file_panel_item_selected_fg = colors.base09;
      file_panel_item_selected_bg = "";

      sidebar_title = colors.base0E;
      sidebar_item_selected_fg = colors.base09;
      sidebar_item_selected_bg = "";
      sidebar_divider = colors.base03;

      modal_cancel_fg = colors.base08;
      modal_cancel_bg = "";
      modal_confirm_fg = colors.base0B;
      modal_confirm_bg = "";

      help_menu_hotkey = colors.base0C;
      help_menu_title = colors.base0E;
    };
  };
}
