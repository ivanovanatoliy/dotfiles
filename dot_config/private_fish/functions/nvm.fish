function nvm --description 'Node Version Manager wrapper'
    set -q NVM_DIR; or set -gx NVM_DIR $HOME/.nvm
    bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
end
