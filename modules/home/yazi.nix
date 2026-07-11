{ config, pkgs, ... }: {
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "mtime";
        sort_sensitive = false;
        sort_reverse = true;
      };
    };
  };
}
