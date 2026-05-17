if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_user_paths $HOME/bin $fish_user_paths
alias hx helix
alias cd z
set fish_greeting

zoxide init fish | source
starship init fish | source
