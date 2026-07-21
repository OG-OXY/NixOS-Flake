{
  config,
  pkgs,
  ...
}:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    package = null;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "mtime";
        sort_sensitive = false;
        sort_reverse = true;
      };
      opener = {
        edit = [
          {
            run = "nvf \"$@\"";
            block = true;
            desc = "Edit";
          }
        ];
      };
    };
  };
}
