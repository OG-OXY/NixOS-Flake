
if status is-interactive
  set -g fish_greeting "Welcome to NixOS!"
  set -g fish_handle_reflow 1  
  
  abbr neo nvim
  abbr sneo sudoedit
  
  fastfetch
  direnv hook fish | source
end
