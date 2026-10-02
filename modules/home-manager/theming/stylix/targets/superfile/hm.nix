{ mkTarget, ... }:
mkTarget {
  config =
    { colors }:
    {
      # The first entry of `themes` becomes the active theme when
      # `settings.theme` is unset.
      programs.superfile.themes.stylix = with colors.withHashtag; {
        # Only used by the builtin chroma previewer (see code_previewer).
        code_syntax_highlight = "base16-snazzy";

        file_panel_border = base03;
        sidebar_border = base03;
        footer_border = base03;

        file_panel_border_active = base0D;
        sidebar_border_active = base0E;
        footer_border_active = base0A;
        modal_border_active = base0C;

        full_screen_bg = base00;
        file_panel_bg = base00;
        sidebar_bg = base00;
        footer_bg = base00;
        modal_bg = base01;

        full_screen_fg = base05;
        file_panel_fg = base05;
        sidebar_fg = base05;
        footer_fg = base05;
        modal_fg = base05;

        cursor = base0C;
        correct = base0B;
        error = base08;
        hint = base0D;
        cancel = base04;
        gradient_color = [
          base0D
          base0E
        ];

        file_panel_top_directory_icon = base0B;
        file_panel_top_path = base0D;
        file_panel_item_selected_fg = base09;
        file_panel_item_selected_bg = "";

        sidebar_title = base0E;
        sidebar_item_selected_fg = base09;
        sidebar_item_selected_bg = "";
        sidebar_divider = base03;

        modal_cancel_fg = base08;
        modal_cancel_bg = "";
        modal_confirm_fg = base0B;
        modal_confirm_bg = "";

        help_menu_hotkey = base0C;
        help_menu_title = base0E;
      };
    };
}
