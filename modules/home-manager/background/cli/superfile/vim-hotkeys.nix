# superfile's upstream vim preset (src/superfile_config/vimHotkeys.toml,
# v1.3.3), with:
# - open_spf_prompt added: the preset omits it, and superfile warns about
#   every missing hotkey on each start
# - h/l on parent_directory/confirm, for yazi muscle memory
{
  # Global hotkeys (cannot conflict with other hotkeys)
  confirm = [
    "enter"
    "l"
  ];
  quit = [ "ctrl+c" ];
  list_up = [ "k" ];
  list_down = [ "j" ];
  page_up = [ "pgup" ];
  page_down = [ "pgdown" ];

  create_new_file_panel = [ "n" ];
  close_file_panel = [ "q" ];
  next_file_panel = [ "tab" ];
  previous_file_panel = [ "shift+tab" ];
  toggle_file_preview_panel = [ "f" ];
  open_sort_options_menu = [ "o" ];
  toggle_reverse_sort = [ "R" ];

  focus_on_process_bar = [ "ctrl+p" ];
  focus_on_sidebar = [ "ctrl+s" ];
  focus_on_metadata = [ "ctrl+d" ];

  file_panel_item_create = [ "a" ];
  file_panel_item_rename = [ "r" ];

  copy_items = [ "y" ];
  cut_items = [ "x" ];
  paste_items = [ "p" ];
  delete_items = [ "d" ];

  extract_file = [ "ctrl+e" ];
  compress_file = [ "ctrl+a" ];

  open_file_with_editor = [ "e" ];
  open_current_directory_with_editor = [ "E" ];

  pinned_directory = [ "P" ];
  toggle_dot_file = [ "." ];
  change_panel_mode = [ "m" ];
  open_help_menu = [ "?" ];
  open_command_line = [ ":" ];
  open_spf_prompt = [ ">" ];
  copy_path = [ "Y" ];
  copy_present_working_directory = [ "c" ];
  toggle_footer = [ "ctrl+f" ];

  # Typing hotkeys (can conflict with all hotkeys)
  confirm_typing = [ "enter" ];
  cancel_typing = [ "esc" ];

  # Normal mode hotkeys (cannot conflict with global hotkeys)
  parent_directory = [
    "-"
    "h"
  ];
  search_bar = [ "/" ];

  # Select mode hotkeys (cannot conflict with global hotkeys)
  file_panel_select_mode_items_select_down = [ "J" ];
  file_panel_select_mode_items_select_up = [ "K" ];
  file_panel_select_all_items = [ "A" ];
}
