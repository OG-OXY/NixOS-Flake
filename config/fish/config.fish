set -gx EDITOR nvim
set -gx VISUAL nvim
if status is-interactive
  set -g fish_greeting "Welcome to NixOS!"
  set -g fish_handle_reflow 1
  alias ls ls -a
  abbr -a cds cd ~/NixOS/nixos
  abbr -a ga git add -A
  abbr -a gc git commit -m '"'
  abbr -a gp git push -u origin master
  abbr -a gpf git push -u --force origin master
  abbr -a yz yazi
  abbr -a nv nvim
  abbr -a snv sudoedit nvim
  abbr -a v vis
  abbr -a sv sudoedit vis
  abbr -a sy sudo yazi
  abbr -a nrs sudo nixos-rebuild switch --flake .#nixos
  abbr -a nrsu sudo nixos-rebuild switch --upgrade --flake .#nixos
  abbr -a nb nix backup
  fastfetch
  direnv hook fish | source
end
