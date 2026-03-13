# 1. Non-interactive shell check
[[ "$-" != *i* ]] && return

# 2. Modular Sourcing
# Loads separate files for exports, aliases, and functions if they exist
for file in ~/.{exports,aliases,functions}; do
    [[ -r "$file" ]] && source "$file"
done

# 3. Environment & UI Variables
export EDITOR=$(which vim 2>/dev/null || echo "vi")
export GPG_TTY=${TTY}
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export LOG_COLORS=cxgxdxhxcxhxBxdxCxGxHxxA
export LOG_STYLE=compact

# 4. Completion & Aliases
complete -cf sudo
alias ls='ls -G' # Ensures LSCOLORS are applied on macOS/BSD

# 5. Identity-Based Prompt & Safety
if [ "$EUID" -eq 0 ]; then
    # Root: Red prompt + safety confirmation aliases
    PS1='\[\e[31m\]\u@\h\[\e[0m\]:\[\e[36m\]\w\[\e[00m\] \$ '
    alias rm='rm -i'
    alias cp='cp -i'
    alias mv='mv -i'
else
    # Standard User: Green/Yellow prompt
    PS1='\[\e[32m\]\u\[\e[33m\]@\h\[\e[0m\]:\[\e[36m\]\w\[\e[00m\] \$ '
fi

# 6. Terminal Window Title
# Updates the tab/window title to the current hostname
printf "\033]0;%s\007" "${HOSTNAME%%.*}"
