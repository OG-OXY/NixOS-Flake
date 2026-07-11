{ config, pkgs, ... }: {
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      ai.enabled = true;
      dialect = "us";
      timezone = "local";
      auto_sync = true;
      show_preview = true;
      exit_mode = "return-original";
      word_jump_mode = "emacs";
      show_numeric_shortcuts = true;
      show_help = true;
      show_tabs = true;
      enter_accept = true;
      command_chaining = true;
      sync.records = true;
      tmux.enabled = false;
    };
  };
}
