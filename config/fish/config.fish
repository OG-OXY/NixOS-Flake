
if status is-interactive
  set -g fish_greeting "Welcome to NixOS!"
  set -g fish_handle_reflow 1  
  
  abbr -a sy sudo yazi
  abbr -a nrs sudo nixos-rebuild switch --flake .#nixos
  
  fastfetch
  direnv hook fish | source
end
