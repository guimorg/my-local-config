# autocompletion for git
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

# VPN ticket
source $HOME/.secrets/secret.sh

# some functions
mcd () {
    # Creates dir and cd into dir
    mkdir -p $1
    cd $1
}

mov_to_gif(){
    echo "📽️  Going to transform ${1} to ${2} 📽️"
    ffmpeg -i ${1}.mov -s 800x600 -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > ${2}.gif
    echo "🍿 Finished! 🍿"
}

pintoken(){
    # Gets TOTP ticket
    totp --list meli >> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "TOTP for MeLi is not available!"
        return 2
    fi
    
    melitotp="$(totp --totp meli)"
    echo "${VPN_PIN}${melitotp}"
}

meli_aws_login() {
    # Getting token and pin
    which aws-bastion-cli >> /dev/null
    if [[ $? -ne 0 ]]; then
        echo "Could not find aws-bastion-cli 😓"
        return 2
    fi
    
    echo "Getting your pintoken 😏 🍆"
    token=`pintoken`
    echo "Logging in using aws-bastion-cli ☁️"
    aws_json_fields="$(aws-bastion-cli -t ${token} --print 2>/dev/null)"
    if [[ $? -ne 0 ]]; then
        echo "Try again!"
        return 1
    fi
    expire=$(jq -r '.Expiration' <<< "${aws_json_fields}")
    echo "Credentials will expire at ${expire} ⏲️"
    export AWS_ACCESS_KEY_ID=$(jq -r '.AccessKeyId' <<< "${aws_json_fields}")
    export AWS_SECRET_ACCESS_KEY=$(jq -r '.SecretAccessKey' <<< "${aws_json_fields}")
    export AWS_SECURITY_TOKEN=$(jq -r '.SessionToken' <<< "${aws_json_fields}")
    export AWS_SESSION_TOKEN=$(jq -r '.SessionToken' <<< "${aws_json_fields}")
    echo "All done! Goodbye! 😍"
}

# some aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ls='ls -GwF'
alias ll='ls -alh'
alias l='ls -CF'
alias en_to_pt='trans en:pt "$@"'
alias es_to_pt='trans es:pt "$@"'
alias es_to_en='trans es:en "$@"'
alias pt_to_en='trans pt:en "$@"'
alias pt_to_es='trans pt:es "$@"'

# python3
alias python=python3

# to quickly edit zshrc
alias zshrc='vim ~/.zshrc'

# to quickly edit vimrc
alias vimrc='vim ~/.vimrc'

# quickly update zhsrc
alias update="source ~/.zshrc"

# default editor
EDITOR=vim

# Not sure why GOPATH is unset
GOPATH=$HOME/go

# gitconfig if needed
alias gitconfig='vim ~/.gitconfig'
# Added by furycli:
export PATH="$HOME/Library/Python/3.7/bin:$GOPATH/bin:$PATH"
source "$HOME/.oh-my-zsh/custom/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
source $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load completion config
source $HOME/.zsh/completion.zsh

# Initialize the completion system
autoload -Uz compinit

# Cache completion if nothing changed - faster startup time
typeset -i updated_at=$(date +'%j' -r ~/.zcompdump 2>/dev/null || stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)
if [ $(date +'%j') != $updated_at ]; then
  compinit -i
else
  compinit -C -i
fi

# Enhanced form of menu completion called `menu selection'
zmodload -i zsh/complist

eval "$(starship init zsh)"
source $HOME/.zsh/history.zsh

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
