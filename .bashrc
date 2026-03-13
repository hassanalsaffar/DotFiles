# 1. Non-interactive shell check
[[ "$-" != *i* ]] && return

# 2. Modular Sourcing
for file in ~/.{exports,aliases,functions}; do
    [[ -r "$file" ]] && source "$file"
done

# 3. Environment & UI Variables
export EDITOR=$(which vim 2>/dev/null || echo "vi")
export GPG_TTY=${TTY}
export LOG_COLORS=cxgxdxhxcxhxBxdxCxGxHxxA
export LOG_STYLE=compact

# 4. OS-Specific Color Logic
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS / BSD Logic
    export CLICOLOR=1
    export LSCOLORS=GxFxCxDxBxegedabagaced
    alias ls='ls -G'
    alias ll='ls -lhG'
else
    # Raspberry Pi / Linux (GNU) Logic
    if [ -x /usr/bin/dircolors ]; then
        test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
        alias ls='ls --color=auto'
        alias ll='ls -l --color=auto'
        alias grep='grep --color=auto'
    fi
fi

# 5. Identity-Based Prompt & Safety
if [ "$EUID" -eq 0 ]; then
    # Root: Red prompt
    PS1='\[\e[31m\]\u@\h\[\e[0m\]:\[\e[36m\]\w\[\e[00m\] \$ '
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
else
    # Standard User: Green/Yellow prompt
    PS1='\[\e[32m\]\u\[\e[33m\]@\h\[\e[0m\]:\[\e[36m\]\w\[\e[00m\] \$ '
fi

# 6. Terminal Window Title & Completion
printf "\033]0;%s\007" "${HOSTNAME%%.*}"
complete -cf sudo
