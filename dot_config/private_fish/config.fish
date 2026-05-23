if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -U fish_user_paths $HOME/bin $fish_user_paths
alias hx helix
alias cd z
set fish_greeting

set -Ux BROWSER helium-browser
set -Ux TERMINAL foot

zoxide init fish | source
starship init fish | source

# Created by `pipx` on 2026-05-20 19:00:50
set PATH $PATH /home/anatoliy/.local/bin
