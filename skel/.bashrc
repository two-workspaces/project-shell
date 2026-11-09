# ~/.bashrc - persisted on the Railway volume. Edit freely.
[ -z "$PS1" ] && return
export PATH="$HOME/.local/bin:$PATH"
export EDITOR=vim
HISTSIZE=10000 HISTFILESIZE=100000
shopt -s histappend
alias ll='ls -alF'
PS1='\[\e[1;35m\]${RAILWAY_PROJECT_NAME:-railway}\[\e[0m\]/\[\e[36m\]${RAILWAY_ENVIRONMENT_NAME:-env}\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '
if [ -f ~/.motd ] && [ -z "$TERMINAL_MOTD_SHOWN" ]; then
  export TERMINAL_MOTD_SHOWN=1
  cat ~/.motd
  db 2>/dev/null || true
  echo
fi
